#!/bin/bash

mix local.hex --force
mix local.rebar --force
rm -rf _build/prod
MIX_ENV=prod mix release --no-tar
