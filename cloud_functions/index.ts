import './global';
import { onCustomEventPublished } from 'firebase-functions/v2/eventarc';
import * as logger from 'firebase-functions/logger';
import { match_finalizer as matchFinalizerHandler } from './src/match_finalizer';

export { onUserCreate, coin_trx } from './coin_trx.logic';
// log_coin kivezetve (Step4) – végleges törléshez futtasd egyszer:
// firebase functions:delete log_coin --region=europe-central2 --force
export { onFriendRequestAccepted } from './friend_request';
export { daily_bonus } from './src/daily_bonus';
export { claim_daily_bonus } from './src/bonus_claim';
export { admin_coin_ops } from './admin_coin_ops';
export { reserve_nickname } from './src/username_reservation';

// Global options a global.ts-ben kerül beállításra (régió + secretek)

// Gen2 Pub/Sub trigger (topic set by deploy), handle raw CloudEvent to avoid
// v2 pubsub wrapper constructing Message on undefined event.data.
export const match_finalizer = onCustomEventPublished(
  'google.cloud.pubsub.topic.v1.messagePublished',
  async (event) => {
    // Védő log + guard, hogy üres event esetén is értelmezhető legyen a viselkedés
    const ev: any = event as any;
    let dataB64: string | undefined = ev?.data?.message?.data as string | undefined;
    let attrs: { [key: string]: string } | undefined = ev?.data?.message?.attributes as any;
    // Eventarc CUSTOM_PUBSUB eset: data.data / data.attributes
    if (!dataB64 && ev?.data?.data) dataB64 = ev.data.data as string;
    if (!attrs && ev?.data?.attributes) attrs = ev.data.attributes as any;
    // Ha továbbra sincs dataB64, próbáljuk az egész data objektumot JSON-ként base64-elni
    if (!dataB64 && ev?.data) {
      try {
        dataB64 = Buffer.from(JSON.stringify(ev.data), 'utf8').toString('base64');
      } catch (_) {}
    }
    const hasMsg = !!dataB64;
    let eventType: string | undefined;
    try {
      const raw = dataB64;
      if (raw) {
        const jsonStr = Buffer.from(raw, 'base64').toString('utf8');
        const parsed = JSON.parse(jsonStr);
        if (parsed && typeof parsed === 'object' && parsed.type === 'diag-check') {
          eventType = 'diag-check';
        }
      }
    } catch (_) {
      // ignore parse errors – not a fatal condition for logging
    }
    logger.info('match_finalizer.start', {
      hasMsg,
      hasData: !!dataB64,
      attrKeys: Object.keys(attrs ?? {}),
      ...(eventType ? { eventType } : {}),
    });
    if (!hasMsg) {
      // INFO szintre állítva – nem tekintjük hibának a hiányzó üzenetet
      logger.info('match_finalizer.no_message');
      return;
    }
    const msg = { data: dataB64, attributes: attrs };
    try {
      const result = await matchFinalizerHandler(msg as any);
      logger.info('match_finalizer.done', { result });
    } catch (e: any) {
      logger.error('match_finalizer.unhandled_error', { error: e?.message || String(e) });
      throw e;
    }
  }
);
