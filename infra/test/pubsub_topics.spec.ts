import fs from 'fs';
import path from 'path';

const tf = fs.readFileSync(path.resolve('infra/pubsub_topics.tf'), 'utf8');

describe('Terraform Pub/Sub topics', () => {
  it('should declare result-check topic', () => {
    expect(tf).toMatch(/name\s*=\s*"result-check"/);
  });

  it('should declare result-check-dlq topic', () => {
    expect(tf).toMatch(/name\s*=\s*"result-check-dlq"/);
  });
});
