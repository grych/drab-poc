#!/bin/bash
export PORT=6503
export MIX_ENV=prod
elixir --detached -S mix phoenix.server

