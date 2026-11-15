-- Course review sign-offs.
--
-- A course may only be marked complete (`content_complete = true`) after a subject-matter
-- expert and a native Uzbek speaker have approved it. Approvals are recorded here per course
-- and review kind, edited in Mahorat Studio, and enforced by a trigger on courses — so the
-- “In development” label can never be removed by accident.

create table public.content_reviews (
  course_id uuid not null references public.courses (id) on delete cascade,
  kind text not null check (kind in ('expert', 'native_uz', 'native_ru')),
  status text not null default 'pending' check (status in ('pending', 'changes_requested', 'approved')),
  reviewer_id uuid references public.profiles (id) on delete set null,
  notes text check (char_length(notes) <= 4000),
  updated_at timestamptz not null default now(),
  primary key (course_id, kind)
);

comment on table public.content_reviews is
  'Expert and native-speaker sign-offs per course; approved expert + native_uz reviews are required for content_complete.';

alter table public.content_reviews enable row level security;

create policy "reviews: staff read" on public.content_reviews for select to authenticated
  using (private.is_staff());
create policy "reviews: editors write" on public.content_reviews for insert to authenticated
  with check (private.is_editor());
create policy "reviews: editors update" on public.content_reviews for update to authenticated
  using (private.is_editor()) with check (private.is_editor());

revoke all on public.content_reviews from anon;
revoke delete, truncate on public.content_reviews from authenticated;

-- Who signed off and when is recorded by the server, not the client.
create or replace function private.stamp_review()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  if private.is_client_role() then
    new.reviewer_id := (select auth.uid());
  end if;
  return new;
end $$;

create trigger stamp_review before insert or update on public.content_reviews
  for each row execute function private.stamp_review();
create trigger audit after insert or update or delete on public.content_reviews
  for each row execute function private.audit();

-- A course is “complete” only with approved expert and native-Uzbek reviews.
create or replace function private.guard_content_complete()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.content_complete and (tg_op = 'INSERT' or not old.content_complete) then
    if (select count(*) from public.content_reviews r
        where r.course_id = new.id and r.kind in ('expert', 'native_uz') and r.status = 'approved') < 2 then
      raise exception 'course_not_reviewed' using errcode = '23514',
        hint = 'Approve the expert and native Uzbek reviews before marking the course complete.';
    end if;
  end if;
  return new;
end $$;

create trigger guard_content_complete before insert or update of content_complete on public.courses
  for each row execute function private.guard_content_complete();
