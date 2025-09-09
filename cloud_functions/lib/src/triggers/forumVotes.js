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
exports.onVoteDelete = exports.onVoteCreate = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = __importStar(require("firebase-admin"));
require("../lib/firebase");
async function updateCount(postId, delta) {
    const snap = await admin
        .firestore()
        .collectionGroup('posts')
        .where(admin.firestore.FieldPath.documentId(), '==', postId)
        .limit(1)
        .get();
    if (snap.empty) {
        return;
    }
    await snap.docs[0].ref.update({
        votesCount: admin.firestore.FieldValue.increment(delta),
    });
}
exports.onVoteCreate = (0, firestore_1.onDocumentCreated)('votes/{voteId}', async (event) => {
    const data = event.data?.data();
    const postId = data?.postId;
    if (!postId)
        return;
    await updateCount(postId, 1);
});
exports.onVoteDelete = (0, firestore_1.onDocumentDeleted)('votes/{voteId}', async (event) => {
    const data = event.data?.data();
    const postId = data?.postId;
    if (!postId)
        return;
    await updateCount(postId, -1);
});
