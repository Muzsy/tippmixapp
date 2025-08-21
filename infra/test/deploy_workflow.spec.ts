const fs = require('fs');
const assert = require('assert');
const wf = fs.readFileSync('.github/workflows/deploy.yml', 'utf8');
describe('Deploy workflow', () => {
  it('includes firebase functions deploy', () => {
    assert.match(wf, /firebase deploy --only functions/);
  });
  it('includes firestore rules deploy', () => {
    assert.match(wf, /firebase deploy --only firestore:rules/);
  });
  it('includes terraform plan', () => {
    assert.match(wf, /terraform plan/);
  });
});
