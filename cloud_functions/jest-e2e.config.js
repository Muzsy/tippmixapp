module.exports = {
  preset: 'ts-jest',
  testMatch: ['**/test/e2e.test.ts'],
  testEnvironment: 'node',
  globals: {
    'ts-jest': {
      tsconfig: 'tsconfig.json'
    }
  }
};
