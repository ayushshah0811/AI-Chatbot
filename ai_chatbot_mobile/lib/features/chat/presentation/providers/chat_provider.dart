import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_sender.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/entities/target_app.dart';
import '../providers/chat_state.dart';
import '../providers/session_provider.dart';
// NOTE: SSE streaming import commented out — kept for future reference.
// import '../providers/streaming_state.dart';

part 'chat_provider.g.dart';

/// Primary state manager for the chat feature.
///
/// Orchestrates message sending, conversation lifecycle, and error handling.
/// All UI state flows through [ChatState].
@riverpod
class ChatNotifier extends _$ChatNotifier {
  late final ChatRepositoryImpl _repository;

  /// The text of the message currently being sent / last attempted.
  /// Used for retry on failure.
  String? _pendingMessageText;

  /// Whether the current request has been cancelled by the user.
  bool _isCancelled = false;

  /// The ID of the bot message currently being loaded.
  String? _activeBotMessageId;

  // NOTE: SSE streaming fields commented out — kept for future reference.
  // StreamSubscription<String>? _streamSubscription;
  // StreamingState? _streamingState;
  // Timer? _uiThrottleTimer;
  // bool _hasPendingUpdate = false;

  @override
  ChatState build() {
    // Wire up the repository
    final secureStorage = SecureStorageService();
    final apiClient = ApiClient(secureStorage: secureStorage);
    _repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSource(apiClient: apiClient),
    );

    // Restore persisted target app from session (if available)
    final sessionAsync = ref.read(sessionProvider);
    final initialTargetApp = _resolveTargetApp(sessionAsync.value?.targetAppId);

