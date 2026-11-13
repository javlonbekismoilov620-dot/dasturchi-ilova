// In-app account deletion (App Store Review Guideline 5.1.1(v), Google Play policy).
// Removes the user's uploaded files, then the auth user; every learner table cascades
// from public.profiles → auth.users, so progress, notes and certificates go with it.
import { adminClient, corsHeaders, json, requireUser } from '../_shared/http.ts';

async function removeFolder(bucket: string, prefix: string) {
  const storage = adminClient().storage.from(bucket);
  const stack = [prefix];
  while (stack.length) {
    const dir = stack.pop()!;
    const { data, error } = await storage.list(dir, { limit: 1000 });
    if (error || !data?.length) continue;
    const files = data.filter((f) => f.id).map((f) => `${dir}/${f.name}`);
    data.filter((f) => !f.id).forEach((d) => stack.push(`${dir}/${d.name}`));
    if (files.length) await storage.remove(files);
  }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  const user = await requireUser(req);
  if (!user) return json({ error: 'not_authenticated' }, 401);

  try {
    await removeFolder('avatars', user.id);
    await removeFolder('submissions', user.id);
    const { error } = await adminClient().auth.admin.deleteUser(user.id);
    if (error) throw error;
    return json({ deleted: true });
  } catch (e) {
    console.error('delete-account failed', user.id, e instanceof Error ? e.message : e);
    return json({ error: 'delete_failed' }, 500);
  }
});
