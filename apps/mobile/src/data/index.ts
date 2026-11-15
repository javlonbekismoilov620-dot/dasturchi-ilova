import { isDemoMode } from '@/lib/env';

import type { LearningApi } from './api';
import { createDemoApi } from './demo/demoApi';
import { createSupabaseApi } from './supabaseApi';

/** The active data source. Screens never import an implementation directly. */
export const api: LearningApi = isDemoMode ? createDemoApi() : createSupabaseApi();

export type { LearningApi } from './api';
