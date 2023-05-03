FROM node:16-alpine AS BUILD_IMAGE
RUN apk add --no-cache git curl
RUN curl -sf https://gobinaries.com/tj/node-prune | sh
WORKDIR /app
RUN git clone https://github.com/Dovakiin0/Kitsune.git
WORKDIR /app/Kitsune
RUN find .  -type f -exec sed -i 's/\r$//' {} +
RUN yarn install --frozen-lockfile
RUN yarn add sharp
RUN yarn build
RUN rm -rf .git .gitignore .next/cache .vscode LICENSE.md README.md
RUN node-prune node_modules
RUN chmod -R 777 .

FROM node:16-alpine
RUN mkdir /app
RUN mkdir /app/Kitsune
WORKDIR /app/Kitsune
COPY --from=BUILD_IMAGE /app/Kitsune .
EXPOSE 3000
CMD yarn start
