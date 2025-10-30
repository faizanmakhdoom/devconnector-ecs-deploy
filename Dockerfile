# -----------------------------
# Stage 1 - Build React client
# -----------------------------
FROM node:18 AS build
WORKDIR /usr/src/app

# ✅ Fix OpenSSL issue for Node 17+
ENV NODE_OPTIONS=--openssl-legacy-provider

# Copy and install frontend dependencies
COPY client/package*.json ./client/
RUN cd client && npm install

# Copy all source code
COPY . .

# Build React frontend
RUN cd client && npm run build

# -----------------------------
# Stage 2 - Build backend + serve
# -----------------------------
FROM node:18
WORKDIR /usr/src/app

# Copy backend package.json and install production dependencies
COPY package*.json ./
RUN npm install --production

# Copy entire project
COPY . .

# Copy prebuilt frontend from build stage
COPY --from=build /usr/src/app/client/build ./client/build

# -----------------------------
# Environment & Runtime Config
# -----------------------------
ENV NODE_ENV=production
ENV PORT=5000
# ⚠️ Hardcoded only for demo — ECS overrides these via task definition
ENV MONGO_URI=mongodb://mongodb:27017/devconnector
ENV JWT_SECRET=supersecretkey

# Expose backend API port
EXPOSE 5000

# Start server
CMD ["npm", "start"]
