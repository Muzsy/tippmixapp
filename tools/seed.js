#!/usr/bin/env node
/* Minimal Firestore seed for emulator-only usage.
 * Connects to localhost emulators and seeds baseline data:
 * - users (3 roles)
 * - tickets (pending)
 * - fixtures index skeleton
 * - leaderboard snapshot
 */

const admin = require('firebase-admin');

function ensureEmulatorEnv() {
  process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
  process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
  process.env.FIREBASE_STORAGE_EMULATOR_HOST = process.env.FIREBASE_STORAGE_EMULATOR_HOST || 'localhost:9199';
  process.env.GOOGLE_CLOUD_PROJECT = process.env.GOOGLE_CLOUD_PROJECT || 'tippmixapp-dev';
}

async function main() {
  ensureEmulatorEnv();
  if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: process.env.GOOGLE_CLOUD_PROJECT });
  }
  const db = admin.firestore();

  const users = [
    { id: 'u_user', email: 'user@example.com', role: 'user' },
    { id: 'u_moderator', email: 'moderator@example.com', role: 'moderator' },
    { id: 'u_admin', email: 'admin@example.com', role: 'admin' },
  ];

  console.log('Seeding users...');
  for (const u of users) {
    await db.collection('users').doc(u.id).set({
      email: u.email,
      role: u.role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      coins: 1000,
    }, { merge: true });
  }

  console.log('Seeding fixtures + tickets...');
  const fixtureId = '1379538'; // matches tmp/fixture_1379538.txt for parity
  await db.collection('fixtures').doc(fixtureId).set({
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  // Pending ticket with 2 tips
  const pendingTicket = {
    userId: 'u_user',
    stake: 100,
    status: 'pending',
    tips: [
      { eventId: '1379538', marketKey: 'H2H', outcome: 'Home', odds: 1.75, result: 'pending' },
      { eventId: '1379538', marketKey: 'OU_2_5', outcome: 'Over', odds: 1.95, result: 'pending' },
    ],
    createdAt: new Date(),
  };
  const tRef = db.collection('users').doc('u_user').collection('tickets').doc();
  await tRef.set(pendingTicket);
  await db.collection('fixtures').doc(fixtureId).collection('ticketTips').add({
    userId: 'u_user', ticketId: tRef.id, tipIndex: 0, status: 'pending', createdAt: new Date(),
  });

  console.log('Seeding leaderboard snapshot...');
  await db.collection('leaderboard').doc('daily').set({
    date: new Date().toISOString().slice(0, 10),
    top: [
      { userId: 'u_admin', coins: 20000 },
      { userId: 'u_moderator', coins: 12000 },
      { userId: 'u_user', coins: 9800 },
    ],
    updatedAt: new Date(),
  });

  console.log('Seed complete.');
}

main().catch((e) => {
  console.error('Seed failed:', e);
  process.exit(1);
});

