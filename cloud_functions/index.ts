import { setGlobalOptions } from 'firebase-functions/v2/options';
import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import { defineSecret } from 'firebase-functions/params';
import { match_finalizer as matchFinalizerHandler } from './src/match_finalizer';

export { onUserCreate, coin_trx } from './coin_trx.logic';
export { log_coin } from './log_coin';
export { onFriendRequestAccepted } from './friend_request';
export { daily_bonus } from './src/daily_bonus';

// Global options for all v2 functions
setGlobalOptions({ region: 'europe-central2' });

// Secret from Secret Manager (Console → Secret Manager → API_FOOTBALL_KEY)
export const API_FOOTBALL_KEY = defineSecret('API_FOOTBALL_KEY');

// Gen2 Pub/Sub trigger (topic: result-check, region via global options)
export const match_finalizer = onMessagePublished({ topic: 'result-check', secrets: [API_FOOTBALL_KEY] }, async (event) => {
  const msg = {
    data: event.data.message?.data,
    attributes: event.data.message?.attributes as { [key: string]: string } | undefined,
  };
  await matchFinalizerHandler(msg as any);
});
