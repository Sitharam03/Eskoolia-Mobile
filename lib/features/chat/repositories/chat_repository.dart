import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_models.dart';

/// Chat API repository — mirrors all backend chat endpoints.
/// Handles all response wrapper formats (bare list, {results: [...]}, {users: [...]}, etc.)
class ChatRepository {
  ChatRepository._();
  static final ChatRepository instance = ChatRepository._();

  static const _base = '/api/chat';

  /// Safely extract a list from response data.
  /// Backend may return: bare List, {results: [...]}, {users: [...]}, or {key: [...]}
  static List<dynamic> _extractList(dynamic data, [String? key]) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (key != null && data.containsKey(key) && data[key] is List) {
        return data[key] as List;
      }
      if (data.containsKey('results') && data['results'] is List) {
        return data['results'] as List;
      }
      if (data.containsKey('users') && data['users'] is List) {
        return data['users'] as List;
      }
      if (data.containsKey('data') && data['data'] is List) {
        return data['data'] as List;
      }
      // Try first list value in the map
      for (final v in data.values) {
        if (v is List) return v;
      }
    }
    return [];
  }

  // ── 1-to-1 Messaging ──────────────────────────────────────────────────────

  /// Get all connected users for sidebar.
  Future<List<ChatUser>> getConnectedUsers() async {
    final r = await ApiClient.dio.get('$_base/messages/connected_users/');
    return _extractList(r.data, 'users')
        .map((u) => ChatUser.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  /// Get conversation thread with a specific user.
  Future<List<Conversation>> getConversation(int userId) async {
    final r = await ApiClient.dio
        .get('$_base/messages/conversation/', queryParameters: {'user_id': userId});
    return _extractList(r.data)
        .map((m) => Conversation.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Send a 1-to-1 text message.
  Future<Conversation> sendMessage({
    required int toUserId,
    required String message,
    MessageType type = MessageType.text,
    int? replyId,
  }) async {
    final r = await ApiClient.dio.post('$_base/messages/', data: {
      'to_user': toUserId,
      'message': message,
      'message_type': msgTypeToInt(type),
      if (replyId != null) 'reply': replyId,
    });
    return Conversation.fromJson(r.data as Map<String, dynamic>);
  }

  /// Send a 1-to-1 file message (image, pdf, doc, voice).
  Future<Conversation> sendFileMessage({
    required int toUserId,
    required String filePath,
    required MessageType type,
    String? caption,
  }) async {
    final formData = FormData.fromMap({
      'to_user': toUserId,
      'message_type': msgTypeToInt(type),
      'file_name': await MultipartFile.fromFile(filePath),
      if (caption != null && caption.isNotEmpty) 'message': caption,
    });
    final r = await ApiClient.dio.post('$_base/messages/', data: formData);
    return Conversation.fromJson(r.data as Map<String, dynamic>);
  }

  /// Mark messages from a user as read.
  Future<void> markRead(int userId) async {
    await ApiClient.dio.post('$_base/messages/mark_read/', data: {'user_id': userId});
  }

  /// Forward a message.
  Future<Conversation> forwardMessage({
    required int messageId,
    required int toUserId,
  }) async {
    final r = await ApiClient.dio.post('$_base/messages/forward/',
        data: {'message_id': messageId, 'to_user': toUserId});
    return Conversation.fromJson(r.data as Map<String, dynamic>);
  }

  /// Delete a message.
  Future<void> deleteMessage(int messageId) async {
    await ApiClient.dio.delete('$_base/messages/$messageId/');
  }

  /// Search users.
  Future<List<ChatUser>> searchUsers({String query = '', String? userType}) async {
    final params = <String, dynamic>{'query': query, 'q': query};
    if (userType != null && userType.isNotEmpty) params['user_type'] = userType;
    final r = await ApiClient.dio
        .get('$_base/messages/search_users/', queryParameters: params);
    return _extractList(r.data, 'users')
        .map((u) => ChatUser.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  /// Get shared files with a user.
  Future<List<Conversation>> getSharedFiles(int userId) async {
    final r = await ApiClient.dio
        .get('$_base/messages/files/', queryParameters: {'user_id': userId});
    return _extractList(r.data)
        .map((m) => Conversation.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  // ── Blocking ───────────────────────────────────────────────────────────────

  Future<void> blockUser(int userId) async {
    await ApiClient.dio.post('$_base/messages/block_user/', data: {'user_id': userId});
  }

  Future<void> unblockUser(int userId) async {
    await ApiClient.dio.post('$_base/messages/unblock_user/', data: {'user_id': userId});
  }

  Future<List<ChatUser>> getBlockedUsers() async {
    final r = await ApiClient.dio.get('$_base/messages/blocked_users/');
    // Backend returns {blocked_users: [...]} where each item has blocked_user field
    final raw = _extractList(r.data, 'blocked_users');
    return raw.map((item) {
      if (item is Map<String, dynamic>) {
        // Item may be {id, blocked_user: {id, username, ...}, created_at}
        final userMap = item['blocked_user'] as Map<String, dynamic>? ?? item;
        return ChatUser.fromJson(userMap);
      }
      return ChatUser(id: 0, username: '');
    }).where((u) => u.id != 0).toList();
  }

  // ── Groups ─────────────────────────────────────────────────────────────────

  /// List user's groups.
  Future<List<ChatGroup>> getGroups() async {
    final r = await ApiClient.dio.get('$_base/groups/');
    return _extractList(r.data)
        .map((g) => ChatGroup.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  /// Get group details + last messages.
  Future<Map<String, dynamic>> getGroupDetail(String groupId) async {
    final r = await ApiClient.dio.get('$_base/groups/$groupId/');
    final data = r.data;
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  /// Create a group.
  Future<ChatGroup> createGroup({
    required String name,
    required List<int> userIds,
    String? description,
  }) async {
    final r = await ApiClient.dio.post('$_base/groups/', data: {
      'name': name,
      'user_ids': userIds,
      if (description != null) 'description': description,
    });
    final data = r.data;
    if (data is Map<String, dynamic>) {
      // Backend may return {group: {...}} or bare group object
      final groupMap = data.containsKey('group')
          ? data['group'] as Map<String, dynamic>
          : data;
      return ChatGroup.fromJson(groupMap);
    }
    return ChatGroup(id: '', name: name, createdAt: DateTime.now());
  }

  /// Send message to group.
  Future<GroupMessage> sendGroupMessage({
    required String groupId,
    required String message,
    MessageType type = MessageType.text,
  }) async {
    final r = await ApiClient.dio.post('$_base/groups/$groupId/send/', data: {
      'message': message,
      'message_type': msgTypeToInt(type),
    });
    return GroupMessage.fromJson(r.data as Map<String, dynamic>);
  }

  /// Send file to group.
  Future<GroupMessage> sendGroupFile({
    required String groupId,
    required String filePath,
    required MessageType type,
    String? caption,
  }) async {
    final formData = FormData.fromMap({
      'message_type': msgTypeToInt(type),
      'file_name': await MultipartFile.fromFile(filePath),
      if (caption != null && caption.isNotEmpty) 'message': caption,
    });
    final r = await ApiClient.dio.post('$_base/groups/$groupId/send/', data: formData);
    return GroupMessage.fromJson(r.data as Map<String, dynamic>);
  }

  /// Add members to group.
  Future<void> addGroupMembers(String groupId, List<int> userIds) async {
    await ApiClient.dio
        .post('$_base/groups/$groupId/add_members/', data: {'user_ids': userIds});
  }

  /// Remove members from group.
  Future<void> removeGroupMembers(String groupId, List<int> userIds) async {
    await ApiClient.dio
        .post('$_base/groups/$groupId/remove_members/', data: {'user_ids': userIds});
  }

  /// Leave group.
  Future<void> leaveGroup(String groupId) async {
    await ApiClient.dio.post('$_base/groups/$groupId/leave/');
  }

  /// Delete group (admin only).
  Future<void> deleteGroup(String groupId) async {
    await ApiClient.dio.delete('$_base/groups/$groupId/');
  }

  // ── Invitations ────────────────────────────────────────────────────────────

  Future<List<Invitation>> getInvitations() async {
    final r = await ApiClient.dio.get('$_base/invitations/');
    return _extractList(r.data)
        .map((i) => Invitation.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<Invitation> sendInvitation(int toUserId) async {
    final r = await ApiClient.dio
        .post('$_base/invitations/', data: {'to_user_id': toUserId});
    return Invitation.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> acceptInvitation(int invitationId) async {
    await ApiClient.dio.post('$_base/invitations/$invitationId/accept/');
  }

  Future<void> declineInvitation(int invitationId) async {
    await ApiClient.dio.post('$_base/invitations/$invitationId/decline/');
  }

  Future<List<Invitation>> getPendingInvitations() async {
    final r = await ApiClient.dio.get('$_base/invitations/pending/');
    return _extractList(r.data)
        .map((i) => Invitation.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  // ── Online Status ──────────────────────────────────────────────────────────

  Future<void> setOnline() async {
    await ApiClient.dio.post('$_base/status/set_online/');
  }

  Future<void> setOffline() async {
    await ApiClient.dio.post('$_base/status/set_offline/');
  }
}
