# === Frontend Dockerfile ===
# Stage 1: Build React App
FROM node:18 AS build

WORKDIR /app
COPY package*.json ./
RUN npm install

# 🩹 Fix Webpack build error with Node 18
ENV NODE_OPTIONS=--openssl-legacy-provider

COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:latest
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
