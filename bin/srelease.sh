#!/bin/bash

mix local.hex --force
mix local.rebar --force
MIX_ENV=prod mix release
