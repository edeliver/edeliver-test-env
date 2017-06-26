FROM alpine:3.4

ARG ERLANG_VERSION=19.2.1
ARG TEST_SERVER_VERSION=3.1.1
ARG ELIXIR_VERSION=1.4.1

LABEL name="elixir" version=$ELIXIR_VERSION

ARG DISABLED_APPS='megaco wx debugger jinterface orber reltool observer gs et'
ARG ERLANG_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${ERLANG_VERSION}.tar.gz"
ARG TEST_SERVER_URL="http://erlang.org/download/test_server/test_server-${TEST_SERVER_VERSION}.tar.gz"

RUN set -xe \
    && apk --update add --virtual build-dependencies curl ca-certificates build-base autoconf perl ncurses-dev openssl-dev unixodbc-dev tar ncurses openssl unixodbc \
    && curl -fSL -o otp-src.tar.gz "$ERLANG_DOWNLOAD_URL" \
    && curl -fSL -o test-server.tar.gz "$TEST_SERVER_URL" \
    && mkdir -p /usr/src/otp-src \
    && tar -xzf otp-src.tar.gz -C /usr/src/otp-src --strip-components=1 \
    && tar -xzf test-server.tar.gz -C /usr/src/otp-src \
    && rm otp-src.tar.gz \
    && rm test-server.tar.gz \
    && cd /usr/src/otp-src \
    && for lib in ${DISABLED_APPS} ; do touch lib/${lib}/SKIP ; done \
    && ./otp_build autoconf \
    && ./configure \
        --enable-smp-support \
        --enable-m64-build \
        --disable-native-libs \
        --enable-sctp \
        --enable-threads \
        --enable-kernel-poll \
        --disable-hipe \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && find /usr/local -name examples | xargs rm -rf \
    && apk del build-dependencies \
    && ls -d /usr/local/lib/erlang/lib/*/src | xargs rm -rf \
    && rm -rf \
      /opt \
      /var/cache/apk/* \
      /tmp/* \
      /usr/src



RUN set -xe \
    && apk --update add --virtual build-dependencies wget ca-certificates \
    && wget --no-check-certificate https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip \
    && mkdir -p /opt/elixir-${ELIXIR_VERSION}/ \
    && unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/ \
    && rm Precompiled.zip \
    && apk del build-dependencies \
    && rm -rf /etc/ssl \
    && rm -rf \
      /var/cache/apk/* \
      /tmp/*


ENV PATH $PATH:/opt/elixir-${ELIXIR_VERSION}/bin

RUN echo "@community http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk add --update grep coreutils openssh inotify-tools alpine-sdk ncurses ncurses-dev openssl openssl-dev bash git curl docker@community erlang-tools tzdata \
    && rm -rf /var/cache/apk/* \
    && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
    && sed -i s/#PermitEmptyPasswords.*/PermitEmptyPasswords\ yes/ /etc/ssh/sshd_config \
    && echo "root:" | chpasswd \
    && sed -i 's/^\(root:.*:\)\/bin\/ash$/\1\/bin\/bash/g' /etc/passwd

RUN mkdir -p /build && cd build \
  && git clone https://github.com/ferd/erlang-history --depth=1 \
  && cd erlang-history \
  && make install \
  && cd ~ \
  && rm -fr /build/erlang-history


RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa


RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /development

ENV TERM vt100

CMD ["/bin/bash"]