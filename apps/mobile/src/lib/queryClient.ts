import AsyncStorage from '@react-native-async-storage/async-storage';
import NetInfo from '@react-native-community/netinfo';
import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister';
import { focusManager, onlineManager, QueryClient } from '@tanstack/react-query';
import { AppState, Platform } from 'react-native';

import { errorCode } from './errors';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60_000,
      gcTime: 1000 * 60 * 60 * 24, // keep 24h so the persisted cache can serve offline launches
      retry: (count, error) => {
        const code = errorCode(error);
        if (['lesson_locked', 'premium_required', 'not_authenticated', 'quiz_locked'].includes(code)) return false;
        return count < 2;
      },
      networkMode: 'offlineFirst',
    },
    mutations: { networkMode: 'online', retry: 0 },
  },
});

export const queryPersister = createAsyncStoragePersister({
  storage: AsyncStorage,
  key: 'mahorat.query-cache.v1',
  throttleTime: 2000,
});

// Wire React Query to the device's connectivity and app focus.
onlineManager.setEventListener((setOnline) =>
  NetInfo.addEventListener((state) => setOnline(state.isConnected !== false && state.isInternetReachable !== false)),
);

if (Platform.OS !== 'web') {
  AppState.addEventListener('change', (status) => focusManager.setFocused(status === 'active'));
}
