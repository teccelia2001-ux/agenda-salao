-- ============================================================
-- Loja virtual - tabelas proprias, separadas da agenda
-- Rodar em: Supabase > SQL Editor > New query > cola > Run
--
-- A loja e independente: nenhuma tabela daqui se cruza com as da
-- agenda. O unico ponto em comum e o dono (a mesma conta do salao),
-- que e o que garante que uma pessoa so ve a propria loja.
--
-- Seguro rodar mais de uma vez.
-- ============================================================

-- ---------- classificacao dos itens (o que a dona quiser) ----------
-- Ex.: "Produtos capilares", "Acessorios", "Maquiagem".
create table if not exists public.loja_categorias (
  id            text not null,
  dono          uuid not null references auth.users(id) on delete cascade,
  nome          text not null,
  ordem         integer,
  atualizado_em timestamptz not null default now(),
  primary key (dono, id)
);

-- ---------- os itens a venda ----------
-- custo  = quanto ela pagou no item (usado para o lucro)
-- preco  = por quanto ela vende
-- estoque= quantas unidades tem
create table if not exists public.loja_produtos (
  id            text not null,
  dono          uuid not null references auth.users(id) on delete cascade,
  categoria_id  text,
  nome          text not null,
  custo         numeric,
  preco         numeric,
  estoque       numeric,
  obs           text,
  atualizado_em timestamptz not null default now(),
  primary key (dono, id)
);

-- ---------- as vendas ----------
-- itens guarda a foto do momento da venda (nome, quantidade, preco e
-- custo de cada item). Assim, mudar o preco do produto depois nao
-- reescreve o lucro de uma venda ja feita.
create table if not exists public.loja_vendas (
  id            text not null,
  dono          uuid not null references auth.users(id) on delete cascade,
  data          date not null,
  itens         jsonb not null default '[]'::jsonb,
  total         numeric,
  custo         numeric,
  cliente_id    text,
  nome          text,
  pago          boolean not null default true,
  pago_em       date,
  obs           text,
  atualizado_em timestamptz not null default now(),
  primary key (dono, id)
);

create index if not exists loja_produtos_cat on public.loja_produtos (dono, categoria_id);
create index if not exists loja_vendas_data on public.loja_vendas (dono, data);

-- ---------- quem pode ver o que ----------

alter table public.loja_categorias enable row level security;
alter table public.loja_produtos   enable row level security;
alter table public.loja_vendas     enable row level security;

drop policy if exists loja_categorias_tudo on public.loja_categorias;
create policy loja_categorias_tudo on public.loja_categorias for all
  using (dono = auth.uid()) with check (dono = auth.uid());

drop policy if exists loja_produtos_tudo on public.loja_produtos;
create policy loja_produtos_tudo on public.loja_produtos for all
  using (dono = auth.uid()) with check (dono = auth.uid());

drop policy if exists loja_vendas_tudo on public.loja_vendas;
create policy loja_vendas_tudo on public.loja_vendas for all
  using (dono = auth.uid()) with check (dono = auth.uid());

-- ---------- carimbo de hora ----------

drop trigger if exists hora_loja_categorias on public.loja_categorias;
create trigger hora_loja_categorias before insert or update on public.loja_categorias
  for each row execute function public.agenda_marcar_hora();

drop trigger if exists hora_loja_produtos on public.loja_produtos;
create trigger hora_loja_produtos before insert or update on public.loja_produtos
  for each row execute function public.agenda_marcar_hora();

drop trigger if exists hora_loja_vendas on public.loja_vendas;
create trigger hora_loja_vendas before insert or update on public.loja_vendas
  for each row execute function public.agenda_marcar_hora();

-- ------------------------------------------------------------
-- Conferencia depois de rodar (opcional):
--   select tablename from pg_tables
--    where schemaname='public' and tablename like 'loja_%';
-- Devem aparecer as tres tabelas.
-- ------------------------------------------------------------
