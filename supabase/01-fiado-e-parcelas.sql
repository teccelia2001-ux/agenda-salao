-- ============================================================
-- Fiado e parcelas
-- Rodar em: Supabase > SQL Editor > New query > cola > Run
--
-- Guarda como o atendimento foi pago. Fica tudo numa coluna so,
-- em jsonb, porque a forma de pagamento pertence ao atendimento e
-- nunca e consultada sozinha:
--
--   null                          -> pagou a vista, nada devendo
--   { "tipo": "fiado",     "parcelas": [ ... 1 ... ] }
--   { "tipo": "parcelado", "parcelas": [ ... N ... ] }
--
-- e cada parcela e
--   { "n": 1, "valor": 60, "vence": "2026-10-08", "pago": false, "pagoEm": null }
--
-- Seguro rodar mais de uma vez.
-- ============================================================

alter table public.agenda_horarios
  add column if not exists pagamento jsonb;

-- ------------------------------------------------------------
-- Conferencia depois de rodar (opcional):
--   select column_name from information_schema.columns
--    where table_name = 'agenda_horarios' and column_name = 'pagamento';
-- Deve devolver uma linha.
-- ------------------------------------------------------------
