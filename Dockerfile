FROM node:18-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat git
WORKDIR /app
RUN git clone https://github.com/Ve-Ka/Kitsune.git .
RUN rm -rf .git .gitignore .vscode LICENSE.md README.md
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

FROM base AS builder
ENV NEXT_TELEMETRY_DISABLED 1
WORKDIR /app
COPY --from=deps --link /app/node_modules ./node_modules
COPY --from=deps /app .
RUN yarn build

FROM base AS runner
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV="development"
ENV VERCEL_URL=""
ENV TMDB_ACCESS_KEY=""
WORKDIR /app
RUN \
  addgroup --system --gid 1001 nodejs; \
  adduser --system --uid 1001 nextjs
COPY --from=builder --link --chown=1001:1001 /app .
USER nextjs
EXPOSE 3000

CMD yarn start
