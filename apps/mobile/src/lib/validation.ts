/** Client-side validation (the database re-validates everything with CHECK constraints). */
export const isValidEmail = (v: string) => /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v.trim());
export const isStrongPassword = (v: string) => v.length >= 8 && /[A-Za-z]/.test(v) && /\d/.test(v);
export const isHttpUrl = (v: string) => /^https?:\/\/[^\s]+\.[^\s]+/.test(v.trim());
export const normalizeAnswer = (v: string) => v.trim().toLowerCase().replace(/\s+/g, ' ');
