FROM rockylinux/rockylinux:10

# OCI Image Metadata - https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL maintainer="thomas.steiner@ikey.ch"
LABEL org.opencontainers.image.authors="thomas.steiner@ikey.ch"
LABEL org.opencontainers.image.url="https://github.com/thomis/elixir-rocky"
LABEL org.opencontainers.image.source="https://github.com/thomis/elixir-rocky"
LABEL org.opencontainers.image.documentation="https://github.com/thomis/elixir-rocky/blob/main/README.md"
LABEL org.opencontainers.image.vendor="ikey.ch"
# License: This Dockerfile and configurations are MIT. Included software has various licenses.
LABEL org.opencontainers.image.licenses="MIT AND BSD-3-Clause AND Apache-2.0"
LABEL org.opencontainers.image.title="Elixir Development Stack on Rocky Linux"
LABEL org.opencontainers.image.base.name="rockylinux/rockylinux:10"
LABEL org.opencontainers.image.description="Production-ready development stack with latest Erlang, Elixir, Phoenix Framework, Go, and Bun on Rocky Linux 10. Check /versions.json or /versions.txt for installed versions."
LABEL org.opencontainers.image.name="elixir-rocky"
LABEL name="elixir-rocky"
LABEL vendor="ikey.ch"

RUN dnf -y upgrade
RUN dnf -y install procps glibc-langpack-en wget make git automake autoconf openssl-devel ncurses-devel gcc gcc-c++ unzip jq

# UTF8 setting for elixir
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV KERL_CONFIGURE_OPTIONS="--without-javac --without-wx --without-odbc"
ENV ELIXIR=1.18.4-otp-27

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
    printf "%s  %s\n" "$(cat asdf-$VERSION-$ARCH.tar.gz.md5)" "asdf-$VERSION-$ARCH.tar.gz" > asdf-$VERSION-$ARCH.tar.gz.md5 \
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
RUN asdf install elixir $ELIXIR
RUN asdf install golang latest
RUN asdf install bun latest

RUN asdf set --home erlang latest
RUN asdf set --home elixir $ELIXIR
RUN asdf set --home golang latest
RUN asdf set --home bun latest

# Source bashrc to ensure asdf shims are in PATH
RUN source ~/.bashrc && mix local.rebar --force
RUN source ~/.bashrc && mix local.hex --force
RUN source ~/.bashrc && mix archive.install github hexpm/hex branch latest
RUN source ~/.bashrc && mix archive.install hex phx_new --force

RUN source ~/.bashrc && asdf list && mix phx.new --version

# Create version files for reference and output for build process
RUN source ~/.bashrc && \
    ERLANG_VERSION=$(asdf list erlang | grep -v "No versions" | tail -1 | xargs | sed 's/^\*//' ) && \
    ELIXIR_VERSION=$(asdf list elixir | grep -v "No versions" | tail -1 | xargs | sed 's/^\*//') && \
    PHOENIX_VERSION=$(mix phx.new --version | grep "Phoenix installer v" | cut -d'v' -f2) && \
    GO_VERSION=$(asdf list golang | grep -v "No versions" | tail -1 | xargs | sed 's/^\*//') && \
    BUN_VERSION=$(asdf list bun | grep -v "No versions" | tail -1 | xargs | sed 's/^\*//') && \
    ROCKY_VERSION=$(cat /etc/rocky-release | grep -oP '\d+' | head -1) && \
    jq -n \
      --arg erlang "${ERLANG_VERSION}" \
      --arg elixir "${ELIXIR_VERSION}" \
      --arg phoenix "${PHOENIX_VERSION}" \
      --arg go "${GO_VERSION}" \
      --arg bun "${BUN_VERSION}" \
      --arg rocky "${ROCKY_VERSION}" \
      '{erlang: $erlang, elixir: $elixir, phoenix: $phoenix, go: $go, bun: $bun, rocky_linux: $rocky}' > /versions.json && \
    echo "========================================" > /versions.txt && \
    echo "   Elixir Development Stack Versions" >> /versions.txt && \
    echo "========================================" >> /versions.txt && \
    echo "" >> /versions.txt && \
    echo "Runtime & Languages:" >> /versions.txt && \
    echo "  • Erlang/OTP:        ${ERLANG_VERSION}" >> /versions.txt && \
    echo "  • Elixir:            ${ELIXIR_VERSION}" >> /versions.txt && \
    echo "  • Go:                ${GO_VERSION}" >> /versions.txt && \
    echo "" >> /versions.txt && \
    echo "Frameworks & Tools:" >> /versions.txt && \
    echo "  • Phoenix Framework: ${PHOENIX_VERSION}" >> /versions.txt && \
    echo "  • Bun:               ${BUN_VERSION}" >> /versions.txt && \
    echo "" >> /versions.txt && \
    echo "Base System:" >> /versions.txt && \
    echo "  • Rocky Linux:       ${ROCKY_VERSION}" >> /versions.txt && \
    echo "" >> /versions.txt && \
    echo "========================================" >> /versions.txt && \
    echo "=== Version files created ===" && \
    echo "JSON format:" && \
    cat /versions.json && \
    echo -e "\nText format:" && \
    cat /versions.txt && \
    echo "::VERSIONS::$(cat /versions.json | jq -c .)::VERSIONS::"
