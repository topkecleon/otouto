# Set OTOUTO_BOT_API_KEY to your telegram bot api key
# Set ADMIN_ID to your telegram id
# Example: docker run -e OTOUTO_BOT_API_KEY="apikeyhere" -e ADMIN_ID="idhere" jacobamason/otouto
FROM alpine:3.7

RUN apk --no-cache add --virtual build-deps \
    curl gcc libc-dev pcre-dev libressl-dev && \
    apk --no-cache add lua5.3 lua5.3-dev luarocks5.3 && \
    luarocks-5.3 install dkjson && \
    luarocks-5.3 install lpeg && \
    luarocks-5.3 install lrexlib-pcre && \
    luarocks-5.3 install luasec && \
    luarocks-5.3 install luasocket && \
    luarocks-5.3 install multipart-post && \
    apk del build-deps

COPY . /otouto
WORKDIR /otouto
CMD ./launch.sh

