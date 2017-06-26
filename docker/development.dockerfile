FROM elixir:1.4.4



RUN apt-get update \
    && apt-get install -y --no-install-recommends ssh \
    && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
    && sed -i s/#PermitEmptyPasswords.*/PermitEmptyPasswords\ yes/ /etc/ssh/sshd_config



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