import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const alertTf = fs.readFileSync(
  path.resolve(__dirname, '../monitoring_alert.tf'),
  'utf8',
);

describe('Quota watcher alert TF', () => {
  it('defines remaining_credits metric', () => {
    expect(alertTf).toMatch(/remaining_credits_metric/);
  });

  it('defines credit_low_alert policy', () => {
    expect(alertTf).toMatch(/credit_low_alert/);
  });
});
