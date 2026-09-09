-- ============================================================
-- Agenda do Salao - estrutura do banco (Supabase)
-- Rodar UMA vez em: SQL Editor > New query > cola > Run
--
-- Seguro rodar de novo: tudo usa "if not exists" / "create or replace"
-- e as politicas sao apagadas e recriadas.
--
-- Desenho: cada salao e uma conta. Tudo que a conta grava leva o
-- dono = auth.uid(), e a regra de seguranca (RLS) so deixa cada uma
-- enxergar e mexer no que e dela. Nenhum salao ve o do outro.
--
-- O "id" das linhas e o mesmo id que o aparelho ja usa, para o
-- aparelho e o servidor falarem do mesmo registro sem tradutor.
-- ============================================================

-- ---------- ajustes do salao (uma linha por conta) ----------
create table if not exists public.agenda_config (
  dono          uuid primary key references auth.users(id) on delete cascade,
  nome          text,
  abre          text,
  fecha         text,
  intervalo     integer,
  dias          jsonb not null default '[]'::jsonb,
  atualizado_em timestamptz not null default now()
);

-- ---------- clientes ----------
create table if not exists public.agenda_clientes (
  id            text not null,
  dono          uuid not null references auth.users(id) on delete cascade,
  nome          text not null,
  tel           text,
  obs           text,
  desde         date,
  atualizado_em timestamptz not null default now(),
  primary key (dono, id)
);

-- ---------- tabela de precos ----------
create table if not exists public.agenda_servicos (
  id            text not null,
  dono          uuid not null references auth.users(id) on delete cascade,
  nome          text not null,
  min           integer,
  preco         numeric,
  atualizado_em timestamptz not null default now(),
  primary key (dono, id)
);

-- ---------- quem atende ----------
create table if not exists public.agenda_profissionais (
  id            text not null,
  dono          uuid not null references auth.users(id) on delete cascade,
  nome          text not null,
  atualizado_em timestamptz not null default now(),
  primary key (dono, id)
);

-- ---------- os horarios marcados ----------
create table if not exists public.agenda_horarios (
  id            text not null,
  dono          uuid not null references auth.users(id) on delete cascade,
  data          date not null,
  hora          text not null,
  min           integer,
  cliente_id    text,
  nome          text,
  servico_ids   jsonb not null default '[]'::jsonb,
  prof_id       text,
  valor         numeric,
  status        text,
  obs           text,
  atualizado_em timestamptz not null default now(),
  primary key (dono, id)
);

create index if not exists agenda_horarios_dia on public.agenda_horarios (dono, data);
create index if not exists agenda_clientes_nome on public.agenda_clientes (dono, nome);

-- ---------- quem pode ver o que ----------
-- Sem isto, a chave publica do site daria acesso a tudo de todo mundo.

alter table public.agenda_config        enable row level security;
alter table public.agenda_clientes      enable row level security;
alter table public.agenda_servicos      enable row level security;
alter table public.agenda_profissionais enable row level security;
alter table public.agenda_horarios      enable row level security;

drop policy if exists agenda_config_tudo on public.agenda_config;
create policy agenda_config_tudo on public.agenda_config for all
  using (dono = auth.uid()) with check (dono = auth.uid());

drop policy if exists agenda_clientes_tudo on public.agenda_clientes;
create policy agenda_clientes_tudo on public.agenda_clientes for all
  using (dono = auth.uid()) with check (dono = auth.uid());

drop policy if exists agenda_servicos_tudo on public.agenda_servicos;
create policy agenda_servicos_tudo on public.agenda_servicos for all
  using (dono = auth.uid()) with check (dono = auth.uid());

drop policy if exists agenda_profissionais_tudo on public.agenda_profissionais;
create policy agenda_profissionais_tudo on public.agenda_profissionais for all
  using (dono = auth.uid()) with check (dono = auth.uid());

drop policy if exists agenda_horarios_tudo on public.agenda_horarios;
create policy agenda_horarios_tudo on public.agenda_horarios for all
  using (dono = auth.uid()) with check (dono = auth.uid());

-- ---------- carimbo de hora ----------
-- Usado para decidir quem vence quando o mesmo registro for mudado
-- em dois aparelhos: vale o mais recente.

create or replace function public.agenda_marcar_hora()
returns trigger language plpgsql as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$;

drop trigger if exists hora_agenda_config on public.agenda_config;
create trigger hora_agenda_config before insert or update on public.agenda_config
  for each row execute function public.agenda_marcar_hora();

drop trigger if exists hora_agenda_clientes on public.agenda_clientes;
create trigger hora_agenda_clientes before insert or update on public.agenda_clientes
  for each row execute function public.agenda_marcar_hora();

drop trigger if exists hora_agenda_servicos on public.agenda_servicos;
create trigger hora_agenda_servicos before insert or update on public.agenda_servicos
  for each row execute function public.agenda_marcar_hora();

drop trigger if exists hora_agenda_profissionais on public.agenda_profissionais;
create trigger hora_agenda_profissionais before insert or update on public.agenda_profissionais
  for each row execute function public.agenda_marcar_hora();

drop trigger if exists hora_agenda_horarios on public.agenda_horarios;
create trigger hora_agenda_horarios before insert or update on public.agenda_horarios
  for each row execute function public.agenda_marcar_hora();

-- ------------------------------------------------------------
-- Conferencia depois de rodar (opcional):
--   select tablename from pg_tables where schemaname='public' and tablename like 'agenda_%';
-- Devem aparecer as cinco tabelas.
-- ------------------------------------------------------------
