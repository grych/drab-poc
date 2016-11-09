#!/usr/bin/env bash
git pull
mix deps.get
npm install && node_modules/brunch/bin/brunch build --production
MIX_ENV=prod mix compile
MIX_ENV=prod mix phoenix.digest
