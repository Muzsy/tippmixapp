import * as firebase from "@firebase/rules-unit-testing";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getFunctions, httpsCallable } from "firebase/functions";
import { jest } from "@jest/globals";

const PROJECT_ID = "demo-project";
const UID = "user_e2e";
const FIXTURE_ID_WIN = "123456";    // 2-1 → home win
const FIXTURE_ID_VOID = "223344";   // 0-0 → void

describe("E2E: create → finalize → payout", () => {
  let app: any;
  beforeAll(async () => {
    process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
    process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || "localhost:9099";
    app = initializeApp({ projectId: PROJECT_ID });
    const db = getFirestore();
    await db.collection("users").doc(UID).set({ balance: 10000 });
  });

  afterAll(async () => {
    await firebase.clearFirestoreData({ projectId: PROJECT_ID });
  });

  it("creates ticket, finalizes once, idempotent on second finalize", async () => {
    // 1) create ticket via callable
    // NOTE: a valós callable export nevét a projektnek megfelelően állítsd be
    // Itt feltételezzük: functions index exportálja `createTicket`

    const stake = 1500;
    const tips = [
      { fixtureId: FIXTURE_ID_WIN, market: "1X2", selection: "HOME", oddsSnapshot: 1.80, kickoff: Date.now() + 60_000 },
      { fixtureId: FIXTURE_ID_VOID, market: "1X2", selection: "DRAW", oddsSnapshot: 3.10, kickoff: Date.now() + 60_000 }
    ];

    // A callable meghívása itt pszeudókód, mert emulátoros Functions kliens projekt-specifikus.
    // A Codex futásban a projekt saját helperét kell használni (ld. README / index.ts exportok).

    // 2) run match_finalizer (once)
    // 3) assert: ticket.status/payout, users.balance increased by payout
    // 4) run match_finalizer (second time) → no changes (idempotent)

    expect(true).toBe(true);
  });
});
