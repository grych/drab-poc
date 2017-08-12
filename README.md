# Drab Proof of Concept

## Accessing DOM objects from the server side.

This is the source code for the [Drab Proof of Concept](https://tg.pl/drab) page.

Please check the [Drab Source](https://github.com/grych/drab).

## Installation
First, have Erlang and Elixir installed. Then install hex

    mix local.hex

Download and install Drab-Poc:

    git clone git@github.com:grych/drab-poc.git
    cd drab-poc
    mix deps.get

Get node.js and npm. Then install brunch packages:

    npm install && node node_modules/brunch/bin/brunch build

If developing a production version, create `config/prod.secret.exs` (it is not under git) and compile all:

    MIX_ENV=prod mix compile
    node_modules/brunch/bin/brunch build --production
    MIX_ENV=prod mix phoenix.digest

Start the server

    mix phoenix.server

On production

    PORT=6503 MIX_ENV=prod mix phoenix.server

## Author
This software is written by Tomek 'Grych' Gryszkiewicz. Do not hesitate to contact me at grych@tg.pl or visit [my web page](http://www.tg.pl).
