import 'package:freezed_annotation/freezed_annotation.dart';

part 'target_app.freezed.dart';

/// A backend application context for the chat.
///
/// The user selects a [TargetApp] to scope the AI's responses to a
/// specific system (e.g., STS_LP, TMS, QMS). Switching the target app
/// creates a new conversation.
@freezed
abstract class TargetApp with _$TargetApp {
  const factory TargetApp({
    /// Unique code sent to the backend (e.g., `STS_LP`).
    required String id,

    /// Human-readable name shown in the UI dropdown.
    required String displayName,

    /// Optional description providing additional context.
    String? description,
  }) = _TargetApp;
}
