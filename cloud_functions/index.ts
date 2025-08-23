import './global';
import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import { API_FOOTBALL_KEY } from './global';
import * as logger from 'firebase-functions/logger';
import { match_finalizer as matchFinalizerHandler } from './src/match_finalizer';

export { onUserCreate, coin_trx } from './coin_trx.logic';
// log_coin kivezetve (Step4) – végleges törléshez futtasd egyszer:
// firebase functions:delete log_coin --region=europe-central2 --force
export { onFriendRequestAccepted } from './friend_request';
export { daily_bonus } from './src/daily_bonus';
export { claim_daily_bonus } from './src/bonus_claim';

// Global options a global.ts-ben kerül beállításra (régió + secretek)

// Gen2 Pub/Sub trigger (topic: result-check, region via global options)
export const match_finalizer = onMessagePublished(
  { topic: 'result-check', secrets: [API_FOOTBALL_KEY], retry: true },
  async (event) => {
    logger.info('match_finalizer.start');
    const msg = {
      data: event.data.message?.data,
      attributes: event.data.message?.attributes as { [key: string]: string } | undefined,
    };
    try {
      const result = await matchFinalizerHandler(msg as any);
      logger.info('match_finalizer.done', { result });
    } catch (e: any) {
      // Fallback: if handler threw, let platform retry
      logger.error('match_finalizer.unhandled_error', { error: e?.message || String(e) });
      throw e;
    }
  }
);
