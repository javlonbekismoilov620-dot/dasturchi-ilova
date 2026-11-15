// Creates role-specific accounts on the LOCAL Supabase stack for development/QA.
//   node supabase/scripts/create-dev-users.mjs
// Refuses to run against anything but localhost.
import { execSync } from 'node:child_process';
import { createClient } from '@supabase/supabase-js';

const status = JSON.parse(execSync('npx supabase status -o json', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }));
if (!/^http:\/\/(127\.0\.0\.1|localhost)/.test(status.API_URL)) throw new Error('Refusing to create dev users on a non-local project.');
const admin = createClient(status.API_URL, status.SERVICE_ROLE_KEY, { auth: { persistSession: false } });
const password = process.env.DEV_PASSWORD ?? 'Mahorat-dev-2026';

const users = [
  { email: 'admin@mahorat.local', name: 'Studio Admin', roles: ['admin'] },
  { email: 'editor@mahorat.local', name: 'Content Editor', roles: ['editor'] },
  { email: 'instructor@mahorat.local', name: 'Course Instructor', roles: ['instructor'] },
  { email: 'student@mahorat.local', name: 'Demo Student', roles: [] },
];

for (const u of users) {
  const { data: list } = await admin.auth.admin.listUsers({ perPage: 1000 });
  let user = list.users.find((x) => x.email === u.email);
  if (!user) {
    const { data, error } = await admin.auth.admin.createUser({ email: u.email, password, email_confirm: true, user_metadata: { full_name: u.name } });
    if (error) throw error;
    user = data.user;
  }
  for (const role of u.roles) await admin.from('user_roles').upsert({ user_id: user.id, role }, { onConflict: 'user_id,role' });
  if (u.roles.includes('instructor')) {
    await admin.from('instructors').upsert({ slug: 'course-instructor', name: u.name, headline: 'Instructor (local dev account)', profile_id: user.id }, { onConflict: 'slug' });
  }
  console.log(`${u.email.padEnd(26)} ${u.roles.join(', ') || 'student'}`);
}
console.log(`password: ${password}`);
