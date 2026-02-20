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

  group('Session isolation – target app switching', () {
    test('switchTargetApp generates new conversationId', () async {
      final container = createContainer(storage);

      // Initial session
      final session1 = await container.read(sessionProvider.future);
      final originalConvId = session1.conversationId;
      expect(session1.targetAppId, equals(AppConstants.defaultTargetAppId));

      // Switch to TMS
      await container.read(sessionProvider.notifier).switchTargetApp('TMS');
      final session2 = container.read(sessionProvider).value!;

      // conversationId changed
      expect(session2.conversationId, isNot(equals(originalConvId)));
      expect(UuidGenerator.isValid(session2.conversationId), isTrue);

      // targetAppId updated
      expect(session2.targetAppId, equals('TMS'));

      // userId preserved
      expect(session2.userId, equals(session1.userId));

      container.dispose();
    });

    test('switchTargetApp persists new conversationId to storage', () async {
      final container = createContainer(storage);
      await container.read(sessionProvider.future);

      await container.read(sessionProvider.notifier).switchTargetApp('QMS');
      final session = container.read(sessionProvider).value!;

      final storedConvId = await storage.getConversationId();
      expect(storedConvId, equals(session.conversationId));

      container.dispose();
    });

    test('switchTargetApp persists new targetAppId to storage', () async {
      final container = createContainer(storage);
      await container.read(sessionProvider.future);

      await container.read(sessionProvider.notifier).switchTargetApp('TMS');

      final storedTargetAppId = await storage.getTargetAppId();
      expect(storedTargetAppId, equals('TMS'));

      container.dispose();
    });

    test('Switching to same target app is a no-op', () async {
      final container = createContainer(storage);
      final session1 = await container.read(sessionProvider.future);

      await container
          .read(sessionProvider.notifier)
          .switchTargetApp(AppConstants.defaultTargetAppId);
      final session2 = container.read(sessionProvider).value!;

      // Nothing changed
      expect(session2.conversationId, equals(session1.conversationId));
      expect(session2.targetAppId, equals(session1.targetAppId));

      container.dispose();
    });

    test('Target app is restored from storage on restart', () async {
      // First launch – switch to QMS
      final container1 = createContainer(storage);
      await container1.read(sessionProvider.future);
      await container1.read(sessionProvider.notifier).switchTargetApp('QMS');
      container1.dispose();

      // Second launch – same storage
      final container2 = createContainer(storage);
      final session2 = await container2.read(sessionProvider.future);

      expect(session2.targetAppId, equals('QMS'));
      container2.dispose();
    });

    test('Each target app switch gets a unique conversationId', () async {
      final container = createContainer(storage);
      await container.read(sessionProvider.future);

      final conversationIds = <String>{};

      // Switch through all apps
      for (final app in AppConstants.targetApps) {
        await container.read(sessionProvider.notifier).switchTargetApp(app.id);
        final session = container.read(sessionProvider).value!;
        conversationIds.add(session.conversationId);
      }

      // Each switch should produce a distinct conversationId
      expect(conversationIds.length, equals(AppConstants.targetApps.length));

      container.dispose();
    });

    test('userId is never affected by target app switching', () async {
      final container = createContainer(storage);
      final session1 = await container.read(sessionProvider.future);
      final originalUserId = session1.userId;

      // Switch multiple times
      await container.read(sessionProvider.notifier).switchTargetApp('TMS');
      await container.read(sessionProvider.notifier).switchTargetApp('QMS');
      await container.read(sessionProvider.notifier).switchTargetApp('STS_LP');

      final sessionFinal = container.read(sessionProvider).value!;
      expect(sessionFinal.userId, equals(originalUserId));

      container.dispose();
    });
  });
}
