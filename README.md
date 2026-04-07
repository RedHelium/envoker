# envoker

`envoker` is a small Gleam helper for reading environment variables through
[`envoy`](https://hex.pm/packages/envoy) with a typed API.

## Features

- required and optional readers
- built-in parsing for `String`, `Int`, `Float`, and `Bool`
- defaults for missing and empty values
- structured errors:
  - `MissingFieldError`
  - `EmptyFieldError`
  - `ParseFieldError` (includes source value and optional details)
- declarative config loader with error accumulation

## Installation

```sh
gleam add envoker
```

## Basic example

```gleam
import envoker
import gleam/option

pub fn load_config() {
  let assert Ok(host) =
    envoker.read_required_string("HOST", option.None)

  let assert Ok(port) =
    envoker.read_required_int("PORT", option.Some(8080))

  let assert Ok(debug) =
    envoker.read_optional_bool("DEBUG", option.Some(False))

  #(host, port, debug)
}
```

`String` values are always trimmed with `string.trim`, and `Bool` parsing is
case-insensitive for `true` and `false`.

## Detailed parse errors

By default, `read_*_with_parser` expects a parser of type
`fn(String) -> Result(a, Nil)` and returns parse errors without a textual reason.

If you want parser-provided details, use `read_*_with_parser_detailed` with
`Result(a, String)`:

```gleam
import envoker
import envoker/error
import gleam/option

pub fn parse_color(value: String) -> Result(String, String) {
  case value {
    "red" -> Ok("red")
    _ -> Error("only red is allowed")
  }
}

pub fn load_color() {
  let result =
    envoker.read_required_with_parser_detailed(
      "COLOR",
      option.None,
      "Color",
      parse_color,
    )

  case result {
    Ok(color) -> Ok(color)
    Error(error.ParseFieldError(_, _, _, _)) -> result
    Error(_) -> result
  }
}
```

## Declarative config loading with accumulated errors

The `envoker/config` module lets you define config fields as a list and load
them in one pass while collecting all errors:

```gleam
import envoker/config
import gleam/option

type AppConfig {
  AppConfig(host: String, port: Int, debug: option.Option(Bool))
}

fn set_host(config: AppConfig, host: String) -> AppConfig {
  AppConfig(..config, host: host)
}

fn set_port(config: AppConfig, port: Int) -> AppConfig {
  AppConfig(..config, port: port)
}

fn set_debug(config: AppConfig, debug: option.Option(Bool)) -> AppConfig {
  AppConfig(..config, debug: debug)
}

pub fn load() {
  config.load(
    AppConfig(host: "", port: 0, debug: option.None),
    [
      config.required_string("HOST", option.None, set_host),
      config.required_int("PORT", option.None, set_port),
      config.optional_bool("DEBUG", option.None, set_debug),
    ],
  )
}
```

Result:
- `Ok(config)` when all fields are loaded successfully
- `Error(List(EnvFieldError))` when there are errors (no fail-fast)

## Development

```sh
gleam test
gleam check
gleam format
```
