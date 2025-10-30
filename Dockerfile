# -----------------------------
# Stage 1 - Build React client
# -----------------------------
FROM node:18 as build
WORKDIR /usr/src/app

# Copy frontend dependencies and install
COPY client/package*.json ./client/
RUN cd client && npm install

# Copy the full project and build the frontend
COPY . .
RUN cd client && npm run build

# -----------------------------
# Stage 2 - Backend runtime
# -----------------------------
FROM node:18
WORKDIR /usr/src/app

# Copy backend package.json and install dependencies (including config)
COPY package*.json ./
RUN npm install --production

# Copy backend code, models, routes, and config
COPY . .

# Copy built React app from previous stage
COPY --from=build /usr/src/app/client/build ./client/build

# Expose the backend port
EXPOSE 5000

# Environment variables (ECS overrides these)
ENV NODE_ENV=production
ENV PORT=5000
ENV MONGO_URI=mongodb://mongodb:27017/devconnector
ENV JWT_SECRET=supersecretkey

# Start the server
CMD ["npm", "start"]
