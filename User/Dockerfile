FROM node:22-alpine

WORKDIR /app

COPY package*.json .

# production dependencies only
RUN npm install --omit=dev

COPY . .

# switch to non-root user
RUN chown -R node:node /app
USER node

EXPOSE 3001

CMD [ "node", "server.js" ]
