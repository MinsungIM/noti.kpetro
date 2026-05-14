# syntax=docker/dockerfile:1.7
# noti.kpetro: Node 20 단일 컨테이너 (Python 의존 없음, 가벼움)

# === Stage 1: Node 빌드 ===
FROM node:20-bookworm-slim AS node-builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

COPY . .
RUN npm run build

# === Stage 2: 런타임 ===
FROM node:20-bookworm-slim AS runtime
WORKDIR /app

ENV NODE_ENV=production

# 한글 폰트 + TLS 인증서
RUN apt-get update && apt-get install -y --no-install-recommends \
      fonts-noto-cjk \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Node 프로덕션 의존성만
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev

# 빌드 결과
COPY --from=node-builder /app/dist ./dist

# boot 스크립트 + DB migration SQL
COPY migrations ./migrations
COPY startup.mjs ./
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Non-root 사용자
RUN useradd -r -u 10001 -g nogroup app && chown -R app:nogroup /app
USER app

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:5000/').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))" || exit 1

ENTRYPOINT ["./entrypoint.sh"]
