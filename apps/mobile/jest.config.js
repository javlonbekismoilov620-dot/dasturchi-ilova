/** Unit tests for pure logic (i18n, learning helpers, validation, data contracts). */
module.exports = {
  preset: 'jest-expo',
  testMatch: ['<rootDir>/__tests__/**/*.test.ts?(x)'],
  moduleNameMapper: { '^@/(.*)$': '<rootDir>/src/$1' },
  setupFiles: ['<rootDir>/__tests__/setup.ts'],
};
