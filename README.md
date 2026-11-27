# JUAN — Meu Treino ABC 17.0

Aplicativo pessoal de musculação com catálogo de exercícios, fichas A/B/C/ABS, diário de treino e sincronização entre dispositivos.

## Publicação

O aplicativo é publicado gratuitamente pelo GitHub Pages:
https://vascaino-arch.github.io/vasco-meu-treino-abc/

## Ativar login e sincronização (Supabase)

1. Crie um projeto em https://supabase.com/dashboard usando um e-mail que você consiga acessar.
2. Escolha a região South America (São Paulo), se disponível.
3. No projeto, abra **SQL Editor** → **New query**, cole todo o conteúdo de `supabase-setup.sql` e execute.
4. Em **Project Settings → API**, copie o **Project URL** e a chave **publishable** (ou a chave legada **anon public**).
5. Edite `supabase-config.js` neste repositório e preencha os campos `url` e `anonKey`. Essas duas informações são próprias para uso público no cliente. **Nunca use `service_role`, secret key ou senha do banco no navegador ou neste arquivo.**
6. Em **Authentication → URL Configuration**, defina a Site URL e adicione esta URL à lista de Redirect URLs:
   `https://vascaino-arch.github.io/vasco-meu-treino-abc/`
7. Mantenha o provedor **Email** habilitado. Crie a conta pelo painel de sincronização do aplicativo e confirme o e-mail, se o Supabase solicitar.

## Como funciona a sincronização

- Use o mesmo e-mail e senha em todos os aparelhos.
- Fichas, cargas, equipamentos, ciclos e histórico são sincronizados pela nuvem.
- As alterações são salvas localmente primeiro e enviadas automaticamente quando houver internet.
- Realtime atualiza os outros aparelhos; ao voltar ao app ou à internet, ele também consulta a versão mais recente.
- Se dois aparelhos alterarem dados ao mesmo tempo, o aplicativo pede que você escolha qual versão manter, evitando sobrescrita silenciosa.
- A primeira conexão envia os dados locais se ainda não houver cópia na nuvem. Em um aparelho novo sem dados locais, baixa a cópia da nuvem automaticamente.
- O backup JSON continua disponível como proteção adicional.

## Segurança e privacidade

- O repositório e o site são públicos, mas as linhas da tabela têm RLS e cada usuário autenticado só pode ler a própria linha.
- A gravação é feita por uma função que usa o ID obtido da sessão autenticada e valida conflitos de versão.
- A chave publishable/anon pode aparecer no código público; a proteção real depende das políticas RLS e da função SQL instaladas.
- Nunca publique a chave `service_role`, uma secret key ou a senha do banco.
- O banco contém os registros de treino associados ao ID da conta autenticada.

## Arquivos importantes

- `index.html` e `app.html`: aplicativo.
- `supabase-setup.sql`: tabela, RLS, função segura de gravação e Realtime.
- `supabase-config.js`: URL e chave pública do projeto.
- `sw.js`: cache do app e suporte offline básico.

A hospedagem GitHub Pages e o uso do Supabase dependem dos limites e condições dos planos vigentes.
