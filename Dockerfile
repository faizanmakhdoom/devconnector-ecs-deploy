# === Backend Dockerfile ===
FROM node:18

WORKDIR /app

# Copy only backend files
COPY package*.json ./
RUN npm install

COPY . .

# Expose backend port
EXPOSE 5000

# Start backend
CMD ["node", "server.js"]
