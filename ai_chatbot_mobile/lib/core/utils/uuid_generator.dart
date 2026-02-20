import 'package:uuid/uuid.dart';

/// Wrapper around the `uuid` package for generating unique identifiers.
///
/// Used primarily for generating `conversationId` and `messageId` values.
/// Generates RFC 4122 v4 (random) UUIDs.
class UuidGenerator {
  UuidGenerator._();

  static const Uuid _uuid = Uuid();

  /// Generates a new random UUID v4 string.
  ///
  /// Example output: `'7c9e6679-7425-40de-944b-e07fc1f90ae7'`
  static String generate() => _uuid.v4();

  /// Validates whether the given string is a valid UUID format.
  ///
  /// Returns `true` if [value] matches the standard UUID pattern.
  static bool isValid(String value) {
    return Uuid.isValidUUID(fromString: value);
  }
}
