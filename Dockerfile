FROM node:20-alpine AS deps
WORKDIR /app
COPY src/package*.json ./
RUN npm ci --frozen-lockfile --omit=dev

FROM node:20-alpine AS runtime
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY src/ ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:3000/ || exit 1
CMD ["node", "index.js"]