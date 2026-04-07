import envoker
import envoker/config
import envoker/error
import envoy
import gleam/option
import gleeunit

type AppConfig {
  AppConfig(host: String, port: Int, debug: option.Option(Bool))
}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn read_required_int_uses_default_when_missing_test() {
  let field_name = "ENVOKER_TEST_REQUIRED_INT_DEFAULT_MISSING"

  envoy.unset(field_name)

  let result = envoker.read_required_int(field_name, option.Some(42))

  assert result == Ok(42)
}

pub fn read_required_int_uses_default_when_empty_test() {
  let field_name = "ENVOKER_TEST_REQUIRED_INT_DEFAULT_EMPTY"

  envoy.set(field_name, "   ")

  let result = envoker.read_required_int(field_name, option.Some(7))

  assert result == Ok(7)

  envoy.unset(field_name)
}

pub fn read_required_int_returns_missing_error_without_default_test() {
  let field_name = "ENVOKER_TEST_REQUIRED_INT_MISSING_NO_DEFAULT"

  envoy.unset(field_name)

  let result = envoker.read_required_int(field_name, option.None)

  assert result == Error(error.MissingFieldError(field_name))
}

pub fn read_required_int_returns_empty_error_without_default_test() {
  let field_name = "ENVOKER_TEST_REQUIRED_INT_EMPTY_NO_DEFAULT"

  envoy.set(field_name, "    ")

  let result = envoker.read_required_int(field_name, option.None)

  assert result == Error(error.EmptyFieldError(field_name))

  envoy.unset(field_name)
}

pub fn read_optional_int_returns_none_when_missing_test() {
  let field_name = "ENVOKER_TEST_OPTIONAL_INT_MISSING"

  envoy.unset(field_name)

  let result = envoker.read_optional_int(field_name, option.None)

  assert result == Ok(option.None)
}

pub fn read_optional_int_uses_default_when_missing_test() {
  let field_name = "ENVOKER_TEST_OPTIONAL_INT_DEFAULT_MISSING"

  envoy.unset(field_name)

  let result = envoker.read_optional_int(field_name, option.Some(99))

  assert result == Ok(option.Some(99))
}

pub fn read_optional_string_uses_default_when_empty_test() {
  let field_name = "ENVOKER_TEST_OPTIONAL_STRING_DEFAULT_EMPTY"

  envoy.set(field_name, "   ")

  let result = envoker.read_optional_string(field_name, option.Some("fallback"))

  assert result == Ok(option.Some("fallback"))

  envoy.unset(field_name)
}

pub fn read_required_bool_is_case_insensitive_test() {
  let true_field_name = "ENVOKER_TEST_REQUIRED_BOOL_TRUE"
  let false_field_name = "ENVOKER_TEST_REQUIRED_BOOL_FALSE"

  envoy.set(true_field_name, "TRUE")
  envoy.set(false_field_name, "fAlSe")

  let true_result = envoker.read_required_bool(true_field_name, option.None)
  let false_result = envoker.read_required_bool(false_field_name, option.None)

  assert true_result == Ok(True)
  assert false_result == Ok(False)

  envoy.unset(true_field_name)
  envoy.unset(false_field_name)
}

pub fn read_optional_bool_returns_parse_error_test() {
  let field_name = "ENVOKER_TEST_OPTIONAL_BOOL_PARSE_ERROR"

  envoy.set(field_name, "yes")

  let result = envoker.read_optional_bool(field_name, option.None)

  assert result
    == Error(error.ParseFieldError(field_name, "Bool", "yes", option.None))

  envoy.unset(field_name)
}

pub fn read_required_string_trims_value_test() {
  let field_name = "ENVOKER_TEST_REQUIRED_STRING_TRIM"

  envoy.set(field_name, "  hello  ")

  let result = envoker.read_required_string(field_name, option.None)

  assert result == Ok("hello")

  envoy.unset(field_name)
}

