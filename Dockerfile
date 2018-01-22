# Set OTOUTO_BOT_API_KEY to your telegram bot api key
# Set ADMIN_ID to your telegram id
# Example: docker run -e OTOUTO_BOT_API_KEY="apikeyhere" -e ADMIN_ID="idhere" jacobamason/otouto
FROM alpine:3.7

RUN apk --no-cache add \
    curl gcc libc-dev pcre-dev libressl-dev \
    lua5.3 lua5.3-dev luarocks5.3 && \
    luarocks-5.3 install dkjson && \
    luarocks-5.3 install lpeg && \
    luarocks-5.3 install lrexlib-pcre && \
    luarocks-5.3 install luasec && \
    luarocks-5.3 install luasocket && \
    luarocks-5.3 install multipart-post && \
    apk del curl gcc libc-dev pcre-dev libressl-dev lua5.3-dev

COPY . /otouto
WORKDIR /otouto
CMD ./launch.sh