    return ChatState.initial().copyWith(selectedTargetApp: initialTargetApp);
  }

  // ── Send Message ──────────────────────────────────────────────────────

  /// Sends a user message and awaits the complete bot response.
  ///
  /// 1. Adds the user message to the conversation
  /// 2. Creates a placeholder bot message in `sending` state
  /// 3. Awaits the full response from the repository
  /// 4. Updates the bot message with the complete response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (!state.isSendEnabled) return;

    // Track the message text for retry on failure
    _pendingMessageText = text.trim();

    // Await session data (async provider may still be loading on first call)
    final session = await ref.read(sessionProvider.future);

    // Clear any previous error and last failed message
    state = state.copyWith(errorMessage: null, lastFailedMessage: null);

    // Ensure we have an active conversation
    final conversation =
        state.activeConversation ??
        Conversation(
          conversationId: session.conversationId,
          userId: session.userId,
          targetApp: state.selectedTargetApp,
          createdAt: DateTime.now(),
          messages: [],
        );

    // Create user message
    final userMessage = Message(
      id: _repository.generateConversationId(),
      content: text.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      conversationId: conversation.conversationId,
      status: MessageStatus.complete,
    );

    // Create placeholder bot message (loading state)
    final botMessageId = _repository.generateConversationId();
    final botMessage = Message(
      id: botMessageId,
      content: '',
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      conversationId: conversation.conversationId,
      status: MessageStatus.sending,
    );

    // Update state: add both messages, disable send, mark loading
    final updatedMessages = [...conversation.messages, userMessage, botMessage];
    final updatedConversation = conversation.copyWith(
      messages: updatedMessages,
    );

    final startTime = DateTime.now();

    _isCancelled = false;
    _activeBotMessageId = botMessageId;

    state = state.copyWith(
      activeConversation: updatedConversation,
      isStreaming: true, // reuse as "loading" indicator
      isSendEnabled: false,
      lastResponseTimeMs: null,
    );

    // Await the complete response
    try {
      final response = await _repository.sendMessage(
        message: text.trim(),
        userId: session.userId,
        conversationId: conversation.conversationId,
        targetApp: state.selectedTargetApp.id,
      );

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;

      // If the user cancelled while the request was in flight, discard the
      // response and keep the bot message in stopped state.
      if (_isCancelled) {
        _activeBotMessageId = null;
        return;
      }

      // Handle empty response
      if (response.trim().isEmpty) {
        _updateBotMessage(
          botMessageId: botMessageId,
          content: '',
          status: MessageStatus.error,
        );

        _pendingMessageText = null;
        state = state.copyWith(
          isStreaming: false,
          isSendEnabled: true,
          errorMessage: 'No response received. Please try again.',
          lastFailedMessage: _pendingMessageText,
        );
        return;
      }

      // Update bot message with complete response
      _updateBotMessage(
        botMessageId: botMessageId,
        content: response,
        status: MessageStatus.complete,
        responseTimeMs: elapsed,
      );

      _pendingMessageText = null;
      _activeBotMessageId = null;
      state = state.copyWith(
        isStreaming: false,
        isSendEnabled: true,
        lastResponseTimeMs: elapsed,
      );
    } catch (e) {
      debugPrint('ChatProvider: Send error: $e');

      final errorMsg = _userFriendlyError(e);

      _updateBotMessage(
        botMessageId: botMessageId,
        content: '',
        status: MessageStatus.error,
      );

      state = state.copyWith(
        isStreaming: false,
        isSendEnabled: true,
        errorMessage: errorMsg,
        lastFailedMessage: _pendingMessageText,
      );
      _activeBotMessageId = null;
    }
  }

  /// Returns a user-friendly error message based on the error type.
  String _userFriendlyError(Object error) {
    if (error is Exception) {
      final msg = error.toString().replaceFirst('Exception: ', '');
      if (msg.isNotEmpty && msg != 'null') return msg;
    }
    return 'Something went wrong. Please try again.';
  }

  // NOTE: SSE streaming callbacks commented out — kept for future reference.
  // void _onStreamChunk(String chunk) { ... }
  // void _onStreamError(Object error) { ... }
  // void _onStreamDone() { ... }

  // NOTE: Pause / Stop Streaming commented out — kept for future reference.
  // void pauseStreaming() { ... }

  /// Cancels the in-flight request and marks the bot message as stopped.
  void stopGenerating() {
    if (!state.isStreaming) return;

    _isCancelled = true;

    // Mark the placeholder bot message as stopped so it shows
    // a "Generation stopped" state instead of lingering as loading.
    if (_activeBotMessageId != null) {
      _updateBotMessage(
        botMessageId: _activeBotMessageId!,
        content: '',
        status: MessageStatus.stopped,
      );
      _activeBotMessageId = null;
    }

    state = state.copyWith(isStreaming: false, isSendEnabled: true);
  }

  // ── Target App ────────────────────────────────────────────────────────

  /// Switches the target app and starts a new conversation.
  ///
  /// Generates a new conversationId, clears the current messages,
  /// and updates the selected app.
  Future<void> setTargetApp(TargetApp targetApp) async {
    if (targetApp.id == state.selectedTargetApp.id) return;

    // Persist the target app and generate new conversationId in session
    await ref.read(sessionProvider.notifier).switchTargetApp(targetApp.id);

    state = state.copyWith(
      selectedTargetApp: targetApp,
      activeConversation: null,
      isStreaming: false,
      isSendEnabled: true,
      errorMessage: null,
      lastResponseTimeMs: null,
    );

    // Load history for the newly selected target app
    await loadHistory();
  }

  /// Alias for [setTargetApp] matching the task specification naming.
  Future<void> switchTargetApp(TargetApp targetApp) => setTargetApp(targetApp);

  /// Resolves a [TargetApp] from a persisted ID, falling back to default.
  static TargetApp _resolveTargetApp(String? targetAppId) {
    final id = targetAppId ?? AppConstants.defaultTargetAppId;
    final config = AppConstants.targetApps.firstWhere(
      (a) => a.id == id,
      orElse: () => AppConstants.targetApps.first,
    );
    return TargetApp(id: config.id, displayName: config.displayName);
  }

  // ── New Conversation ──────────────────────────────────────────────────

  /// Starts a brand-new conversation, clearing all messages.
  Future<void> newConversation() async {
    await ref.read(sessionProvider.notifier).newConversation();

    state = state.copyWith(
      activeConversation: null,
      isStreaming: false,
      isSendEnabled: true,
      errorMessage: null,
      lastResponseTimeMs: null,
    );
  }

  /// Alias for [newConversation] matching the task specification naming.
  ///
  /// Generates a new conversationId, clears messages, and keeps the
  /// selected target app unchanged.
  Future<void> startNewSession() => newConversation();

  // ── Load History ──────────────────────────────────────────────────────

  /// Loads chat history from the backend for the current user.
  ///
  /// Deduplicates messages by ID to prevent showing the same message twice
  /// (e.g. from overlapping history loads or network retries).
  Future<void> loadHistory() async {
    final session = await ref.read(sessionProvider.future);

    try {
      final messages = await _repository.loadHistory(userId: session.userId);
      if (messages.isEmpty) return;

      // Deduplicate by message ID
      final seen = <String>{};
      final unique = <Message>[];
      for (final msg in messages) {
        if (seen.add(msg.id)) {
          unique.add(msg);
        }
      }

      final conversation =
          state.activeConversation ??
          Conversation(
            conversationId: session.conversationId,
            userId: session.userId,
            targetApp: state.selectedTargetApp,
            createdAt: DateTime.now(),
            messages: [],
          );

      // Also check against existing messages in state
      final existingIds = conversation.messages.map((m) => m.id).toSet();
      final newMessages = unique
          .where((m) => !existingIds.contains(m.id))
          .toList();
      final merged = [...conversation.messages, ...newMessages];

      state = state.copyWith(
        activeConversation: conversation.copyWith(messages: merged),
      );
    } catch (e) {
      debugPrint('ChatProvider: Failed to load history: $e');
      state = state.copyWith(errorMessage: 'Failed to load chat history');
    }
  }

  // ── Error Handling ────────────────────────────────────────────────────

  /// Clears the current error message and last-failed-message marker.
  void clearError() {
    _pendingMessageText = null;
    state = state.copyWith(errorMessage: null, lastFailedMessage: null);
  }

  /// Retries sending the last message that failed.
  ///
  /// Removes the failed user + error bot messages from the conversation,
  /// then re-invokes [sendMessage] with the original text.
  Future<void> retryLastMessage() async {
    final text = state.lastFailedMessage;
    if (text == null) return;

    // Remove the failed user message and error bot message from the conversation
    final conversation = state.activeConversation;
    if (conversation != null && conversation.messages.length >= 2) {
      final messages = List<Message>.from(conversation.messages);

      // Remove last two messages (user + bot-error placeholder)
      final lastMsg = messages.last;
      if (lastMsg.sender == MessageSender.bot &&
          lastMsg.status == MessageStatus.error) {
        messages.removeLast();
        // Also remove the user message that triggered the error
        if (messages.isNotEmpty && messages.last.sender == MessageSender.user) {
          messages.removeLast();
        }
      }

      state = state.copyWith(
        activeConversation: conversation.copyWith(messages: messages),
        errorMessage: null,
        lastFailedMessage: null,
      );
    }

    await sendMessage(text);
  }

  // ── Rephrase ───────────────────────────────────────────────────────────

  /// Populates the message input with [text] so the user can edit and
  /// re-send it.
  ///
  /// Sets [ChatState.rephraseText] which the UI consumes to fill the
  /// input field, then clears automatically via [clearRephraseText].
  void rephrase(String text) {
    state = state.copyWith(rephraseText: text);
  }

  /// Clears the rephrase text after the UI has consumed it.
  void clearRephraseText() {
    state = state.copyWith(rephraseText: null);
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  /// Updates a bot message by its ID with new content and status.
  void _updateBotMessage({
    required String botMessageId,
    required String content,
    required MessageStatus status,
    int? responseTimeMs,
  }) {
    final conversation = state.activeConversation;
    if (conversation == null) return;

    final messages = conversation.messages.map((msg) {
      if (msg.id == botMessageId) {
        return msg.copyWith(
          content: content,
          status: status,
          responseTimeMs: responseTimeMs,
        );
      }
      return msg;
    }).toList();

    state = state.copyWith(
      activeConversation: conversation.copyWith(messages: messages),
    );
  }
}
