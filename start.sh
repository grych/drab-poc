#!/bin/bash
rm logs/1.pid
# rm logs/2.pid
PORT=6503 MIX_ENV=prod elixir --detached -e "File.write! 'logs/1.pid', :os.getpid" --name n1@127.0.0.1 --erl "-config sys.config" -S mix phx.server
PORT=6504 MIX_ENV=prod elixir --detached -e "File.write! 'logs/2.pid', :os.getpid" --name n2@127.0.0.1 --erl "-config sys.config" -S mix phx.server

