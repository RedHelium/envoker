import envoker/error.{type EnvFieldError, to_string as error_to_string}
import gleam/option
import utils/env

pub fn to_string(error: EnvFieldError) -> String {
  error_to_string(error)
}

pub fn read_required_int(
  field_name: String,
  default: option.Option(Int),
) -> Result(Int, EnvFieldError) {
  env.read_required_int(field_name, default)
}

pub fn read_optional_int(
  field_name: String,
  default: option.Option(Int),
) -> Result(option.Option(Int), EnvFieldError) {
  env.read_optional_int(field_name, default)
}

pub fn read_required_float(
  field_name: String,
  default: option.Option(Float),
) -> Result(Float, EnvFieldError) {
  env.read_required_float(field_name, default)
}

pub fn read_optional_float(
  field_name: String,
  default: option.Option(Float),
) -> Result(option.Option(Float), EnvFieldError) {
  env.read_optional_float(field_name, default)
}

pub fn read_required_bool(
  field_name: String,
  default: option.Option(Bool),
) -> Result(Bool, EnvFieldError) {
  env.read_required_bool(field_name, default)
}

pub fn read_optional_bool(
  field_name: String,
  default: option.Option(Bool),
) -> Result(option.Option(Bool), EnvFieldError) {
  env.read_optional_bool(field_name, default)
}

pub fn read_required_string(
  field_name: String,
  default: option.Option(String),
) -> Result(String, EnvFieldError) {
  env.read_required_string(field_name, default)
}

pub fn read_optional_string(
  field_name: String,
  default: option.Option(String),
) -> Result(option.Option(String), EnvFieldError) {
  env.read_optional_string(field_name, default)
}

pub fn read_required_with_parser(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, Nil),
) -> Result(a, EnvFieldError) {
  env.read_required_with_parser(field_name, default, expected_type, parser)
}

pub fn read_optional_with_parser(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, Nil),
) -> Result(option.Option(a), EnvFieldError) {
  env.read_optional_with_parser(field_name, default, expected_type, parser)
}

pub fn read_required_with_parser_detailed(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, String),
) -> Result(a, EnvFieldError) {
  env.read_required_with_parser_detailed(
    field_name,
    default,
    expected_type,
    parser,
  )
}

pub fn read_optional_with_parser_detailed(
  field_name: String,
  default: option.Option(a),
  expected_type: String,
  parser: fn(String) -> Result(a, String),
) -> Result(option.Option(a), EnvFieldError) {
  env.read_optional_with_parser_detailed(
    field_name,
    default,
    expected_type,
    parser,
  )
}
