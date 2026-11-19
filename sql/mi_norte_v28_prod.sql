-- Producción V28: tablas nuevas y aisladas. No modifica las tablas V10 ni las de QA.
begin;
create table if not exists public.mi_norte_v28_prod_states(
 user_id uuid primary key references auth.users(id) on delete cascade,
 storage jsonb not null default '{}'::jsonb,
 revision bigint not null default 0,
 updated_at timestamptz not null default now()
);
create table if not exists public.mi_norte_v28_prod_commits(
 user_id uuid not null references auth.users(id) on delete cascade,
 mutation_id uuid not null,
 body jsonb not null,
 revision bigint not null,
 previous_storage jsonb not null,
 created_at timestamptz not null default now(),
 primary key(user_id,mutation_id)
);
alter table public.mi_norte_v28_prod_states enable row level security;
alter table public.mi_norte_v28_prod_commits enable row level security;
revoke all on public.mi_norte_v28_prod_states,public.mi_norte_v28_prod_commits from anon,authenticated;
create or replace function public.mi_norte_v28_prod_read()
returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=auth.uid(); r jsonb;
begin
 if u is null then raise exception 'Sesión requerida' using errcode='42501'; end if;
 select jsonb_build_object('revision',revision,'storage',storage) into r
 from public.mi_norte_v28_prod_states where user_id=u;
 return r;
end; $$;
create or replace function public.mi_norte_v28_prod_save(next_storage jsonb,expected_revision bigint,mutation_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=auth.uid(); r public.mi_norte_v28_prod_states; prior public.mi_norte_v28_prod_commits;
 raw_state text; parsed_state jsonb; next_revision bigint; body jsonb;
begin
 if u is null then raise exception 'Sesión requerida' using errcode='42501'; end if;
 if mutation_id is null or jsonb_typeof(next_storage) is distinct from 'object' then raise exception 'Estado inválido'; end if;
 raw_state:=next_storage->>'mi-norte-v28-personal-vacia-estado-v1';
 if raw_state is null then raise exception 'Falta estado V28'; end if;
 begin parsed_state:=raw_state::jsonb; exception when others then raise exception 'Estado V28 ilegible'; end;
 if jsonb_typeof(parsed_state->'entries') is distinct from 'array' or jsonb_typeof(parsed_state->'closures') is distinct from 'array' then raise exception 'Estado V28 incompleto'; end if;
 if octet_length(next_storage::text)>20000000 then raise exception 'Estado demasiado grande'; end if;
 body:=jsonb_build_object('storage',next_storage);
 select * into prior from public.mi_norte_v28_prod_commits c where c.user_id=u and c.mutation_id=mi_norte_v28_prod_save.mutation_id;
 if found then
  if prior.body is distinct from body then raise exception 'Identificador de guardado reutilizado' using errcode='40001'; end if;
  return jsonb_build_object('revision',prior.revision);
 end if;
 select * into r from public.mi_norte_v28_prod_states s where s.user_id=u for update;
 if not found then
  if expected_revision<>0 then raise exception 'Conflicto de revisión' using errcode='40001'; end if;
  insert into public.mi_norte_v28_prod_states(user_id,storage,revision) values(u,next_storage,1);
  insert into public.mi_norte_v28_prod_commits(user_id,mutation_id,body,revision,previous_storage) values(u,mutation_id,body,1,'{}'::jsonb);
  return jsonb_build_object('revision',1);
 end if;
 if r.revision is distinct from expected_revision then raise exception 'Conflicto de revisión' using errcode='40001'; end if;
 next_revision:=r.revision+1;
 insert into public.mi_norte_v28_prod_commits(user_id,mutation_id,body,revision,previous_storage) values(u,mutation_id,body,next_revision,r.storage);
 update public.mi_norte_v28_prod_states set storage=next_storage,revision=next_revision,updated_at=now() where user_id=u;
 return jsonb_build_object('revision',next_revision);
end; $$;
revoke all on function public.mi_norte_v28_prod_read(),public.mi_norte_v28_prod_save(jsonb,bigint,uuid) from public,anon;
grant execute on function public.mi_norte_v28_prod_read(),public.mi_norte_v28_prod_save(jsonb,bigint,uuid) to authenticated;
commit;

