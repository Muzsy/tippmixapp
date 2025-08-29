#!/usr/bin/env node
// Usage:
//   node tools/check_tickets.mjs --project tippmix-dev [--uid <UID>] [--watch] [--event <EVENT_ID>] [--since <ISO|1h|24h>] [--limit <N>]
// Requires ADC: `gcloud auth application-default login`

import { initializeApp, getApps, applicationDefault } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';

function parseArgs() {
  const args = process.argv.slice(2);
  const out = { limit: 50 };
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--project') out.projectId = args[++i];
    else if (a === '--uid') out.uid = args[++i];
    else if (a === '--watch') out.watch = true;
    else if (a === '--event') out.eventId = args[++i];
    else if (a === '--since') out.since = args[++i];
    else if (a === '--limit') out.limit = Number(args[++i] || '50') || 50;
  }
  return out;
}

function parseSince(input) {
  if (!input) return null;
  // Supports ISO or relative like 1h, 24h, 2d
  const rel = /^([0-9]+)([hd])$/i.exec(input);
  if (rel) {
    const n = Number(rel[1]);
    const unit = rel[2].toLowerCase();
    const ms = unit === 'h' ? n * 3600e3 : n * 86400e3;
    return new Date(Date.now() - ms);
  }
  const d = new Date(input);
  return isNaN(d.getTime()) ? null : d;
}

const { projectId, uid, watch, eventId, limit, since: sinceRaw } = parseArgs();
if (!projectId) {
  console.error('Missing --project <PROJECT_ID>');
  process.exit(2);
}
const since = parseSince(sinceRaw);

if (!getApps().length) {
  initializeApp({ credential: applicationDefault(), projectId });
}
const db = getFirestore();

function userTickets(u) {
  return db.collection('users').doc(u).collection('tickets');
}

function matchesFilters(data) {
  if (eventId) {
    const tips = data.tips || [];
    if (!tips.some(t => String(t?.eventId) === String(eventId))) return false;
  }
  if (since) {
    const u = data.updatedAt?.toDate?.() ?? (data.updatedAt instanceof Date ? data.updatedAt : null);
    if (u && u < since) return false;
  }
  return true;
}

async function listPendingSafe() {
  try {
    if (uid) {
      const q = userTickets(uid).where('status', '==', 'pending').limit(limit);
      const snap = await q.get();
      return snap.docs
        .map(d => ({ path: d.ref.path, ...d.data() }))
        .filter(matchesFilters);
    }
    const q = db.collectionGroup('tickets').where('status', '==', 'pending').limit(limit);
    const snap = await q.get();
    return snap.docs
      .map(d => ({ path: d.ref.path, ...d.data() }))
      .filter(matchesFilters);
  } catch (e) {
    console.error('Pending query failed. Tip: add --uid <UID> to bypass global index/permissions. Error:', e?.message || e);
    return [];
  }
}

async function listLatestSafe() {
  try {
    if (uid) {
      const snap = await userTickets(uid).limit(Math.max(100, limit)).get();
      const rows = snap.docs.map(d => ({
        path: d.ref.path,
        updatedAt: d.get('updatedAt')?.toDate?.() ?? null,
        status: d.get('status'),
        payout: d.get('payout') ?? 0,
      })).filter(matchesFilters);
      rows.sort((a, b) => (b.updatedAt?.getTime?.() || 0) - (a.updatedAt?.getTime?.() || 0));
      return rows.slice(0, limit);
    }
    const snap = await db.collectionGroup('tickets').limit(Math.max(200, limit)).get();
    const rows = snap.docs.map(d => ({
      path: d.ref.path,
      updatedAt: d.get('updatedAt')?.toDate?.() ?? null,
      status: d.get('status'),
      payout: d.get('payout') ?? 0,
    })).filter(matchesFilters);
    rows.sort((a, b) => (b.updatedAt?.getTime?.() || 0) - (a.updatedAt?.getTime?.() || 0));
    return rows.slice(0, limit);
  } catch (e) {
    console.error('Latest query failed. Tip: add --uid <UID> to bypass global index/permissions. Error:', e?.message || e);
    return [];
  }
}

function summarize(rows) {
  const sum = { won: 0, lost: 0, pending: 0, payout: 0 };
  for (const r of rows) {
    sum[r.status] = (sum[r.status] || 0) + 1;
    if (typeof r.payout === 'number') sum.payout += r.payout;
  }
  return sum;
}

async function main() {
  const pend = await listPendingSafe();
  const sumPend = summarize(pend.map(x => ({ status: 'pending', payout: x.payout || 0 })));
  console.log(`Pending tickets${uid ? ' for ' + uid : ''}${eventId ? ' (event ' + eventId + ')' : ''}: ${pend.length}`);
  if (pend.length) pend.slice(0, Math.min(10, pend.length)).forEach(r => console.log(` - ${r.path} stake=${r.stake} tips=${(r.tips||[]).length}`));

  const latest = await listLatestSafe();
  console.log('\nLatest tickets:');
  latest.forEach(r => console.log(` - ${r.path} status=${r.status} payout=${r.payout}`));
  const sumLatest = summarize(latest);
  console.log(`\nSummary: won=${sumLatest.won||0} lost=${sumLatest.lost||0} pending=${sumLatest.pending||0} totalPayout=${sumLatest.payout||0}`);

  if (!watch) return;
  console.log('\nWatching for status changes... (Ctrl+C to exit)');
  let q = uid ? userTickets(uid) : db.collectionGroup('tickets');
  // Note: global watch may require index/permissions; if it fails, advise to use --uid
  const cache = new Map();
  const flushChanges = (() => {
    let tm = null;
    return (fn) => {
      if (tm) clearTimeout(tm);
      tm = setTimeout(fn, 300);
    };
  })();
  try {
    q.onSnapshot(
      snap => {
        const changes = [];
        snap.docChanges().forEach(ch => {
          if (ch.type !== 'modified') return;
          const d = ch.doc;
          const prev = cache.get(d.id);
          const cur = { status: d.get('status'), payout: d.get('payout') ?? 0 };
          cache.set(d.id, cur);
          if (!prev || prev.status !== cur.status || prev.payout !== cur.payout) {
            if (matchesFilters({ ...d.data(), updatedAt: d.get('updatedAt') })) {
              changes.push(`* ${d.ref.path}: ${prev ? prev.status : 'n/a'} -> ${cur.status}, payout=${cur.payout}`);
            }
          }
        });
        if (changes.length) flushChanges(() => changes.forEach(c => console.log(c)));
      },
      err => {
        console.error('Watch failed. Tip: add --uid <UID> to reduce scope. Error:', err?.message || err);
      }
    );
  } catch (e) {
    console.error('Watch init failed. Tip: add --uid <UID>. Error:', e?.message || e);
  }
}

main().catch(e => {
  console.error('Error:', e);
  process.exit(1);
});
