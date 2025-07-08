import { db } from '../src/lib/firebase';

async function migrate() {
  const usersSnap = await db.collection('users').get();
  for (const doc of usersSnap.docs) {
    const data = doc.data();
    const update: Record<string, any> = {};

    if (!('uid' in data)) update.uid = doc.id;
    if (!('email' in data)) update.email = '';
    if (!('displayName' in data)) update.displayName = '';
    if (!('nickname' in data)) update.nickname = '';
    if (!('avatarUrl' in data)) update.avatarUrl = 'assets/avatar/default_avatar.png';
    if (!('isPrivate' in data)) update.isPrivate = false;
    if (!('fieldVisibility' in data)) update.fieldVisibility = {};
    if (!('notificationPreferences' in data)) update.notificationPreferences = {};
    if (!('twoFactorEnabled' in data)) update.twoFactorEnabled = false;
    if (!('onboardingCompleted' in data)) update.onboardingCompleted = false;
    if (data.schemaVersion !== 2) update.schemaVersion = 2;

    if (Object.keys(update).length > 0) {
      await doc.ref.update(update);
    }
  }
}

migrate()
  .then(() => {
    console.log('✅ User schema migration completed.');
    process.exit(0);
  })
  .catch((err) => {
    console.error('❌ Migration failed:', err);
    process.exit(1);
  });
