import envoker/error.{
  type EnvFieldError, EmptyFieldError, MissingFieldError, ParseFieldError,
}
import envoy
import gleam/float
import gleam/int
import gleam/option
import gleam/result
import gleam/string

type Presence {
  Required
  Optional
}

/// Reads a required integer environment variable.
/// The value is normalized with `string.trim` before parsing.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_required_int(
  field_name: String,
  default: option.Option(Int),
) -> Result(Int, EnvFieldError) {
  read_required_with_parser(field_name, default, "Int", int.parse)
}

/// Reads an optional integer environment variable.
/// The value is normalized with `string.trim` before parsing.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_optional_int(
  field_name: String,
  default: option.Option(Int),
) -> Result(option.Option(Int), EnvFieldError) {
  read_optional_with_parser(field_name, default, "Int", int.parse)
}

/// Reads a required float environment variable.
/// The value is normalized with `string.trim` before parsing.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_required_float(
  field_name: String,
  default: option.Option(Float),
) -> Result(Float, EnvFieldError) {
  read_required_with_parser(field_name, default, "Float", float.parse)
}

/// Reads an optional float environment variable.
/// The value is normalized with `string.trim` before parsing.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_optional_float(
  field_name: String,
  default: option.Option(Float),
) -> Result(option.Option(Float), EnvFieldError) {
  read_optional_with_parser(field_name, default, "Float", float.parse)
}

/// Reads a required boolean environment variable.
/// The value is normalized with `string.trim` before parsing.
/// Parsing is case-insensitive.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_required_bool(
  field_name: String,
  default: option.Option(Bool),
) -> Result(Bool, EnvFieldError) {
  read_required_with_parser(field_name, default, "Bool", parse_bool)
}

/// Reads an optional boolean environment variable.
/// The value is normalized with `string.trim` before parsing.
/// Parsing is case-insensitive.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_optional_bool(
  field_name: String,
  default: option.Option(Bool),
) -> Result(option.Option(Bool), EnvFieldError) {
  read_optional_with_parser(field_name, default, "Bool", parse_bool)
}

/// Reads a required string environment variable.
/// This is not a raw read: the value always goes through `string.trim`,
/// so leading and trailing whitespace is removed before returning.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_required_string(
  field_name: String,
  default: option.Option(String),
) -> Result(String, EnvFieldError) {
  read_required_with_parser(field_name, default, "String", fn(field) {
    Ok(field)
  })
}

/// Reads an optional string environment variable.
/// This is not a raw read: the value always goes through `string.trim`,
/// so leading and trailing whitespace is removed before returning.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_optional_string(
  field_name: String,
  default: option.Option(String),
) -> Result(option.Option(String), EnvFieldError) {
  read_optional_with_parser(field_name, default, "String", fn(field) {
    Ok(field)
  })
}

/// Reads a required environment variable with a custom parser.
/// The value is normalized with `string.trim` before parsing.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_required_with_parser(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, Nil),
) -> Result(a, EnvFieldError) {
  unwrap_required(
    field_name,
    read_value(field_name, Required, default, expected_type, parser),
  )
}

/// Reads an optional environment variable with a custom parser.
/// The value is normalized with `string.trim` before parsing.
/// Uses `default` when the field is missing or empty, if provided.
pub fn read_optional_with_parser(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, Nil),
) -> Result(option.Option(a), EnvFieldError) {
  read_value(field_name, Optional, default, expected_type, parser)
}

/// Parses `true` / `false` string values without case sensitivity.
fn parse_bool(field: String) -> Result(Bool, Nil) {
  case string.lowercase(field) {
    "true" -> Ok(True)
    "false" -> Ok(False)
    _ -> Error(Nil)
  }
}

fn read_value(
  field_name: String,
  presence: Presence,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, Nil),
) -> Result(option.Option(a), EnvFieldError) {
  case envoy.get(field_name) {
    Ok(field) -> {
      let field = string.trim(field)
      case field {
        "" -> handle_missing_or_empty(field_name, presence, default, True)
        _ ->
          parser(field)
          |> result.map(option.Some)
          |> result.map_error(fn(_) {
            ParseFieldError(field_name, expected_type)
          })
      }
    }
    Error(_) -> handle_missing_or_empty(field_name, presence, default, False)
  }
}

fn unwrap_required(
  field_name: String,
  value: Result(option.Option(a), EnvFieldError),
) -> Result(a, EnvFieldError) {
  case value {
    Ok(option.Some(value)) -> Ok(value)
    Ok(option.None) -> Error(MissingFieldError(field_name))
    Error(error) -> Error(error)
  }
}

fn handle_missing_or_empty(
  field_name: String,
  presence: Presence,
  default: option.Option(a),
  is_empty: Bool,
) -> Result(option.Option(a), EnvFieldError) {
  case default {
    option.Some(default) -> Ok(option.Some(default))
    option.None ->
      case presence {
        Optional -> Ok(option.None)
        Required ->
          Error(case is_empty {
            True -> EmptyFieldError(field_name)
            False -> MissingFieldError(field_name)
          })
      }
  }
}
