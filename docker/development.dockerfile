FROM elixir:1.4.4



RUN apt-get update \
    && apt-get install -y --no-install-recommends ssh \
    && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
    && sed -i s/#PermitEmptyPasswords.*/PermitEmptyPasswords\ yes/ /etc/ssh/sshd_config \
    && mkdir /var/run/sshd \
    && chmod 0755 /var/run/sshd \
    && ssh-keygen -t rsa -b 4096 -N "" -f /root/.ssh/id_rsa \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys



RUN mkdir -p /build && cd build \
  && git clone https://github.com/ferd/erlang-history --depth=1 \
  && cd erlang-history \
  && make install \
  && cd ~ \
  && rm -fr /build/erlang-history


RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /development

ENV TERM vt100

CMD ["/bin/bash"]