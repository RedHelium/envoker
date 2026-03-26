# envoker

`envoker` is a small Gleam helper for reading environment variables through
[`envoy`](https://hex.pm/packages/envoy) with a typed API.

It provides:

- required and optional readers
- built-in parsing for `String`, `Int`, `Float`, and `Bool`
- defaults for missing or empty values
- structured errors for missing, empty, and invalid fields

## Installation

```sh
gleam add envoker
```

## Example

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

`String` values are trimmed before validation and return, and `Bool` parsing is
case-insensitive for `true` and `false`.

## Development

```sh
gleam test
gleam check
```
