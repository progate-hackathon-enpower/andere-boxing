FROM node:22-slim AS builder

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy proto files for code generation
COPY apps/proto/ apps/proto/

# Copy web app
COPY apps/web/ apps/web/

WORKDIR /app/apps/web

RUN pnpm install --frozen-lockfile
RUN pnpm run proto:gen
RUN pnpm run build

# Runtime stage
FROM node:22-slim

WORKDIR /app

COPY --from=builder /app/apps/web/.output .output

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
