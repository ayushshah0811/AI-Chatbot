/// Lifecycle status of a chat [Message].
///
/// State transitions:
///
/// **User messages**: `sending` → `complete` | `error`
///
/// **Bot messages**: `streaming` → `complete` | `stopped` | `error`
enum MessageStatus {
  /// User message is being sent to the server.
  sending,

  /// Bot response is actively streaming from the server.
  streaming,

  /// Message delivery / streaming finished successfully.
  complete,

  /// User manually stopped the streaming response.
  stopped,

  /// An error occurred during sending or streaming.
  error,
}
