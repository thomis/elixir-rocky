FROM rockylinux/rockylinux:9.4

LABEL maintainer="thomas.steiner@ikey.ch"
LABEL version="1.0.0"

RUN dnf -y upgrade
RUN dnf -y install procps glibc-langpack-en wget make git automake autoconf openssl-devel ncurses-devel gcc gcc-c++ unzip jq

# UTF8 setting for elixir
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV KERL_CONFIGURE_OPTIONS="--without-javac --without-wx --without-odbc"

# use bash as default shell
# and define login shell which sources .bashrc with every command
SHELL ["/bin/bash", "--login", "-c"]

RUN git config --global advice.detachedHead false

# asdf
WORKDIR /root

# Dynamically detect architecture and download the appropriate binary
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        ARCH=linux-amd64; \
    elif [ "$ARCH" = "aarch64" ]; then \
        ARCH=linux-arm64; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    REPO="asdf-vm/asdf" && \
    VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name') && \
    curl -LO "https://github.com/$REPO/releases/download/$VERSION/asdf-$VERSION-$ARCH.tar.gz" && \
    curl -LO "https://github.com/$REPO/releases/download/$VERSION/asdf-$VERSION-$ARCH.tar.gz.md5" && \
    echo "$(cat asdf-$VERSION-$ARCH.tar.gz.md5) asdf-$VERSION-$ARCH.tar.gz" > asdf-$VERSION-$ARCH.tar.gz.md5 && \
    md5sum -c "asdf-$VERSION-$ARCH.tar.gz.md5" && \
    rm "asdf-$VERSION-$ARCH.tar.gz.md5" && \
    tar -xzvf "asdf-$VERSION-$ARCH.tar.gz" && \
    mv asdf /usr/local/bin && \
    rm "asdf-$VERSION-$ARCH.tar.gz"

RUN echo -e '\nexport PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' >> ~/.bashrc

# erlang, elixir, nodejs, go
RUN asdf plugin add erlang
RUN asdf plugin add elixir
RUN asdf plugin add golang
RUN asdf plugin add bun

RUN asdf install erlang latest
RUN asdf install elixir 1.18.3-otp-27
RUN asdf install golang latest
RUN asdf install bun latest

RUN asdf set --home erlang latest
RUN asdf set --home elixir 1.18.3-otp-27
RUN asdf set --home golang latest
RUN asdf set --home bun latest

RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix archive.install github hexpm/hex branch latest
RUN mix archive.install hex phx_new --force

RUN asdf list && mix phx.new --version
