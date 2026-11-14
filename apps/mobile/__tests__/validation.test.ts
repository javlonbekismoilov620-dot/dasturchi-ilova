import { describe, it, expect } from '@jest/globals';
import { errorCode, errorMessageKey } from '@/lib/errors';
import { isHttpUrl, isStrongPassword, isValidEmail, normalizeAnswer } from '@/lib/validation';

describe('validation', () => {
  it('validates emails', () => {
    expect(isValidEmail(' aziza@example.uz ')).toBe(true);
    expect(isValidEmail('aziza@example')).toBe(false);
    expect(isValidEmail('no spaces@x.com')).toBe(false);
  });
  it('matches the server password policy (8+ chars, letters and digits)', () => {
    expect(isStrongPassword('Mahorat-2026')).toBe(true);
    expect(isStrongPassword('short1')).toBe(false);
    expect(isStrongPassword('onlyletters')).toBe(false);
  });
  it('accepts only http(s) links', () => {
    expect(isHttpUrl('https://github.com/aziza/site')).toBe(true);
    expect(isHttpUrl('javascript:alert(1)')).toBe(false);
  });
  it('normalises short answers like the database', () => {
    expect(normalizeAnswer('  MP4 ')).toBe('mp4');
    expect(normalizeAnswer('a   b')).toBe('a b');
  });
});

describe('error mapping', () => {
  it('maps RPC error codes to messages', () => {
    expect(errorCode(new Error('lesson_locked'))).toBe('lesson_locked');
    expect(errorMessageKey(new Error('premium_required'))).toBe('errors.premiumRequired');
    expect(errorMessageKey(new Error('Failed to fetch'))).toBe('errors.network');
    expect(errorMessageKey(new Error('weird'))).toBe('errors.generic');
  });
});
