#!/bin/bash
PORT=6503 MIX_ENV=prod elixir --detached -S mix phoenix.server
PORT=6504 MIX_ENV=prod elixir --detached -S mix phoenix.server

