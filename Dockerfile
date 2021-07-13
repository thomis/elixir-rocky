FROM centos:8

LABEL maintainer="thomas.steiner@ikey.ch"
LABEL version="1.0.0"

# please update based on your needs
ARG ASDF_VERSION=0.8.1
ARG ERLANG_VERSION=24.0.3
ARG ELIXIR_VERSION=1.12.2-otp-24
ARG PHOENIX_VERSION=1.5.9
ARG NODEJS_VERSION=16.4.2
ARG NPM_VERSION=7.18.1
ARG GOLANG_VERSION=1.16.6

RUN yum update -y
RUN yum -y install glibc-langpack-en wget make git automake autoconf openssl-devel ncurses-devel gcc gcc-c++ unzip python2

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

# erlang, elixir, nodejs, go
RUN asdf plugin-add erlang
RUN asdf plugin-add elixir
RUN asdf plugin-add nodejs
RUN asdf plugin-add golang

RUN asdf install erlang ${ERLANG_VERSION}
RUN asdf install elixir ${ELIXIR_VERSION}
RUN bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
RUN asdf install nodejs ${NODEJS_VERSION}
RUN asdf install golang ${GOLANG_VERSION}

RUN asdf global erlang ${ERLANG_VERSION}
RUN asdf global elixir ${ELIXIR_VERSION}
RUN asdf global nodejs ${NODEJS_VERSION}
RUN asdf global golang ${GOLANG_VERSION}

RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix archive.install hex phx_new ${PHOENIX_VERSION} --force

RUN npm install -g npm@${NPM_VERSION}
