import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/message_dto.dart';

/// Concrete implementation of [ChatRepository].
///
/// Delegates all operations to [ChatRemoteDataSource] which communicates
/// with the backend API at `http://10.30.0.233:8055`.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ChatRemoteDataSource _remoteDataSource;

  // ── ChatRepository ──────────────────────────────────────────────────────

  @override
  Future<String> sendMessage({
    required String message,
    required String userId,
    required String conversationId,
    required String targetApp,
  }) {
    final dto = MessageDto(
      message: message,
      userId: userId,
      conversationId: conversationId,
      targetApp: targetApp,
    );

    return _remoteDataSource.sendMessage(messageDto: dto);
  }

  @override
  Future<List<Message>> loadHistory({required String userId}) {
    return _remoteDataSource.loadHistory(userId: userId);
  }

  @override
  String generateConversationId() => UuidGenerator.generate();
}
