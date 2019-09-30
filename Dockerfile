# ---- Build Stage ----
FROM elixir:1.9.1-alpine AS build

# The environment to build with
ENV MIX_ENV=prod

# Install the necessary build tools
RUN mix local.hex --force
RUN mix local.rebar --force

# By convention, /opt is typically used for applications
WORKDIR /opt/app

# Copy our app source code into the build container
COPY . .

# Fetch the app dependencies, compile them and assemble the release
RUN mix deps.get
RUN mix deps.compile
RUN mix release

# ---- Release Stage ----
FROM alpine

# Exposes this port from the docker container to the host machine
EXPOSE 4000

# Install openssl
RUN apk update
RUN apk add --no-cache openssl ncurses-libs

# Copy over the release artifact from the previous image
WORKDIR /opt/app
COPY --from=build /opt/app/_build/prod/rel/http_api .

# Create a non root user
RUN adduser -h . -D app
RUN chown -R app: .
USER app

# The command to run when the image starts up
CMD ["bin/http_api", "start"]
