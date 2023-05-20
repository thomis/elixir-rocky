FROM rockylinux/rockylinux:9.2

LABEL maintainer="thomas.steiner@ikey.ch"
LABEL version="1.0.0"

# please update based availability
ARG ASDF_VERSION=0.11.2
ARG NODEJS_VERSION=latest

RUN dnf -y upgrade
RUN dnf -y install procps glibc-langpack-en wget make git automake autoconf openssl-devel ncurses-devel gcc gcc-c++ unzip

# UTF8 setting for elixir
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV KERL_CONFIGURE_OPTIONS "--without-javac --without-wx --without-odbc"

# use bash as default shell
# and define login shell which sources .bashrc with every command
SHELL ["/bin/bash", "--login", "-c"]

# asdf
RUN git config --global advice.detachedHead false
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v${ASDF_VERSION}
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
RUN echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
RUN asdf update

# erlang, elixir, nodejs, go
RUN asdf plugin add erlang
RUN asdf plugin add elixir
RUN asdf plugin add nodejs
RUN asdf plugin add golang

RUN asdf install erlang latest
RUN asdf install elixir latest
RUN asdf install nodejs ${NODEJS_VERSION}
RUN asdf install golang latest

RUN asdf global erlang latest
RUN asdf global elixir latest
RUN asdf global nodejs ${NODEJS_VERSION}
RUN asdf global golang latest

RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix archive.install hex phx_new --force

RUN npm install -g npm@$latest

RUN asdf list && echo "npm $(npm -v)" && mix phx.new --version

