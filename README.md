# SlackinEx [![Slackin.ex badge](https://slackinex.herokuapp.com/badge.svg)](https://slackinex.herokuapp.com/)

[Slackin](https://github.com/rauchg/slackin/) clone in Elixir. At the moment we reuse parts of HTML & CSS.

[Live demo](https://slackinex.herokuapp.com/)

## Features

- Can work without Javascript;
- Uses Phoenix channels if available for live stat updates/rpc;
- Badge;
- Network status alerts;
- Memory-friendly users statistics;
- Respects Slack rate-limiting.

## Technical Highlights

- Uses [fuse](https://github.com/jlouis/fuse) circuit breaker for detecting network/slack api recurring failures;
- Caching is done using [run-time code generation](https://github.com/deadtrickster/smerl);
- Live team members stat (retrieved with users.list) implemented using [jsx](https://github.com/talentdeficit/jsx) evented streams.

## Configuration

Slackin.ex can be configured via standard phoenix configuration files
or environment variables.

```elixir
config :slackin_ex,
  slack_subdomain: "slackinex",
  logo_url: "https://i.imgur.com/bq7UPJ6.png",
  contact_email: "slackinex@gmail.com",
  contact_name: "slackin.ex Team"
```

Or using environment variables:

```
SLACK_SUBDOMAIN=slackinex ...
```

Environment variable name is upcased application config key.

All available options:

Slack related:

- `:slack_subdomain` (required)
- `:slack_apitoken` (required)
- `:slack_channels` {not used yet)
- `:slack_team_name` (optional)
- `:slack_update_interval` (defaults to 30_000. lower values could result in rate-limit)

Invite page:

- `:logo_url` (optional)
- `:coc_url` (optional, not used yet)
- `:contact_email` (required)
- `:contant_name` (defaults to contact_email)

Badge:

- `:badge_accent_color` (#4e2a8e)
- `:badge_title_background_color` (#555)
- `:badge_text_color` (#fff)
- `:badge_text_shadow_color` (#010101)
- `:badge_title` ("slack")
- `:badge_pad` (8)
- `:badge_sep` (4)

Only three absolutely required options:

- `:slack_subdomain`
- `:slack_apitoken`
- `:contact_email`

## Deployment

### Release via Distillery 

Can be configured using prod.exs and optional prod.secret.exs(gitignored).
Environment variables still work too.

```
## Create release:
MIX_ENV=prod mix release

## Run:
PORT=4000 _build/prod/rel/slackin_ex/bin/slackin_ex console

```

**Note** Do not forget to check url config of endpoint!

### Heroku

Put you configuration in prod.exs and api token in environment (config var):

```
heroku config:set SLACK_APITOKEN=<your token>
heroku config:set SECRET_KEY_BASE=<key base>
```

And deploy with Heroku git as usual.

### Docker

Run the latest image:

```
docker run -e SLACK_SUBDOMAIN=<> -e SLACK_APITOKEN=<> -e CONTACT_EMAIL=<> \
           -p 4000:4000 --rm deadtrickster/slackin_ex foreground
```

Or build your own:

```
./bin/build-docker-release.sh TAG
```

## License
MIT
