# Build Stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build:ssr

# Run Stage
FROM node:20-alpine
WORKDIR /app

RUN apk add --no-cache wget

COPY --from=build /app/package*.json ./
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules

EXPOSE 4000

CMD ["npm", "run", "serve:ssr"]
