import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_chatbot_mobile/core/constants/app_constants.dart';
import 'package:ai_chatbot_mobile/core/storage/secure_storage.dart';
import 'package:ai_chatbot_mobile/core/utils/uuid_generator.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/providers/session_provider.dart';

// ── In-memory fake storage ──────────────────────────────────────────────

/// A [SecureStorageService] backed by an in-memory [Map].
/// No platform channels needed – safe for pure Dart unit tests.
class FakeStorageService extends SecureStorageService {
  final Map<String, String> _store = {};

  FakeStorageService() : super();

  Map<String, String> get store => _store;

  @override
  Future<void> saveUserId(String userId) async => _store['userId'] = userId;

  @override
  Future<String?> getUserId() async => _store['userId'];

  @override
  Future<void> deleteUserId() async => _store.remove('userId');

  @override
  Future<void> saveConversationId(String id) async =>
      _store['conversationId'] = id;

  @override
  Future<String?> getConversationId() async => _store['conversationId'];

  @override
  Future<void> deleteConversationId() async => _store.remove('conversationId');

  @override
  Future<void> saveTargetAppId(String id) async => _store['targetAppId'] = id;

  @override
  Future<String?> getTargetAppId() async => _store['targetAppId'];

  @override
  Future<void> clearAll() async => _store.clear();
}

// ── Helpers ─────────────────────────────────────────────────────────────

/// Override [secureStorageServiceProvider] so SessionNotifier uses our fake.
ProviderContainer createContainer(FakeStorageService storage) {
  return ProviderContainer(
    overrides: [secureStorageServiceProvider.overrideWithValue(storage)],
  );
}

void main() {
  late FakeStorageService storage;

  setUp(() {
    storage = FakeStorageService();
  });

  group('New Chat session – startNewSession / newConversation', () {
    test('newConversation generates a new conversationId', () async {
      final container = createContainer(storage);

      // Initial session
      final session1 = await container.read(sessionProvider.future);
      final originalConvId = session1.conversationId;
      expect(UuidGenerator.isValid(originalConvId), isTrue);

      // Start new conversation
      await container.read(sessionProvider.notifier).newConversation();
      final session2 = container.read(sessionProvider).value!;

      // conversationId must be different
      expect(session2.conversationId, isNot(equals(originalConvId)));
      expect(UuidGenerator.isValid(session2.conversationId), isTrue);

      container.dispose();
    });

    test('newConversation preserves the target app', () async {
      final container = createContainer(storage);
      final session1 = await container.read(sessionProvider.future);
      final originalTargetApp = session1.targetAppId;

      // Start new conversation
      await container.read(sessionProvider.notifier).newConversation();
      final session2 = container.read(sessionProvider).value!;

      // targetAppId must remain the same
      expect(session2.targetAppId, equals(originalTargetApp));

      container.dispose();
    });

    test('newConversation preserves the userId', () async {
      final container = createContainer(storage);
      final session1 = await container.read(sessionProvider.future);
      final originalUserId = session1.userId;

      await container.read(sessionProvider.notifier).newConversation();
      final session2 = container.read(sessionProvider).value!;

      expect(session2.userId, equals(originalUserId));

      container.dispose();
    });

    test('newConversation persists new conversationId to storage', () async {
      final container = createContainer(storage);
      await container.read(sessionProvider.future);

      await container.read(sessionProvider.notifier).newConversation();
      final session = container.read(sessionProvider).value!;

      final storedConvId = await storage.getConversationId();
      expect(storedConvId, equals(session.conversationId));

      container.dispose();
    });

    test('Target app unchanged after new chat with non-default app', () async {
      final container = createContainer(storage);
      await container.read(sessionProvider.future);

      // Switch to TMS first
      await container.read(sessionProvider.notifier).switchTargetApp('TMS');
      final sessionAfterSwitch = container.read(sessionProvider).value!;
      expect(sessionAfterSwitch.targetAppId, equals('TMS'));

      // Now start new conversation
      await container.read(sessionProvider.notifier).newConversation();
      final sessionAfterNew = container.read(sessionProvider).value!;

      // Target app still TMS
      expect(sessionAfterNew.targetAppId, equals('TMS'));

      // But conversationId changed
      expect(
        sessionAfterNew.conversationId,
        isNot(equals(sessionAfterSwitch.conversationId)),
      );

      container.dispose();
    });

    test('Multiple new conversations each get unique conversationId', () async {
      final container = createContainer(storage);
      await container.read(sessionProvider.future);

      final conversationIds = <String>{};

      for (var i = 0; i < 5; i++) {
        await container.read(sessionProvider.notifier).newConversation();
        final session = container.read(sessionProvider).value!;
        conversationIds.add(session.conversationId);
      }

      // All 5 should be unique
      expect(conversationIds.length, equals(5));

      container.dispose();
    });

    test('Default target app is used on fresh session', () async {
      final container = createContainer(storage);
      final session = await container.read(sessionProvider.future);

      expect(session.targetAppId, equals(AppConstants.defaultTargetAppId));

      container.dispose();
    });
  });
}
