import envoker
import envoker/error.{type EnvFieldError}
import gleam/list
import gleam/option

/// A description of one field-loading step for declarative config loading.
pub opaque type ConfigField(config) {
  ConfigField(apply: fn(config) -> Result(config, EnvFieldError))
}

/// Applies all field-loading steps to an initial config value.
/// Errors are accumulated; loading does not stop on the first failure.
pub fn load(
  initial: config,
  fields: List(ConfigField(config)),
) -> Result(config, List(EnvFieldError)) {
  let #(resolved, reversed_errors) =
    list.fold(fields, #(initial, []), fn(state, field) {
      let #(current, errors) = state
      let ConfigField(apply) = field

      case apply(current) {
        Ok(updated) -> #(updated, errors)
        Error(error) -> #(current, [error, ..errors])
      }
    })

  case list.reverse(reversed_errors) {
    [] -> Ok(resolved)
    errors -> Error(errors)
  }
}

/// Describes a required `Int` field.
pub fn required_int(
  field_name: String,
  default: option.Option(Int),
  assign: fn(config, Int) -> config,
) -> ConfigField(config) {
  make_required(fn() { envoker.read_required_int(field_name, default) }, assign)
}

/// Describes an optional `Int` field.
pub fn optional_int(
  field_name: String,
  default: option.Option(Int),
  assign: fn(config, option.Option(Int)) -> config,
) -> ConfigField(config) {
  make_optional(fn() { envoker.read_optional_int(field_name, default) }, assign)
}

/// Describes a required `Float` field.
pub fn required_float(
  field_name: String,
  default: option.Option(Float),
  assign: fn(config, Float) -> config,
) -> ConfigField(config) {
  make_required(
    fn() { envoker.read_required_float(field_name, default) },
    assign,
  )
}

/// Describes an optional `Float` field.
pub fn optional_float(
  field_name: String,
  default: option.Option(Float),
  assign: fn(config, option.Option(Float)) -> config,
) -> ConfigField(config) {
  make_optional(
    fn() { envoker.read_optional_float(field_name, default) },
    assign,
  )
}

/// Describes a required `Bool` field.
pub fn required_bool(
  field_name: String,
  default: option.Option(Bool),
  assign: fn(config, Bool) -> config,
) -> ConfigField(config) {
  make_required(
    fn() { envoker.read_required_bool(field_name, default) },
    assign,
  )
}

/// Describes an optional `Bool` field.
pub fn optional_bool(
  field_name: String,
  default: option.Option(Bool),
  assign: fn(config, option.Option(Bool)) -> config,
) -> ConfigField(config) {
  make_optional(
    fn() { envoker.read_optional_bool(field_name, default) },
    assign,
  )
}

/// Describes a required `String` field.
pub fn required_string(
  field_name: String,
  default: option.Option(String),
  assign: fn(config, String) -> config,
) -> ConfigField(config) {
  make_required(
    fn() { envoker.read_required_string(field_name, default) },
    assign,
  )
}

/// Describes an optional `String` field.
pub fn optional_string(
  field_name: String,
  default: option.Option(String),
  assign: fn(config, option.Option(String)) -> config,
) -> ConfigField(config) {
  make_optional(
    fn() { envoker.read_optional_string(field_name, default) },
    assign,
  )
}

/// Describes a required field with a custom parser without error details.
pub fn required_with_parser(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, Nil),
  assign: fn(config, a) -> config,
) -> ConfigField(config) {
  make_required(
    fn() {
      envoker.read_required_with_parser(
        field_name,
        default,
        expected_type,
        parser,
      )
    },
    assign,
  )
}

/// Describes an optional field with a custom parser without error details.
pub fn optional_with_parser(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, Nil),
  assign: fn(config, option.Option(a)) -> config,
) -> ConfigField(config) {
  make_optional(
    fn() {
      envoker.read_optional_with_parser(
        field_name,
        default,
        expected_type,
        parser,
      )
    },
    assign,
  )
}

/// Describes a required field with a custom parser with detailed errors.
pub fn required_with_parser_detailed(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, String),
  assign: fn(config, a) -> config,
) -> ConfigField(config) {
  make_required(
    fn() {
      envoker.read_required_with_parser_detailed(
        field_name,
        default,
        expected_type,
        parser,
      )
    },
    assign,
  )
}

/// Describes an optional field with a custom parser with detailed errors.
pub fn optional_with_parser_detailed(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, String),
  assign: fn(config, option.Option(a)) -> config,
) -> ConfigField(config) {
  make_optional(
    fn() {
      envoker.read_optional_with_parser_detailed(
        field_name,
        default,
        expected_type,
        parser,
      )
    },
    assign,
  )
}

fn make_required(
  reader: fn() -> Result(a, EnvFieldError),
  assign: fn(config, a) -> config,
) -> ConfigField(config) {
  ConfigField(fn(current) {
    case reader() {
      Ok(value) -> Ok(assign(current, value))
      Error(error) -> Error(error)
    }
  })
}

fn make_optional(
  reader: fn() -> Result(option.Option(a), EnvFieldError),
  assign: fn(config, option.Option(a)) -> config,
) -> ConfigField(config) {
  ConfigField(fn(current) {
    case reader() {
      Ok(value) -> Ok(assign(current, value))
      Error(error) -> Error(error)
    }
  })
}
