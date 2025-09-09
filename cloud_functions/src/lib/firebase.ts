import { getApps, initializeApp } from 'firebase-admin/app';
import { setGlobalOptions } from 'firebase-functions/v2/options';
import { API_FOOTBALL_KEY } from '../../global';
import { getFirestore } from 'firebase-admin/firestore';

if (!getApps().length) {
    initializeApp();
    // Apply global function options after admin initialization
    setGlobalOptions({
        region: 'europe-central2',
        secrets: [API_FOOTBALL_KEY],
        concurrency: 10,
        maxInstances: 10,
        cpu: 1,
        memory: '512MiB',
    });
}

export const db = getFirestore();
