import AsyncStorage from '@react-native-async-storage/async-storage';
import * as aesjs from 'aes-js';
import * as Crypto from 'expo-crypto';
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

/**
 * Supabase session storage for native platforms.
 *
 * Sessions exceed SecureStore's ~2 KB value limit, so we keep a random AES-256 key in the
 * OS keychain/keystore (SecureStore) and store only AES-CTR ciphertext in AsyncStorage.
 * Without the key — which never leaves the secure enclave-backed store — the stored blob
 * is useless. On web, the browser's localStorage is used (supabase-js default).
 */
const KEY_PREFIX = 'mahorat.sk.';

async function encrypt(storageKey: string, value: string) {
  const key = Crypto.getRandomBytes(32);
  const cipher = new aesjs.ModeOfOperation.ctr(key, new aesjs.Counter(1));
  const encrypted = cipher.encrypt(aesjs.utils.utf8.toBytes(value));
  await SecureStore.setItemAsync(KEY_PREFIX + storageKey, aesjs.utils.hex.fromBytes(key), {
    keychainAccessible: SecureStore.AFTER_FIRST_UNLOCK,
  });
  return aesjs.utils.hex.fromBytes(encrypted);
}

async function decrypt(storageKey: string, value: string) {
  const keyHex = await SecureStore.getItemAsync(KEY_PREFIX + storageKey);
  if (!keyHex) return null;
  const cipher = new aesjs.ModeOfOperation.ctr(aesjs.utils.hex.toBytes(keyHex), new aesjs.Counter(1));
  return aesjs.utils.utf8.fromBytes(cipher.decrypt(aesjs.utils.hex.toBytes(value)));
}

const nativeStorage = {
  async getItem(key: string) {
    const encrypted = await AsyncStorage.getItem(key);
    if (!encrypted) return null;
    try {
      return await decrypt(key, encrypted);
    } catch {
      return null;
    }
  },
  async setItem(key: string, value: string) {
    await AsyncStorage.setItem(key, await encrypt(key, value));
  },
  async removeItem(key: string) {
    await AsyncStorage.removeItem(key);
    await SecureStore.deleteItemAsync(KEY_PREFIX + key);
  },
};

const webStorage = {
  getItem: async (key: string) => (typeof localStorage === 'undefined' ? null : localStorage.getItem(key)),
  setItem: async (key: string, value: string) => {
    if (typeof localStorage !== 'undefined') localStorage.setItem(key, value);
  },
  removeItem: async (key: string) => {
    if (typeof localStorage !== 'undefined') localStorage.removeItem(key);
  },
};

export const sessionStorage = Platform.OS === 'web' ? webStorage : nativeStorage;
