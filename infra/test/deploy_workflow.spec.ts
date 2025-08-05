const fs = require('fs');
const wf = fs.readFileSync('.github/workflows/deploy.yml', 'utf8');
describe('Deploy workflow', () => {
  it('includes gcloud functions deploy', () => {
    expect(wf).toMatch(/gcloud functions deploy/);
  });
  it('includes terraform plan', () => {
    expect(wf).toMatch(/terraform plan/);
  });
});
