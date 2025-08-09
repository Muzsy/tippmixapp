 import * as functions from 'firebase-functions';
 import { match_finalizer as matchFinalizerHandler } from './src/match_finalizer';

 export { onUserCreate, coin_trx } from './coin_trx.logic';
 export { log_coin } from './log_coin';
 export { onFriendRequestAccepted } from './friend_request';

 // Pub/Sub trigger: 'result-check' topic, régió: europe-central2
 export const match_finalizer = functions
   .region('europe-central2')
   .pubsub.topic('result-check')
   .onPublish(matchFinalizerHandler);
