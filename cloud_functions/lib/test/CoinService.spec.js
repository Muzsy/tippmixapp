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
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("@google-cloud/firestore");
admin.initializeApp({ projectId: 'demo' });
const mockDb = new firestore_1.Firestore({ projectId: 'demo' });
jest.spyOn(admin, 'firestore').mockReturnValue(mockDb);
const { CoinService } = require('../src/services/CoinService');
describe('CoinService transact', () => {
    afterAll(async () => {
        await mockDb.terminate();
    });
    it('credits only once on concurrent calls', async () => {
        const svc = new CoinService();
        await Promise.all([
            svc.credit('u1', 50, 'ticket42'),
            svc.credit('u1', 50, 'ticket42')
        ]);
        const walletSnap = await mockDb.doc('wallets/u1').get();
        expect(walletSnap.get('balance')).toBe(50);
        const ledgerSnap = await mockDb.doc('wallets/u1/ledger/ticket42').get();
        expect(ledgerSnap.exists).toBe(true);
    });
});
