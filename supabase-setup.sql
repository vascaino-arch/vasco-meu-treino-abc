-- JUAN — Meu Treino ABC 17.0
-- Execute este arquivo inteiro no Supabase > SQL Editor > New query.
-- Os usuários só podem ler/gravar a própria linha. Não use service_role no navegador.

create table if not exists public.juan_training_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.juan_training_data enable row level security;

grant select on public.juan_training_data to authenticated;

drop policy if exists "Read own JUAN training data" on public.juan_training_data;
create policy "Read own JUAN training data"
on public.juan_training_data
for select
to authenticated
using ((select auth.uid()) = user_id);

create or replace function public.save_juan_training_data(
  p_payload jsonb,
  p_expected_updated_at timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_current timestamptz;
begin
  if v_uid is null then
    raise exception 'Authentication required';
  end if;

  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception 'Invalid training payload';
  end if;

  select updated_at
    into v_current
    from public.juan_training_data
    where user_id = v_uid
    for update;

  if not found then
    if p_expected_updated_at is not null then
      return jsonb_build_object('saved', false, 'updated_at', null);
    end if;

    begin
      insert into public.juan_training_data(user_id, payload, updated_at)
      values (v_uid, p_payload, clock_timestamp())
      returning updated_at into v_current;
      return jsonb_build_object('saved', true, 'updated_at', v_current);
    exception when unique_violation then
      select updated_at into v_current
      from public.juan_training_data
      where user_id = v_uid;
      return jsonb_build_object('saved', false, 'updated_at', v_current);
    end;
  end if;

  if p_expected_updated_at is distinct from v_current then
    return jsonb_build_object('saved', false, 'updated_at', v_current);
  end if;

  update public.juan_training_data
     set payload = p_payload,
         updated_at = clock_timestamp()
   where user_id = v_uid
   returning updated_at into v_current;

  return jsonb_build_object('saved', true, 'updated_at', v_current);
end;
$$;

revoke all on function public.save_juan_training_data(jsonb, timestamptz) from public, anon;
grant execute on function public.save_juan_training_data(jsonb, timestamptz) to authenticated;

-- Ativa eventos Realtime para que outros aparelhos recebam atualizações.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'juan_training_data'
  ) then
    alter publication supabase_realtime add table public.juan_training_data;
  end if;
end $$;
