# PRODUCTION DOCKERFILE - Frontend Angular SSR
# Multi-stage build for optimal image size and security

FROM node:20-alpine as builder

ENV NODE_ENV=build

USER node

WORKDIR /home/node

# Copy dependency files
COPY --chown=node:node package*.json ./

# Install all dependencies
RUN npm ci

# Copy source code
COPY --chown=node:node . .

# Build SSR application
RUN npm run build:ssr

# Remove dev dependencies
RUN npm prune --omit=dev

# ---
# Production stage - Minimal runtime image
FROM node:20-alpine

# Install curl for healthcheck
RUN apk add --no-cache curl

ENV NODE_ENV=production

USER node

WORKDIR /home/node

# Copy only necessary files from builder
COPY --from=builder --chown=node:node /home/node/package*.json ./
COPY --from=builder --chown=node:node /home/node/node_modules/ ./node_modules/
COPY --from=builder --chown=node:node /home/node/dist/ ./dist/

# Expose SSR port
EXPOSE 4000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:4000 || exit 1

# Start SSR server
CMD ["node", "dist/server/main.js"]
