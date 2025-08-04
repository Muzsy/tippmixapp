import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';

// 1. Load secrets & MODE from .env (git‑ignored)
dotenv.config({ path: '.env' });

const mode = process.env.MODE ?? 'prod';
const settingsPath = path.resolve(`env.settings.${mode}`);

if (fs.existsSync(settingsPath)) {
  dotenv.config({ path: settingsPath, override: false });
}

export const Config = process.env; // egyszerű re‑export
