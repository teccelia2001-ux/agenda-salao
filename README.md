# Agenda do Salão

Agenda para salão de cabeleireiro: horários do dia, ficha das clientes, tabela de
serviços e fechamento do mês.

Funciona **offline**, gravando primeiro no próprio celular — atender sem sinal nunca
trava. Com a conta criada, tudo também sobe para o servidor, e perder o aparelho
deixa de significar perder a agenda.

## O que ela faz

**Agenda** — calendário do mês com um pontinho por cliente marcada, para bater o olho
e ver o dia cheio. Tocando num dia, aparecem os horários: os marcados e os livres,
na ordem do relógio. Tocar num horário livre já abre o agendamento com a hora
preenchida.

**Agendar** — escolhe a cliente (ou digita o nome de uma nova, que entra sozinha no
cadastro), marca os serviços e a duração e o preço se somam sozinhos. Os dois campos
continuam editáveis, para promoção ou cabelo que demora mais. Se o horário encostar
em outro da mesma profissional, a agenda avisa — mas não impede, porque encaixe é
rotina.

**Cada horário** vira ficha: marcar como atendida ou falta, editar, apagar, e mandar
o lembrete pelo WhatsApp com a mensagem já escrita.

**Clientes** — busca por nome ou telefone, histórico de tudo que a cliente já fez,
quanto gastou, quantas vezes faltou, e observações (a cor da tintura, uma alergia).

**Serviços e profissionais** — a tabela de preços do salão e quem atende. Já vem
preenchida com dez serviços comuns; é só ajustar os preços.

**Pagamento** — cada atendimento pode ser à vista (o normal), **fiado** ou
**parcelado** em até 12 vezes. As parcelas vencem de mês em mês a partir da data
combinada, e o valor quebrado não perde centavo: R$ 100 em 3x vira 33,34 + 33,33 +
33,33. Dia 31 em mês de 30 cai no último dia, não pula para o mês seguinte. Na ficha
do horário, cada parcela tem o botão "recebi".

**Caixa** — fechamento do mês: recebido, fiado em aberto, ainda marcado, ticket
médio, faltas, serviços mais feitos, quanto cada profissional produziu, quem está
devendo (com botão para cobrar no WhatsApp) e as clientes que não aparecem há mais de
60 dias.

O "recebido" é o dinheiro que entrou de verdade: atendimento à vista do mês mais as
parcelas pagas dentro do mês, mesmo de atendimento antigo. O que ficou fiado não entra
ali — vai para "fiado em aberto", que soma a dívida de qualquer mês, com aviso quando
passa do combinado. Agendamento não é dinheiro no bolso, e fiado também não.

**Ajustes** — horário de funcionamento, dias em que o salão abre, de quanto em quanto
tempo mostrar os horários, e a conta do salão.

## Loja

Aba separada do salão, para vender produtos e acessórios. **Nada aqui se mistura com
a agenda**: armazenamento próprio, tabelas próprias no banco, e nenhum valor da loja
entra no Caixa do salão (nem o contrário).

**Classificações** livres, criadas pela dona — vem com "Produtos capilares" e
"Acessórios", e dá para criar quantas quiser (Maquiagem, Bijuteria, o que for). Os
itens aparecem agrupados por classificação, com filtro no topo.

**Itens** com nome, quanto ela pagou, por quanto vende e a quantidade. O lucro por
unidade é calculado enquanto ela digita. Item sem estoque ganha o selo "acabou" e
some o botão de vender.

**Vendas** dão baixa no estoque na hora, e o app não deixa vender mais do que existe.
Cada venda é marcada como **já paga** ou **ficou devendo**, e a pendente tem botão
para cobrar no WhatsApp. Apagar uma venda devolve as unidades ao estoque.

A venda guarda uma foto dos preços do momento — mudar o preço de um item depois não
reescreve o lucro de uma venda já feita.

**Os números do mês:** vendido, lucro, já recebido, pendente (de qualquer mês, porque
dívida não fica presa ao calendário), quanto está parado em estoque e quanto ainda há
de lucro a ganhar nele.

As tabelas da loja vêm de `supabase/02-loja.sql`. Enquanto ele não for rodado, a loja
funciona normalmente no aparelho e a barra avisa "loja só no aparelho" — sem travar a
sincronização da agenda.

## Instalar no celular

Abra o endereço no navegador e escolha **Instalar aplicativo** (Android) ou
**Compartilhar → Adicionar à Tela de Início** (iPhone). A agenda passa a abrir como
aplicativo e funciona sem internet.

## A conta e o servidor

Em **Ajustes → Sua conta**, a dona cria um acesso com usuário e senha. A partir daí a
agenda existe em dois lugares: no celular e no servidor (Supabase, projeto
`myrbsqbwhojomutejtsx`). Perder o celular deixa de significar perder a agenda — no
aparelho novo, basta entrar com o mesmo usuário e tudo desce de volta.

O funcionamento **continua offline**: o app grava no celular primeiro e sobe depois.
Sem sinal, a barra avisa "sem internet — vai quando voltar", e o que ficou pendente
sobe sozinho assim que a conexão volta. Atender no meio do salão sem rede nunca trava.

As exclusões entram numa fila e **só saem dela quando o servidor confirma**. Sem isso,
um `DELETE` recusado seria descartado em silêncio e o registro apagado voltaria na
sincronização seguinte.

Sem conta, o app funciona igual — só no aparelho, como antes.

O banco é montado por `supabase/00-banco-agenda.sql`. Cada conta só enxerga os
próprios dados (regra de segurança por linha). Para o login funcionar, **Confirm
email** precisa ficar desligado no Authentication, porque o usuário vira um e-mail
inventado.

## Onde os dados ficam

Em dois lugares dentro do próprio aparelho, gravados juntos a cada mudança:

- **localStorage** — rápido, sempre pronto na hora de abrir. É também o primeiro que o
  navegador descarta quando o celular fica sem espaço.
- **IndexedDB** — a gaveta grande do aplicativo. O navegador só mexe nela em último
  caso, e nem isso quando o pedido de armazenamento permanente é aceito (o app pede
  sozinho ao abrir; instalar na tela inicial aumenta muito a chance de o Android
  aceitar).

Se o armazenamento rápido for limpo e a gaveta grande ainda tiver a agenda, ela volta
sozinha ao abrir o app, com um aviso na tela. A situação atual aparece em **Ajustes →
Onde a agenda fica guardada**.

**O que nem isso resolve:** desinstalar o aplicativo, formatar, ou perder o celular.
Contra isso serve a conta — por isso o app oferece criá-la depois dos primeiros
agendamentos.

Não há exportação para arquivo: a proteção contra perda é a conta no servidor.

## Arquivos

| Arquivo | O que é |
| --- | --- |
| `index.html` | o aplicativo inteiro: tela, estilo e programa |
| `manifest.webmanifest` | faz o site virar aplicativo instalável |
| `sw.js` | guarda a página para abrir sem internet |
| `icones/` | ícones da tela inicial |
| `supabase/00-banco-agenda.sql` | monta as tabelas do servidor, de uma vez |
| `supabase/01-fiado-e-parcelas.sql` | acrescenta a coluna do pagamento (fiado/parcelas) |
| `supabase/02-loja.sql` | cria as tabelas da loja, separadas das da agenda |

Não há dependências nem build: é um arquivo HTML que roda sozinho, e conversa com o
Supabase direto pela API.
