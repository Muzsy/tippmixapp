import './global';
import { onCustomEventPublished } from 'firebase-functions/v2/eventarc';
import type { CloudEvent } from 'firebase-functions/v2';
import * as logger from 'firebase-functions/logger';
import { match_finalizer as matchFinalizerHandler } from './src/match_finalizer';

export { onUserCreate, coin_trx } from './coin_trx.logic';
// log_coin kivezetve (Step4) – végleges törléshez futtasd egyszer:
// firebase functions:delete log_coin --region=europe-central2 --force
export { onFriendRequestAccepted } from './friend_request';
export { daily_bonus } from './src/daily_bonus';
export { claim_daily_bonus } from './src/bonus_claim';
export { admin_coin_ops } from './admin_coin_ops';

// Global options a global.ts-ben kerül beállításra (régió + secretek)

// Gen2 Pub/Sub trigger (topic set by deploy), handle raw CloudEvent to avoid
// v2 pubsub wrapper constructing Message on undefined event.data.
export const match_finalizer = onCustomEventPublished(
  'google.cloud.pubsub.topic.v1.messagePublished',
  async (event: CloudEvent<any>) => {
    // Védő log + guard, hogy üres event esetén is értelmezhető legyen a viselkedés
    const hasMsg = !!(event as any)?.data?.message;
    let eventType: string | undefined;
    try {
      const raw = (event as any)?.data?.message?.data as string | undefined;
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
      hasData: !!(event as any)?.data?.message?.data,
      attrKeys: Object.keys((event as any)?.data?.message?.attributes ?? {}),
      ...(eventType ? { eventType } : {}),
    });
    if (!hasMsg) {
      // INFO szintre állítva – nem tekintjük hibának a hiányzó üzenetet
      logger.info('match_finalizer.no_message');
      return;
    }
    const msg = {
      data: (event as any).data.message?.data,
      attributes: (event as any).data.message?.attributes as { [key: string]: string } | undefined,
    };
    try {
      const result = await matchFinalizerHandler(msg as any);
      logger.info('match_finalizer.done', { result });
    } catch (e: any) {
      logger.error('match_finalizer.unhandled_error', { error: e?.message || String(e) });
      throw e;
    }
  }
);
