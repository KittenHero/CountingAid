FROM node:16.9.1-alpine3.11

EXPOSE 5000
ENV HOST=0.0.0.0
RUN mkdir -p /run/vite/cache
RUN chown -R node:985 /run/vite/cache
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD npm start
