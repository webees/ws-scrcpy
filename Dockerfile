FROM node:16 AS builder
COPY . /app
WORKDIR /app
RUN ls
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin
RUN npm install -g node-gyp
RUN npm install
RUN npm run dist
RUN npm prune --production

FROM node:16-alpine
ENV LANG C.UTF-8
COPY --from=builder /app/dist /dist
COPY --from=builder /app/node_modules /node_modules
COPY adbconnect /adbconnect
COPY entrypoint.sh /entrypoint.sh
RUN apk add --no-cache coreutils android-tools bash nmap \
    && chmod +x /adbconnect \
    && chmod +x /entrypoint.sh
EXPOSE 8000
ENTRYPOINT [ "/entrypoint.sh" ]
