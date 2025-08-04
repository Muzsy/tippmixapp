import fs from 'fs';
import path from 'path';

const tf = fs.readFileSync(path.resolve('infra/scheduler_jobs.tf'), 'utf8');

describe('Terraform Scheduler jobs', () => {
  it('declares kickoff-tracker-job', () => {
    expect(tf).toMatch(/kickoff-tracker-job/);
  });
  it('declares result-poller-job', () => {
    expect(tf).toMatch(/result-poller-job/);
  });
  it('declares final-sweep-job', () => {
    expect(tf).toMatch(/final-sweep-job/);
  });
  it('points to result-check topic', () => {
    expect(tf).toMatch(/topic_name\s*=\s*google_pubsub_topic.result_check.name/);
  });
});
