# -----------------------------
# Stage 1 - Build React client
# -----------------------------
FROM node:18 as build
WORKDIR /usr/src/app

# Copy frontend package files
COPY client/package*.json ./client/
RUN cd client && npm install

# Copy entire project and build frontend
COPY . .
RUN cd client && npm run build

# -----------------------------
# Stage 2 - Build backend + serve
# -----------------------------
FROM node:18
WORKDIR /usr/src/app

# Copy backend package.json and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy all project files
COPY . .

# Copy built frontend from previous stage
COPY --from=build /usr/src/app/client/build ./client/build

# Expose backend port
EXPOSE 5000

# Environment variables (will be overridden by ECS)
ENV NODE_ENV=production
ENV PORT=5000
ENV MONGO_URI=mongodb://mongodb:27017/devconnector
ENV JWT_SECRET=supersecretkey

CMD ["npm", "start"]
