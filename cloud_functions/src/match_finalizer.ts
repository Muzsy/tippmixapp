import {
  ApiFootballResultProvider,
  findFixtureIdByMeta,
} from "./services/ApiFootballResultProvider";
import { calcTicketPayout, deriveTicketStatus } from "./tickets/payout";
import { getFirestore, FieldPath } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { db } from "./lib/firebase";
import { PubSub } from "@google-cloud/pubsub";
import { CoinService } from "./services/CoinService";
import { getEvaluator, NormalizedResult } from "./evaluators";
import { API_FOOTBALL_KEY } from "../global";

const pubsub = new PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || "result-check";
const DLQ_TOPIC = process.env.DLQ_TOPIC || "result-check-dlq";
const BATCH_SIZE = Number(process.env.FINALIZER_BATCH_SIZE || 200);
const MAX_BATCHES = Number(process.env.FINALIZER_MAX_BATCHES || 3);

// After computing tip results for a ticket
async function finalizeTicketAtomic(
  ticketRef: FirebaseFirestore.DocumentReference,
  ticketData: any,
) {
  const db = getFirestore();
  await db.runTransaction(async (tx) => {
    const tSnap = await tx.get(ticketRef);
    const t = tSnap.data();
    if (!t) throw new Error("Ticket not found");
    if (t.processedAt) {
      return; // idempotent exit
    }
    const tips = (ticketData.tips || []).map((x: any) => ({
      market: x.market,
      selection: x.selection,
      result: x.result,
      oddsSnapshot: x.oddsSnapshot,
    }));
    // Early-finalize to 'lost' if any leg is lost (final outcome)
    if (tips.some((x: any) => x.result === "lost")) {
      tx.update(ticketRef, { status: "lost", payout: 0, processedAt: new Date(), tips });
      return;
    }
    // Otherwise wait until no pending legs remain
    if (tips.some((x: any) => x.result === "pending")) return;
    const payout = calcTicketPayout(ticketData.stake, tips);
    const status = deriveTicketStatus(tips as any, payout);
    // users.balance helyett csak a ticket mezői frissülnek; pénzügy a CoinService-ben
    tx.update(ticketRef, { status, payout, processedAt: new Date(), tips });
  });
}

interface PubSubMessage {
  data?: string;
  attributes?: { [key: string]: string };
}

type JobType = "kickoff-tracker" | "result-poller" | "final-sweep";