pub fn read_required_float_returns_parse_error_test() {
  let field_name = "ENVOKER_TEST_REQUIRED_FLOAT_PARSE_ERROR"

  envoy.set(field_name, "not-a-float")

  let result = envoker.read_required_float(field_name, option.None)

  assert result
    == Error(error.ParseFieldError(
      field_name,
      "Float",
      "not-a-float",
      option.None,
    ))

  envoy.unset(field_name)
}

pub fn read_required_with_parser_returns_parse_error_without_details_test() {
  let field_name = "ENVOKER_TEST_REQUIRED_CUSTOM_PARSE_ERROR"

  envoy.set(field_name, "  abc  ")

  let result =
    envoker.read_required_with_parser(field_name, option.None, "Hex", fn(_) {
      Error(Nil)
    })

  assert result
    == Error(error.ParseFieldError(field_name, "Hex", "abc", option.None))

  envoy.unset(field_name)
}

pub fn read_required_with_parser_detailed_returns_parse_error_with_details_test() {
  let field_name = "ENVOKER_TEST_REQUIRED_CUSTOM_PARSE_ERROR_DETAILED"

  envoy.set(field_name, "  blue  ")

  let result =
    envoker.read_required_with_parser_detailed(
      field_name,
      option.None,
      "Color",
      fn(_) { Error("only red is allowed") },
    )

  assert result
    == Error(error.ParseFieldError(
      field_name,
      "Color",
      "blue",
      option.Some("only red is allowed"),
    ))

  envoy.unset(field_name)
}

pub fn load_config_returns_success_when_all_fields_are_valid_test() {
  let host_field = "ENVOKER_TEST_CONFIG_HOST_OK"
  let port_field = "ENVOKER_TEST_CONFIG_PORT_OK"
  let debug_field = "ENVOKER_TEST_CONFIG_DEBUG_OK"

  envoy.set(host_field, "  api.local  ")
  envoy.set(port_field, "8081")
  envoy.set(debug_field, "true")

  let result =
    config.load(AppConfig(host: "", port: 0, debug: option.None), [
      config.required_string(host_field, option.None, set_host),
      config.required_int(port_field, option.None, set_port),
      config.optional_bool(debug_field, option.None, set_debug),
    ])

  assert result
    == Ok(AppConfig(host: "api.local", port: 8081, debug: option.Some(True)))

  envoy.unset(host_field)
  envoy.unset(port_field)
  envoy.unset(debug_field)
}

pub fn load_config_accumulates_errors_and_does_not_fail_fast_test() {
  let host_field = "ENVOKER_TEST_CONFIG_HOST_FAIL"
  let port_field = "ENVOKER_TEST_CONFIG_PORT_FAIL"
  let debug_field = "ENVOKER_TEST_CONFIG_DEBUG_FAIL"

  envoy.unset(host_field)
  envoy.set(port_field, "abc")
  envoy.set(debug_field, "enabled")

  let result =
    config.load(
      AppConfig(host: "default-host", port: 5000, debug: option.None),
      [
        config.required_string(host_field, option.None, set_host),
        config.required_int(port_field, option.None, set_port),
        config.optional_bool(debug_field, option.None, set_debug),
      ],
    )

  assert result
    == Error([
      error.MissingFieldError(host_field),
      error.ParseFieldError(port_field, "Int", "abc", option.None),
      error.ParseFieldError(debug_field, "Bool", "enabled", option.None),
    ])

  envoy.unset(port_field)
  envoy.unset(debug_field)
}

pub fn error_to_string_includes_parse_details_test() {
  let message =
    envoker.to_string(error.ParseFieldError(
      "COLOR",
      "Color",
      "blue",
      option.Some("only red is allowed"),
    ))

  assert message
    == "Failed to parse field 'COLOR' with value 'blue'. Expected type: Color. Details: only red is allowed"
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
