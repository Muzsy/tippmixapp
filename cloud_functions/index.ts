import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import { match_finalizer as matchFinalizerHandler } from './src/match_finalizer';

export { onUserCreate, coin_trx } from './coin_trx.logic';
export { log_coin } from './log_coin';
export { onFriendRequestAccepted } from './friend_request';
export { daily_bonus } from './src/daily_bonus';

// Gen2 Pub/Sub trigger (topic: result-check, region via global options)
export const match_finalizer = onMessagePublished('result-check', async (event) => {
  const msg = {
    data: event.data.message?.data,
    attributes: event.data.message?.attributes as { [key: string]: string } | undefined,
  };
  await matchFinalizerHandler(msg as any);
});
