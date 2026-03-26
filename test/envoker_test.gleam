import envoker
import envoker/error
import envoy
import gleam/option
import gleeunit

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

pub fn read_optional_int_returns_none_when_missing_test() {
  let field_name = "ENVOKER_TEST_OPTIONAL_INT_MISSING"

  envoy.unset(field_name)

  let result = envoker.read_optional_int(field_name, option.None)

  assert result == Ok(option.None)
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

  assert result == Error(error.ParseFieldError(field_name, "Float"))

  envoy.unset(field_name)
}
