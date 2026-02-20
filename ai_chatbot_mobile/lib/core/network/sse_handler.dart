import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../constants/api_constants.dart';

/// Parses Server-Sent Events (SSE) streams from the backend.
///
/// The backend sends responses in the SSE format where each data line is
/// prefixed with `data: `. The stream ends with a `data: [DONE]` marker.
///
/// Example stream:
/// ```
/// data: The order
/// data:  12345 is
/// data:  currently in
/// data:  transit.
/// data: [DONE]
/// ```
///
/// This handler transforms a raw byte stream into a stream of text chunks,
/// stripping the `data: ` prefix and filtering out empty lines and the
/// `[DONE]` marker.
class SseHandler {
  SseHandler._();

  /// Transforms a raw SSE byte stream into individual text chunks.
  ///
  /// Takes the raw [Stream<List<int>>] from a Dio streaming response
  /// and yields each data chunk as a [String].
  ///
  /// The stream completes when `[DONE]` is received or the source stream ends.
  /// Empty lines and the `[DONE]` marker are filtered out.
  static Stream<String> transformStream(Stream<List<int>> byteStream) {
    return byteStream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.isNotEmpty)
        .map(_extractData)
        .where((chunk) => chunk != null)
        .cast<String>()
        .takeWhile((chunk) => chunk != ApiConstants.sseDoneMarker);
  }

  /// Extracts the data payload from a single SSE line.
  ///
  /// Returns `null` for lines that are not data lines (e.g., comments,
  /// event type declarations, empty lines).
  /// Returns the raw `[DONE]` marker so [takeWhile] can detect it.
  static String? _extractData(String line) {
    if (line.startsWith(ApiConstants.sseDataPrefix)) {
      final data = line.substring(ApiConstants.sseDataPrefix.length);
      // Return [DONE] marker as-is so takeWhile can detect end
      if (data.trim() == ApiConstants.sseDoneMarker) {
        return ApiConstants.sseDoneMarker;
      }
      return data;
    }

    // Ignore non-data SSE fields (event:, id:, retry:, comments)
    debugPrint('SseHandler: Ignoring non-data SSE line: $line');
    return null;
  }

  /// Convenience method to parse a single SSE line.
  ///
  /// Returns the extracted chunk content, or `null` if the line is
  /// not a valid data line. Returns `null` if the line is the `[DONE]` marker.
  static String? parseLine(String line) {
    if (!line.startsWith(ApiConstants.sseDataPrefix)) {
      return null;
    }
    final data = line.substring(ApiConstants.sseDataPrefix.length);
    if (data.trim() == ApiConstants.sseDoneMarker) {
      return null;
    }
    return data;
  }
}
