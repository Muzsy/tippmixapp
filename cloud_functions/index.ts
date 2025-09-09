import './global';
import './src/lib/firebase';
import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import * as logger from 'firebase-functions/logger';
import { match_finalizer as matchFinalizerHandler } from './src/match_finalizer';

export { onUserCreate, coin_trx } from './coin_trx.logic';
// log_coin kivezetve (Step4) – végleges törléshez futtasd egyszer:
// firebase functions:delete log_coin --region=europe-central2 --force
export { onFriendRequestAccepted } from './friend_request';
// cost-hardening: disable mass daily bonus cron (use claim_daily_bonus instead)
// export { daily_bonus } from './src/daily_bonus';
export { claim_daily_bonus } from './src/bonus_claim';
export { admin_coin_ops } from './admin_coin_ops';
export { reserve_nickname } from './src/username_reservation';
export { onTicketWritten_indexFixture } from './fixtures_index';
export { backfill_fixture_index } from './backfill_fixture_index';
export { finalize_publish } from './src/finalize_publish';
export { force_finalizer } from './src/force_finalizer';
export { dev_publish_finalize, dev_scheduler_kick } from './src/dev_pubsub_emulator';
export { onVoteCreate, onVoteDelete } from './src/triggers/forumVotes';

// Global options a global.ts-ben kerül beállításra (régió + secretek)

// Gen2 Pub/Sub trigger – topic: result-check
export const match_finalizer = onMessagePublished('result-check', async (event) => {
  const dataB64 = event.data.message?.data as unknown as string | undefined;
  const attrs = (event.data.message?.attributes as any) || undefined;
  const hasMsg = !!dataB64;
  let eventType: string | undefined;
  try {
    if (dataB64) {
      const jsonStr = Buffer.from(dataB64, 'base64').toString('utf8');
      const parsed = JSON.parse(jsonStr);
      if (parsed && typeof parsed === 'object' && parsed.type === 'diag-check') {
        eventType = 'diag-check';
      }
    }
  } catch (_) {}
  logger.info('match_finalizer.start', {
    hasMsg,
    hasData: !!dataB64,
    attrKeys: Object.keys(attrs ?? {}),
    ...(eventType ? { eventType } : {}),
  });
  if (!hasMsg) {
    logger.debug('match_finalizer.no_message');
    return;
  }
  const msg = { data: dataB64, attributes: attrs };
  try {
    const result = await matchFinalizerHandler(msg as any);
    logger.debug('match_finalizer.done', { result });
  } catch (e: any) {
    logger.error('match_finalizer.unhandled_error', { error: e?.message || String(e) });
    throw e;
  }
});
