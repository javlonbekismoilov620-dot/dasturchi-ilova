import * as Linking from 'expo-linking';
import { Platform } from 'react-native';
import Purchases, { type PurchasesPackage } from 'react-native-purchases';

import { env, isDemoMode } from './env';

/**
 * Store billing through RevenueCat, which wraps Apple In-App Purchase (StoreKit) and
 * Google Play Billing — purchases never bypass platform payment rules. Entitlements
 * are granted server-side: RevenueCat → `revenuecat-webhook` edge function →
 * `subscriptions` table → `private.has_premium()`. The app never unlocks content on
 * its own based on a client-side receipt.
 */
const apiKey = Platform.select({ ios: env.revenueCatAppleKey, android: env.revenueCatGoogleKey, default: '' });

export const billingAvailable = !isDemoMode && Platform.OS !== 'web' && !!apiKey;

let configuredFor: string | null = null;

export async function ensureBilling(userId: string) {
  if (!billingAvailable) return false;
  if (configuredFor === userId) return true;
  if (!configuredFor) Purchases.configure({ apiKey: apiKey!, appUserID: userId });
  else await Purchases.logIn(userId);
  configuredFor = userId;
  return true;
}

export interface StorePackage {
  identifier: string;
  priceString: string;
  raw: PurchasesPackage;
}

export async function loadPackages(userId: string): Promise<StorePackage[]> {
  if (!(await ensureBilling(userId))) return [];
  const offerings = await Purchases.getOfferings();
  return (offerings.current?.availablePackages ?? []).map((p) => ({ identifier: p.identifier, priceString: p.product.priceString, raw: p }));
}

/** Returns true when the purchase completed (false when the user cancelled). */
export async function purchase(pkg: StorePackage): Promise<boolean> {
  try {
    await Purchases.purchasePackage(pkg.raw);
    return true;
  } catch (e) {
    if (e && typeof e === 'object' && 'userCancelled' in e && (e as { userCancelled: boolean }).userCancelled) return false;
    throw e;
  }
}

export async function restore(userId: string): Promise<boolean> {
  if (!(await ensureBilling(userId))) return false;
  const info = await Purchases.restorePurchases();
  return Object.keys(info.entitlements.active).length > 0;
}

export async function signOutBilling() {
  if (billingAvailable && configuredFor) {
    await Purchases.logOut().catch(() => {});
    configuredFor = null;
  }
}

export function openManageSubscriptions() {
  const url = Platform.OS === 'ios' ? 'https://apps.apple.com/account/subscriptions' : 'https://play.google.com/store/account/subscriptions';
  return Linking.openURL(url);
}
