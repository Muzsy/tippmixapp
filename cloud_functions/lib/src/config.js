"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Config = void 0;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const dotenv_1 = __importDefault(require("dotenv"));
// 1. Load secrets & MODE from .env (git‑ignored)
dotenv_1.default.config({ path: '.env' });
const mode = process.env.MODE ?? 'prod';
const settingsPath = path_1.default.resolve(`env.settings.${mode}`);
if (fs_1.default.existsSync(settingsPath)) {
    dotenv_1.default.config({ path: settingsPath, override: false });
}
exports.Config = process.env; // egyszerű re‑export
