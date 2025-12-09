FROM node:24-alpine AS build

WORKDIR /app

COPY package*.json ./

# Instalar TODAS as dependências (incluindo devDependencies) para o build
# DevDependencies são necessárias para: TypeScript, Vite, ESLint, etc.
RUN npm ci

# Copy the .env file first to ensure environment variables are available during build
COPY .env* ./

COPY . .

# Build with environment variables from .env file
RUN echo "=== Verificando ambiente ===" && \
  echo "Listando arquivos .env* no diretório:" && \
  ls -la .env* || echo "Nenhum arquivo .env encontrado" && \
  if [ -f .env ]; then \
  echo "✅ Arquivo .env encontrado! Conteúdo:" && \
  echo "--- INÍCIO .env ---" && \
  cat .env && \
  echo "--- FIM .env ---" && \
  echo "Carregando variáveis..." && \
  set -a && . .env && set +a && \
  echo "Variáveis VITE_ disponíveis no ambiente:" && \
  env | grep VITE_ || echo "❌ Nenhuma variável VITE_ encontrada no ambiente!"; \
  else \
  echo "❌ Arquivo .env não encontrado, build sem variáveis específicas"; \
  fi && \
  echo "=== Executando build ===" && \
  npm run build && \
  echo "=== Build concluído ===" && \
  ls -la dist/ && \
  echo "=== Verificando arquivos essenciais ===" && \
  test -f dist/index.html || (echo "❌ ERRO: index.html não encontrado!" && exit 1) && \
  echo "✅ Build validado com sucesso!"

# Comando padrão que lista os arquivos gerados para debug
CMD ["ls", "-la", "/app/dist"]
