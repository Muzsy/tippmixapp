import { HttpsError } from 'firebase-functions/v2/https';

const publishMessage = jest.fn().mockResolvedValue('1');
const topic = jest.fn(() => ({ publishMessage }));
jest.mock('@google-cloud/pubsub', () => ({
  PubSub: jest.fn(() => ({ topic })),
}));
const { force_finalizer } = require('../src/force_finalizer');

describe('force_finalizer', () => {
  it('publishes final-sweep message for admin', async () => {
    const result = await (force_finalizer as any).run({
      auth: { uid: 'u1', token: { admin: true } },
      data: {},
    });
    expect(result).toEqual({ status: 'OK' });
    const call = publishMessage.mock.calls[0][0];
    const payload = JSON.parse(call.data.toString());
    expect(payload.type).toBe('final-sweep');
    expect(payload.requestedBy).toBe('u1');
    expect(typeof payload.ts).toBe('number');
  });

  it('rejects non-admin', async () => {
    await expect(
      (force_finalizer as any).run({ auth: { uid: 'u1', token: {} }, data: {} }),
    ).rejects.toBeInstanceOf(HttpsError);
  });
});
