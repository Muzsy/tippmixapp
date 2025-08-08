"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const ResultProvider_1 = require("../src/services/ResultProvider");
jest.mock('../src/services/ResultProvider');
jest.mock('../src/services/CoinService', () => ({
    CoinService: jest.fn().mockImplementation(() => ({ credit: jest.fn() }))
}));
jest.mock('firebase-admin', () => ({
    initializeApp: jest.fn(),
    firestore: jest.fn(),
}));
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("@google-cloud/firestore");
const mockDb = new firestore_1.Firestore({ projectId: 'demo' });
admin.firestore.mockReturnValue(mockDb);
const { match_finalizer } = require('../src/match_finalizer');
ResultProvider_1.ResultProvider.mockImplementation(() => {
    return {
        getScores: async () => [
            { id: 'event123', sport_key: 'soccer_epl', completed: true, scores: { home: 3, away: 1 } }
        ]
    };
});
it('updates tickets and credits coins on win', async () => {
    // Arrange – create fake pending ticket in emulator memory
    const ticketRef = mockDb.collection('tickets').doc('t1');
    await ticketRef.set({
        status: 'pending',
        eventId: 'event123',
        potentialProfit: 100,
        uid: 'user1'
    });
    // Act – trigger function
    const msg = {
        data: Buffer.from(JSON.stringify({ job: 'result-poller' })).toString('base64')
    };
    await match_finalizer(msg);
    // Assert – ticket status won
    const updated = await ticketRef.get();
    expect(updated.get('status')).toBe('won');
});
