import { setGlobalOptions } from 'firebase-functions/v2/options';
import { defineSecret } from 'firebase-functions/params';

// Secret from Secret Manager (Console → Secret Manager → API_FOOTBALL_KEY)
export const API_FOOTBALL_KEY = defineSecret('API_FOOTBALL_KEY');

// Global options for all v2 functions – region + secret binding
setGlobalOptions({ region: 'europe-central2', secrets: [API_FOOTBALL_KEY] });
