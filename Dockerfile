FROM node:alpine
RUN apk add --no-cache git
WORKDIR /app
RUN git clone https://github.com/Dovakiin0/Kitsune.git
WORKDIR /app/Kitsune
RUN find .  -type f -exec sed -i 's/\r$//' {} +
RUN yarn install
RUN yarn build
EXPOSE 3000
CMD yarn start
