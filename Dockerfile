# Set OTOUTO_BOT_API_KEY to your telegram bot api key
# Set ADMIN_ID to your telegram id
FROM ubuntu:xenial

RUN apt-get update && apt-get install -y \
    sudo \
    build-essential \
    git \
    libssl-dev \
    libc6 \
    libpcre3-dev \
    lsb-release \
    curl \
    unzip

COPY . /otouto

WORKDIR /otouto

RUN ./install-dependencies.sh

CMD ./launch.sh

