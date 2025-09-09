import { defineSecret } from 'firebase-functions/params';

// Secret from Secret Manager (Console → Secret Manager → API_FOOTBALL_KEY)
export const API_FOOTBALL_KEY = defineSecret('API_FOOTBALL_KEY');

// Global options are applied after admin initialization in src/lib/firebase.ts
