import Config

config :http_api, port: 4000

import_config "#{Mix.env()}.exs"
