# Set OTOUTO_BOT_API_KEY to your telegram bot api key
# Set ADMIN_ID to your telegram id
# Example: docker run -e OTOUTO_BOT_API_KEY="apikeyhere" -e ADMIN_ID="idhere" jacobamason/otouto
FROM alpine:latest AS build
RUN apk --no-cache add luarocks5.3 lua5.3 lua5.3-dev fortune pcre openssl alpine-sdk pcre-dev openssl-dev ca-certificates
RUN for rock in dkjson lpeg lrexlib-pcre luasec luasocket multipart-post serpent; do /usr/bin/luarocks-5.3 install $rock; done
RUN apk del alpine-sdk pcre-dev openssl-dev
RUN rm -rf /root/.cache

FROM scratch
COPY --from=build / /
COPY . /otouto
WORKDIR /otouto
CMD lua5.3 main.lua

