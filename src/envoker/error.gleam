/// Structured errors returned by environment readers.
pub type EnvFieldError {
  EmptyFieldError(field_name: String)
  MissingFieldError(field_name: String)
  ParseFieldError(field_name: String, expected_type: String)
}

/// Converts a structured env error into a readable message.
pub fn to_string(error: EnvFieldError) -> String {
  case error {
    EmptyFieldError(field_name) -> "Empty value in '" <> field_name <> "'"
    MissingFieldError(field_name) ->
      "Missing ENV field: '" <> field_name <> "'."
    ParseFieldError(field_name, expected_type) ->
      "Cannot parse '" <> field_name <> "'. Expected type: " <> expected_type
  }
}
