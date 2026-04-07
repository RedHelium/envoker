import gleam/option

/// Structured errors returned by environment readers.
pub type EnvFieldError {
  EmptyFieldError(field_name: String)
  MissingFieldError(field_name: String)
  ParseFieldError(
    field_name: String,
    expected_type: String,
    field_value: String,
    details: option.Option(String),
  )
}

/// Converts a structured error into a readable message.
pub fn to_string(error: EnvFieldError) -> String {
  case error {
    EmptyFieldError(field_name) -> "Empty value in '" <> field_name <> "'"
    MissingFieldError(field_name) ->
      "Missing environment variable '" <> field_name <> "'."
    ParseFieldError(field_name, expected_type, field_value, details) ->
      "Failed to parse field '"
      <> field_name
      <> "' with value '"
      <> field_value
      <> "'. Expected type: "
      <> expected_type
      <> case details {
        option.Some(text) -> ". Details: " <> text
        option.None -> ""
      }
  }
}
