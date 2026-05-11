# Stage 1: Building application
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json .

RUN npm install

COPY . .

RUN npm run build

# # # # # # # # # # # # # # # # # # 

# Stage 2: Serve static files
FROM node:22-alpine

WORKDIR /app

RUN npm install -g serve

COPY --from=build /app/dist ./dist

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]

# if will be used with nginx 
# Stage 2: Nginx as reverse proxy 
#  FROM nginx:alpine

#  COPY --from=build /app/dist /usr/share/nginx/html

# # # for SPA (Single Page App) routing
#  COPY nginx.conf /etc/nginx/conf.d/default.conf 

#  EXPOSE 80

#  CMD [ "nginx", "-g", "daemon off;"]



