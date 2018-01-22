# Set OTOUTO_BOT_API_KEY to your telegram bot api key
# Set ADMIN_ID to your telegram id
FROM alpine:3.7

RUN apk update && apk add \
    curl gcc libc-dev pcre-dev libressl-dev \
    lua5.3 lua5.3-dev luarocks5.3

RUN luarocks-5.3 install dkjson && \
    luarocks-5.3 install lpeg && \
    luarocks-5.3 install lrexlib-pcre && \
    luarocks-5.3 install luasec && \
    luarocks-5.3 install luasocket && \
    luarocks-5.3 install multipart-post

COPY . /otouto
WORKDIR /otouto
CMD ./launch.sh

