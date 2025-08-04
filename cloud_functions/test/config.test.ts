import { Config } from '../src/config';
describe('Config loader', () => {
  it('uses dev settings when MODE=dev', () => {
    expect(Config.SCORE_POLL_CRON).toBe('0 */2 * * *');
  });
});
