const path = require('path');
process.env.FIREBASE_RULES = path.resolve(__dirname, '../firebase.rules');
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  setupFiles: ['<rootDir>/jest.setup.ts'],
};
