FROM rockylinux:latest

LABEL maintainer="thomas.steiner@ikey.ch"
LABEL version="1.0.0"

# please update based availability
ARG ASDF_VERSION=0.9.0

RUN dnf -y upgrade
RUN dnf -y install curl glibc-langpack-en wget make git automake autoconf openssl-devel ncurses-devel gcc gcc-c++ unzip python2

# UTF8 setting for elixir
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

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
RUN asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
RUN asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
RUN asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
RUN asdf plugin-add golang https://github.com/kennyp/asdf-golang.git

RUN asdf install erlang latest
RUN asdf install elixir latest
RUN asdf install nodejs latest
RUN asdf install golang latest

RUN asdf global erlang latest
RUN asdf global elixir latest
RUN asdf global nodejs latest
RUN asdf global golang latest

RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix archive.install hex phx_new --force

RUN npm install -g npm@$latest

RUN asdf list && echo "npm $(npm -v)" && mix phx.new --version
