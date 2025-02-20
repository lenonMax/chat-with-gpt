FROM node:19-bullseye-slim AS build

RUN apt-get update && \
    apt-get install -y \
    git

# Set working directory
WORKDIR /app

# Copy package.json and tsconfig.json
COPY ./app/package.json ./
COPY ./app/tsconfig.json ./

# Install Node.js dependencies
RUN yarn install --network-timeout 1000000

COPY ./app/vite.config.js ./

# Copy public, and src directories
COPY ./app/public ./public
COPY ./app/src ./src
COPY ./app/index.html ./

# Set environment variables
ENV NODE_ENV=production

# Build the application
RUN yarn run build

FROM node:19-bullseye-slim AS server

# Set the working directory
WORKDIR /app

COPY ./server/package.json ./server/tsconfig.json ./

# Install Node.js dependencies from package.json
RUN yarn install --network-timeout 1000000

# Copy the rest of the application code into the working directory
COPY ./server/src ./src

RUN CI=true sh -c "cd /app && yarn run start && rm -rf data"

COPY --from=build /app/build /app/public

LABEL org.opencontainers.image.source="https://github.com/lenonMax/chat-with-gpt"
ENV PORT 3000

CMD ["yarn", "run", "start"]
