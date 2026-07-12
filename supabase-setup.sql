-- =============================================================
-- TravAI Pro — database-setup voor Supabase
-- Plak dit volledige script in: Supabase > SQL Editor > Run
-- =============================================================

-- ---------- Tabellen ----------
create table if not exists public.trips (
  id          uuid primary key default gen_random_uuid(),
  owner       uuid not null references auth.users(id) on delete cascade default auth.uid(),
  name        text not null,
  dest        text default '',
  start_date  date,
  end_date    date,
  emoji       text default '✈️',
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz default now()
);

create table if not exists public.trip_members (
  trip_id  uuid references public.trips(id) on delete cascade,
  user_id  uuid references auth.users(id) on delete cascade,
  email    text,
  role     text not null default 'viewer',
  primary key (trip_id, user_id)
);

create table if not exists public.trip_invites (
  id         uuid primary key default gen_random_uuid(),
  trip_id    uuid references public.trips(id) on delete cascade,
  email      text not null,
  role       text not null default 'viewer',
  created_at timestamptz default now()
);

-- ---------- Hulpfuncties (voorkomen recursieve RLS) ----------
create or replace function public.is_trip_owner(t uuid)
returns boolean language sql security definer set search_path = public as
$$ select exists (select 1 from trips where id = t and owner = auth.uid()); $$;

create or replace function public.is_trip_member(t uuid)
returns boolean language sql security definer set search_path = public as
$$ select exists (select 1 from trip_members where trip_id = t and user_id = auth.uid()); $$;

-- Uitnodigingen claimen na inloggen (op basis van e-mailadres)
create or replace function public.claim_invites()
returns integer language plpgsql security definer set search_path = public as
$$
declare n integer;
begin
  insert into trip_members (trip_id, user_id, email, role)
  select i.trip_id, auth.uid(), lower(auth.jwt()->>'email'), i.role
  from trip_invites i
  where lower(i.email) = lower(auth.jwt()->>'email')
  on conflict do nothing;
  get diagnostics n = row_count;
  delete from trip_invites where lower(email) = lower(auth.jwt()->>'email');
  return n;
end;
$$;

grant execute on function public.is_trip_owner(uuid)  to authenticated;
grant execute on function public.is_trip_member(uuid) to authenticated;
grant execute on function public.claim_invites()      to authenticated;

-- ---------- Row Level Security ----------
alter table public.trips        enable row level security;
alter table public.trip_members enable row level security;
alter table public.trip_invites enable row level security;

-- trips: eigenaar = alles; leden = alleen lezen
drop policy if exists trips_select on public.trips;
create policy trips_select on public.trips for select
  using (owner = auth.uid() or public.is_trip_member(id));

drop policy if exists trips_insert on public.trips;
create policy trips_insert on public.trips for insert
  with check (owner = auth.uid());

drop policy if exists trips_update on public.trips;
create policy trips_update on public.trips for update
  using (owner = auth.uid()) with check (owner = auth.uid());

drop policy if exists trips_delete on public.trips;
create policy trips_delete on public.trips for delete
  using (owner = auth.uid());

-- trip_members: zichtbaar voor eigenaar en het lid zelf;
-- eigenaar kan verwijderen, lid kan zichzelf verwijderen (reis verlaten)
drop policy if exists members_select on public.trip_members;
create policy members_select on public.trip_members for select
  using (user_id = auth.uid() or public.is_trip_owner(trip_id));

drop policy if exists members_delete on public.trip_members;
create policy members_delete on public.trip_members for delete
  using (user_id = auth.uid() or public.is_trip_owner(trip_id));

-- trip_invites: alleen de eigenaar beheert uitnodigingen
drop policy if exists invites_all on public.trip_invites;
create policy invites_all on public.trip_invites for all
  using (public.is_trip_owner(trip_id)) with check (public.is_trip_owner(trip_id));

-- Klaar! Ga nu terug naar de handleiding, stap 3.
