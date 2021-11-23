use Mix.Config

config :eia, :database, pool_size: 3, folder: "./persist"
config :eia, port: 5454

import_config "#{Mix.env()}.exs"
