FROM node:16 as build

WORKDIR /tmp/app

# Install dependencies
COPY package*.json ./

RUN npm ci --silent

# Copy source
COPY . .

# Build
RUN npm run build

# -------------------
FROM node:16-alpine as run

WORKDIR /app

# Copy source
COPY .env .
COPY public ./public
COPY package*.json ./

# Copy built files
COPY --from=build /tmp/app/dist .

# Build and cleanup
# ENV NODE_ENV=production
RUN npm ci --silent

# Start server
# CMD ["node", "./node_modules/moleculer/bin/moleculer-runner.js", "-e"]
CMD ["npm", "start"]