export const match_finalizer = async (
  message: PubSubMessage,
): Promise<"OK" | "RETRY" | "DLQ"> => {
  // Provider példányosítás a handler scope‑ban – Secret olvasás futásidőben
  const provider = new ApiFootballResultProvider(
    API_FOOTBALL_KEY.value() || process.env.API_FOOTBALL_KEY || ''
  );
  const attempt = Number((message?.attributes?.attempt as string) || "0");
  logger.info("match_finalizer.handle", {
    hasData: !!message?.data,
    attempt,
    attrKeys: Object.keys(message.attributes || {}),
  });
  let job: JobType | undefined;
  let fixtureIdFromMsg: string | undefined;
  try {
    const payloadStr = Buffer.from(message.data || "", "base64").toString(
      "utf8",
    );
    const parsed = JSON.parse(payloadStr) as { job?: JobType; type?: string; fixtureId?: string | number };
    job = parsed.job as JobType | undefined;
    if ((parsed.type === 'finalize' || !parsed.type) && parsed.fixtureId != null) {
      fixtureIdFromMsg = String(parsed.fixtureId);
    }

    // Batch pagination over pending tickets
    let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined =
      undefined;
    let batches = 0;
    let anyProcessed = false;
    let morePossible = false;

    // If fixtureId is provided, process only that fixture's pending tips via index
    if (fixtureIdFromMsg) {
      const fid = fixtureIdFromMsg;
      const idxSnap = await db
        .collection('fixtures').doc(fid)
        .collection('ticketTips')
        .where('status', '==', 'pending')
        .limit(BATCH_SIZE)
        .get();

      if (idxSnap.empty) {
        logger.info('match_finalizer.no_pending_fixture', { fixtureId: fid });
        return 'OK';
      }

      const ticketRefs: FirebaseFirestore.DocumentReference[] = [];
      const pairs: Array<{ userId: string; ticketId: string; tipIndex: number; idxRef: FirebaseFirestore.DocumentReference }>=[];
      idxSnap.docs.forEach((d) => {
        const userId = String(d.get('userId'));
        const ticketId = String(d.get('ticketId'));
        const tipIndex = Number(d.get('tipIndex')) || 0;
        const tRef = db.collection('users').doc(userId).collection('tickets').doc(ticketId);
        ticketRefs.push(tRef);
        pairs.push({ userId, ticketId, tipIndex, idxRef: d.ref });
      });

      const ticketSnaps = await getFirestore().getAll(...ticketRefs);

      // Fetch only the given fixtureId
      let providerResultsArr;
      try {
        providerResultsArr = await provider.getScores([fid]);
      } catch (err) {
        logger.error('match_finalizer.result_provider_error', { error: err });
        throw err;
      }
      const providerResults: Record<string, any> = {};
      for (const r of providerResultsArr) providerResults[r.id] = r;

      const results: Record<string, NormalizedResult> = {};
      for (const [eid, r] of Object.entries(providerResults)) {
        results[eid] = {
          completed: !!(r as any).completed,
          scores: (r as any).scores,
          home_team: (r as any).home_team,
          away_team: (r as any).away_team,
          winner: (r as any).winner,
        };
      }
      const voidSet = new Set<string>(
        Object.entries(providerResults)
          .filter(([_, r]: any) => r?.canceled === true || r?.status === 'canceled')
          .map(([eid]) => eid),
      );

      // Batch index status updates together
      const batch = getFirestore().batch();
      for (let i = 0; i < ticketSnaps.length; i++) {
        const snap = ticketSnaps[i];
        if (!snap?.exists) continue;
        const tipsRaw = (snap.get('tips') as any[]) || [];
        if (!tipsRaw.length) continue;
        const tipResults: any[] = [];
        for (let ti = 0; ti < tipsRaw.length; ti++) {
          const t = tipsRaw[ti];
          const pick = (t?.outcome ?? '').trim();
          const marketKey = t?.marketKey ?? t?.market ?? 'h2h';
          const evaluator = getEvaluator(String(marketKey));
          const evKey = String(t?.eventId ?? t?.fixtureId ?? '');
          const normRes = evKey === fid ? results[fid] : undefined;
          if (!normRes || !evaluator) {
            tipResults.push({
              ...t,
              market: String(marketKey).toUpperCase(),
              selection: pick,
              result: t?.result ?? 'pending',
              oddsSnapshot: t?.odds ?? t?.oddsSnapshot,
            });
            continue;
          }
          const tipInput = {
            marketKey: String(marketKey),
            selection: pick,
            odds: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
          };
          let result = evaluator.evaluate(tipInput, normRes);
          if (voidSet.has(fid)) result = 'void';
          tipResults.push({
            ...t,
            market: String(marketKey).toUpperCase(),
            selection: pick,
            result,
            oddsSnapshot: tipInput.odds,
          });
        }
        await finalizeTicketAtomic(snap.ref, { stake: snap.get('stake'), tips: tipResults });

        // sync index doc status for this pair (batched)
        const pair = pairs[i];
        const idx = pair?.tipIndex ?? 0;
        const newStatus = tipResults[idx]?.result ?? 'pending';
        batch.set(pair.idxRef as any, { status: newStatus, updatedAt: new Date() }, { merge: true } as any);
      }

      await batch.commit();

      // If we hit the page size, re-enqueue to continue processing this fixture
      if (idxSnap.size >= BATCH_SIZE) {
        await pubsub.topic(RESULT_TOPIC).publishMessage({
          data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId: fid })),
          attributes: { attempt: '0' },
        });
        logger.info('match_finalizer.enqueue_next_fixture_page', { fixtureId: fid });
      }

      logger.info('match_finalizer.finalize_done_fixture', { fixtureId: fid, count: ticketSnaps.length });
      return 'OK';
    }

    while (batches < MAX_BATCHES) {
      const filterUid = process.env.FILTER_UID;
      let q: FirebaseFirestore.Query<FirebaseFirestore.DocumentData>;
      if (filterUid) {
        q = db
          .collection('users')
          .doc(String(filterUid))
          .collection('tickets')
          .where('status', '==', 'pending')
          .limit(BATCH_SIZE) as FirebaseFirestore.Query<FirebaseFirestore.DocumentData>;
      } else {
        q = db
          .collectionGroup("tickets")
          .where("status", "==", "pending")
          .limit(BATCH_SIZE) as FirebaseFirestore.Query<FirebaseFirestore.DocumentData>;
      }
      const ticketsSnap = await q.get();
      if (ticketsSnap.empty) {
        logger.info("match_finalizer.no_pending_batch", { batch: batches });
        break;
      }
      anyProcessed = true;
      if (ticketsSnap.size === BATCH_SIZE) {
        morePossible = true;
      }
      logger.info("match_finalizer.pending_tickets_batch", {
        batch: batches,
        count: ticketsSnap.size,
      });

      // Gather unique eventIds from this batch's tips[] arrays (multi-event tickets támogatás)
      const eventIdSet = new Set<string>();
      for (const doc of ticketsSnap.docs) {
        const tips = (doc.get("tips") as any[]) || [];
        for (const t of tips) {
          if (t && typeof t.eventId === "string" && t.eventId.trim()) {
            eventIdSet.add(t.eventId.trim());
          }
        }
      }

      // Fixture ID feloldás (ha a tipben nincs eltárolva)
      const fixtureMap: Record<string, number> = {};
      for (const doc of ticketsSnap.docs) {
        const tips = (doc.get("tips") as any[]) || [];
        for (const t of tips) {
          if (!t.fixtureId && t.eventName && t.startTime) {
            const found = await findFixtureIdByMeta({
              eventName: t.eventName,
              startTime: t.startTime,
            });
            if (found?.id) {
              fixtureMap[t.eventId] = found.id;
              eventIdSet.add(String(found.id));
            }
          }
        }
      }
      const eventIds = Array.from(eventIdSet);
      logger.info("match_finalizer.unique_events_batch", {
        batch: batches,
        count: eventIds.length,
      });

      // 2) Fetch scores
      let providerResultsArr;
      try {
        providerResultsArr = await provider.getScores(eventIds);
      } catch (err) {
        logger.error("match_finalizer.result_provider_error", { error: err });
        throw err; // message will be retried / DLQ
      }

      const providerResults: Record<string, any> = {};
      for (const r of providerResultsArr) {
        providerResults[r.id] = r;
      }

      // Normalize provider result → evaluator input; canceled = void
      const results: Record<string, NormalizedResult> = {};
      for (const [eid, r] of Object.entries(providerResults)) {
        results[eid] = {
          completed: !!r.completed,
          scores: r.scores,
          home_team: r.home_team,
          away_team: r.away_team,
          winner: r.winner,
        };
      }
      // canceled/void flag támogatása
      const voidSet = new Set<string>(
        Object.entries(providerResults)
          .filter(
            ([_, r]: any) => r?.canceled === true || r?.status === "canceled",
          )
          .map(([eid]) => eid),
      );

      // 4) Evaluate each ticket based on its tips and finalize atomically
      for (const snap of ticketsSnap.docs) {
        const tipsRaw = (snap.get("tips") as any[]) || [];
        if (!tipsRaw.length) continue;

        const pendingTipUpdates: { index: number; fixtureId: number }[] = [];
        const tipResults: any[] = [];
        for (let ti = 0; ti < tipsRaw.length; ti++) {
          const t = tipsRaw[ti];
          const fid = fixtureMap[t.eventId];
          const normRes =
            results[t.eventId] || (fid ? results[String(fid)] : undefined);
          const pick = (t?.outcome ?? "").trim();
          const marketKey = t?.marketKey ?? t?.market ?? "h2h";
          const evaluator = getEvaluator(String(marketKey));
          if (!normRes || !evaluator) {
            tipResults.push({
              ...t,
              market: String(marketKey).toUpperCase(),
              selection: pick,
              result: "pending",
              oddsSnapshot: t?.odds ?? t?.oddsSnapshot,
            });
            continue;
          }
          const tipInput = {
            marketKey: String(marketKey),
            selection: pick,
            odds: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
          };
          let result = evaluator.evaluate(tipInput, normRes);
          const voidKey = fid ? String(fid) : t.eventId;
          if (voidSet.has(voidKey)) result = "void";
          tipResults.push({
            ...t,
            market: String(marketKey).toUpperCase(),
            selection: pick,
            result,
            oddsSnapshot: tipInput.odds,
          });
          if (!t.fixtureId && fid) {
            pendingTipUpdates.push({ index: ti, fixtureId: fid });
          }
        }

        const uid = snap.get("userId") || snap.ref.parent?.parent?.id;
        await finalizeTicketAtomic(snap.ref, { stake: snap.get("stake"), tips: tipResults });
        if (pendingTipUpdates.length) {
          const updates: any = {};
          for (const u of pendingTipUpdates) {
            updates[`tips.${u.index}.fixtureId`] = u.fixtureId;
          }
          await snap.ref.update(updates);
        }
        // Wallet credit via CoinService (idempotens – ledger kulcs: ticketId)
        {
          const payout = calcTicketPayout(snap.get("stake"), tipResults);
          if (uid && payout > 0) {
            const coins = Math.round(payout);
            try {
              await new CoinService().credit(String(uid), coins, snap.id);
            } catch (e) {
              logger.error("match_finalizer.wallet_credit_failed", {
                error: e,
                uid: String(uid),
                ticketId: snap.id,
              });
            }
          }
        }
      } // for ticketsSnap.docs

      // end of batch processing for this page
      // No explicit pagination cursor to avoid composite index requirement
      lastDoc = undefined;
      batches += 1;
    } // while

    if (morePossible) {
      await pubsub.topic(RESULT_TOPIC).publishMessage({
        data: Buffer.from(JSON.stringify({ job })),
        attributes: { attempt: "0" },
      });
      logger.info("match_finalizer.enqueue_next_batch", { next: true });
    }

    if (!anyProcessed) {
      logger.info("match_finalizer.no_pending");
    }
    logger.info("match_finalizer.finalize_done");
    return "OK";
  } catch (e: any) {
    logger.error("match_finalizer.handle_error", {
      error: e?.message || String(e),
      attempt,
    });
    try {
      if (attempt >= 2) {
        await pubsub
          .topic(DLQ_TOPIC)
          .publishMessage({
            data: Buffer.from(JSON.stringify({ job })),
            attributes: { attempt: String(attempt) },
          });
        logger.error("match_finalizer.sent_to_dlq", { attempt });
        return "DLQ";
      } else {
        await pubsub
          .topic(RESULT_TOPIC)
          .publishMessage({
            data: Buffer.from(JSON.stringify({ job })),
            attributes: { attempt: String(attempt + 1) },
          });
        logger.warn("match_finalizer.requeued", {
          nextAttempt: attempt + 1,
          job,
        });
        return "RETRY";
      }
    } catch (pubErr) {
      logger.error("match_finalizer.requeue_failed", { error: String(pubErr) });
    }
    return "RETRY";
  }
};
