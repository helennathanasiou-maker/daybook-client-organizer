create table if not exists public.clients (
  user_id uuid not null references auth.users (id) on delete cascade,
  id text not null,
  name text not null check (char_length(name) between 1 and 70),
  email text not null check (char_length(email) <= 120),
  service text not null check (char_length(service) between 1 and 70),
  note text not null default '' check (char_length(note) <= 250),
  created_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.appointments (
  user_id uuid not null references auth.users (id) on delete cascade,
  id text not null,
  client_id text not null,
  service text not null check (char_length(service) between 1 and 70),
  appointment_date date not null,
  appointment_time time not null,
  duration_minutes integer not null check (duration_minutes in (30, 60, 90, 120)),
  created_at timestamptz not null default now(),
  primary key (user_id, id),
  foreign key (user_id, client_id) references public.clients (user_id, id) on delete cascade
);

create table if not exists public.followups (
  user_id uuid not null references auth.users (id) on delete cascade,
  id text not null,
  client_id text not null,
  title text not null check (char_length(title) between 1 and 100),
  due_date date not null,
  done boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (user_id, id),
  foreign key (user_id, client_id) references public.clients (user_id, id) on delete cascade
);

create index if not exists appointments_user_date_idx
  on public.appointments (user_id, appointment_date, appointment_time);
create index if not exists followups_user_due_date_idx
  on public.followups (user_id, done, due_date);

alter table public.clients enable row level security;
alter table public.appointments enable row level security;
alter table public.followups enable row level security;

drop policy if exists "Users manage their own clients" on public.clients;
create policy "Users manage their own clients"
  on public.clients for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their own appointments" on public.appointments;
create policy "Users manage their own appointments"
  on public.appointments for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their own followups" on public.followups;
create policy "Users manage their own followups"
  on public.followups for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant select, insert, update, delete on public.clients to authenticated;
grant select, insert, update, delete on public.appointments to authenticated;
grant select, insert, update, delete on public.followups to authenticated;
