Test and development environment for the erlang / elixir [edeliver](https://github.com/edeliver/edeliver) build / deploy tool.
It uses [docker compose](https://docs.docker.com/compose/overview/) to emulate a build and deploy environment which can be easily adjusted with different host architectures.

To use this project for [edeliver](https://github.com/edeliver/edeliver) development, you need to install [docker](https://docs.docker.com/engine/installation/) and [docker compose](https://docs.docker.com/compose/install/) and:

- start docker compose: `bin/dev-up`
- enter the docker container: `bin/enter-dev`
- accept host key: `ssh root@build true`
- build a release: `mix edeliver build release`
