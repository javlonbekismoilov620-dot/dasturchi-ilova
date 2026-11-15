import AsyncStorage from '@react-native-async-storage/async-storage';
import { Directory, File, Paths } from 'expo-file-system';
import { Platform } from 'react-native';

import type { Resource } from '@/data/types';

/**
 * Offline lesson resources. Files live in the app's private document directory (not
 * shared storage, so no storage permission is needed) and are listed in an index so
 * the Downloads screen works without a connection.
 */
const INDEX_KEY = 'mahorat.downloads.v1';

export interface DownloadedResource {
  id: string;
  title: string;
  kind: Resource['kind'];
  courseId: string;
  lessonId: string | null;
  uri: string;
  sizeBytes: number;
  downloadedAt: string;
}

const dir = () => new Directory(Paths.document, 'resources');

export async function listDownloads(): Promise<DownloadedResource[]> {
  const raw = await AsyncStorage.getItem(INDEX_KEY);
  return raw ? (JSON.parse(raw) as DownloadedResource[]) : [];
}

async function saveIndex(items: DownloadedResource[]) {
  await AsyncStorage.setItem(INDEX_KEY, JSON.stringify(items));
}

export async function downloadResource(resource: Resource, url: string): Promise<DownloadedResource> {
  if (Platform.OS === 'web') throw new Error('Offline downloads are available in the mobile app.');
  const d = dir();
  if (!d.exists) d.create({ intermediates: true });
  const ext = (resource.storage_path ?? url).split('?')[0].split('.').pop()?.slice(0, 8) ?? 'bin';
  const target = new File(d, `${resource.id}.${ext}`);
  if (target.exists) target.delete();
  const file = await File.downloadFileAsync(url, target);
  const item: DownloadedResource = {
    id: resource.id,
    title: resource.title,
    kind: resource.kind,
    courseId: resource.course_id,
    lessonId: resource.lesson_id,
    uri: file.uri,
    sizeBytes: file.size ?? resource.size_bytes ?? 0,
    downloadedAt: new Date().toISOString(),
  };
  const items = (await listDownloads()).filter((x) => x.id !== resource.id);
  await saveIndex([item, ...items]);
  return item;
}

export async function removeDownload(id: string) {
  const items = await listDownloads();
  const item = items.find((x) => x.id === id);
  if (item) {
    try {
      const f = new File(item.uri);
      if (f.exists) f.delete();
    } catch {
      // already gone
    }
  }
  await saveIndex(items.filter((x) => x.id !== id));
}

export async function clearDownloads() {
  if (Platform.OS !== 'web') {
    const d = dir();
    if (d.exists) d.delete();
  }
  await saveIndex([]);
}

export function formatBytes(n: number) {
  if (n < 1024) return `${n} B`;
  if (n < 1024 ** 2) return `${(n / 1024).toFixed(0)} KB`;
  if (n < 1024 ** 3) return `${(n / 1024 ** 2).toFixed(1)} MB`;
  return `${(n / 1024 ** 3).toFixed(2)} GB`;
}
