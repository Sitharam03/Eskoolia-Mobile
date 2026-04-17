import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/network/api_error.dart';
import '../models/chat_models.dart';
import '../repositories/chat_repository.dart';

class ChatController extends GetxController {
  final _repo = ChatRepository.instance;

  // ── State variables ───────────────────────────────────────────────────────

  final connectedUsers = <ChatUser>[].obs;
  final recentChats = <ChatThread>[].obs; // recent conversations grouped by user
  final groups = <ChatGroup>[].obs;
  final currentMessages = <Conversation>[].obs;
  final currentGroupMessages = <GroupMessage>[].obs;

  final selectedUser = Rx<ChatUser?>(null);
  final selectedGroup = Rx<ChatGroup?>(null);

  final isLoadingUsers = false.obs;
  final isLoadingMessages = false.obs;
  final isSending = false.obs;

  final searchQuery = ''.obs;
  final activeTab = 0.obs;

  final replyingTo = Rx<Conversation?>(null);

  final messageCtrl = TextEditingController();

  // ── Module tabs (0=Chat, 1=Invitation, 2=Blocked) ────────────────────────
  final moduleTab = 0.obs;

  // ── Invitations ──────────────────────────────────────────────────────────
  final invitations = <Invitation>[].obs;
  final invSearchResults = <ChatUser>[].obs;
  final isLoadingInv = false.obs;
  final invUserType = 'all'.obs;
  final invSearchQuery = ''.obs;

  List<Invitation> get pendingInvitations =>
      invitations.where((i) => i.status == 0).toList();

  // ── Blocked users ────────────────────────────────────────────────────────
  final blockedUsers = <ChatUser>[].obs;
  final blockedSearchResults = <ChatUser>[].obs;
  final isLoadingBlocked = false.obs;
  final blockedSearchQuery = ''.obs;

  // ── WebSocket ─────────────────────────────────────────────────────────────

  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSub;
  bool _wsIntentionalClose = false;
  Timer? _reconnectTimer;

  // ── Computed getters ──────────────────────────────────────────────────────

  List<ChatUser> get filteredUsers {
    if (searchQuery.value.isEmpty) return connectedUsers;
    final q = searchQuery.value.toLowerCase();
    return connectedUsers
        .where((u) =>
            u.fullName.toLowerCase().contains(q) ||
            u.username.toLowerCase().contains(q))
        .toList();
  }

  List<ChatThread> get filteredRecentChats {
    if (searchQuery.value.isEmpty) return recentChats;
    final q = searchQuery.value.toLowerCase();
    return recentChats
        .where((t) =>
            t.user.fullName.toLowerCase().contains(q) ||
            t.user.username.toLowerCase().contains(q))
        .toList();
  }

  List<ChatGroup> get filteredGroups {
    if (searchQuery.value.isEmpty) return groups;
    final q = searchQuery.value.toLowerCase();
    return groups.where((g) => g.name.toLowerCase().contains(q)).toList();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await loadConnectedUsers();
    await loadGroups();
    _setOnlineSafe();
    _connectWebSocket();
  }

  @override
  void onClose() {
    _wsIntentionalClose = true;
    _reconnectTimer?.cancel();
    _wsSub?.cancel();
    _wsChannel?.sink.close();
    messageCtrl.dispose();
    _setOfflineSafe();
    super.onClose();
  }

  // ── WebSocket connection (uses web_socket_channel — works on all platforms) ──

  Future<void> _connectWebSocket() async {
    try {
      final token = await StorageService.to.getAccessToken();
      if (token.isEmpty) return;

      // Convert http(s) base URL to ws(s) URL
      String wsBase = AppConstants.kBaseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');

      final wsUrl = Uri.parse('$wsBase/api/ws/chat/?token=$token');

      _wsChannel = WebSocketChannel.connect(wsUrl);
      await _wsChannel!.ready;
      debugPrint('[ChatWS] Connected');

      _wsSub = _wsChannel!.stream.listen(
        (data) => _handleWsMessage(data),
        onDone: () {
          debugPrint('[ChatWS] Connection closed');
          _scheduleReconnect();
        },
        onError: (error) {
          debugPrint('[ChatWS] Error: $error');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('[ChatWS] Failed to connect: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_wsIntentionalClose) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), _connectWebSocket);
  }

  void _handleWsMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String? ?? '';

      if (type == 'chat_message' || type == 'new_message') {
        final msg = Conversation.fromJson(data['message'] as Map<String, dynamic>);
        // Add to current conversation if relevant
        if (selectedUser.value != null &&
            (msg.fromUser.id == selectedUser.value!.id ||
             msg.toUser.id == selectedUser.value!.id)) {
          currentMessages.add(msg);
        }
      } else if (type == 'group_message') {
        final msg = GroupMessage.fromJson(data['message'] as Map<String, dynamic>);
        if (selectedGroup.value != null && msg.groupId == selectedGroup.value!.id) {
          currentGroupMessages.add(msg);
        }
      }
    } catch (e) {
      debugPrint('[ChatWS] Parse error: $e');
    }
  }

  // ── Users & Groups loading ────────────────────────────────────────────────

  Future<void> loadConnectedUsers() async {
    try {
      isLoadingUsers.value = true;
      final users = await _repo.getConnectedUsers();
      connectedUsers.assignAll(users);
      await loadRecentChats();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// Load recent conversations, group by the other user, keep last message.
  Future<void> loadRecentChats() async {
    try {
      final allMsgs = await _repo.getRecentConversations();
      if (allMsgs.isEmpty) {
        recentChats.clear();
        return;
      }

      // Determine current user id from first message
      // The current user is the one who appears in both from_user and to_user across messages
      final firstMsg = allMsgs.first;
      int? myId;
      // Heuristic: count which user id appears most as from_user
      final fromCounts = <int, int>{};
      for (final m in allMsgs) {
        fromCounts[m.fromUser.id] = (fromCounts[m.fromUser.id] ?? 0) + 1;
      }
      myId = fromCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      // Group messages by the OTHER user
      final threadMap = <int, ChatThread>{};
      for (final msg in allMsgs) {
        final otherUser = msg.fromUser.id == myId ? msg.toUser : msg.fromUser;
        final existing = threadMap[otherUser.id];
        if (existing == null) {
          threadMap[otherUser.id] = ChatThread(
            user: otherUser,
            lastMessage: msg,
            unreadCount: (msg.toUser.id == myId && !msg.isRead) ? 1 : 0,
          );
        } else {
          // Keep the most recent message
          if (msg.createdAt.isAfter(existing.lastMessage!.createdAt)) {
            existing.lastMessage = msg;
          }
          if (msg.toUser.id == myId && !msg.isRead) {
            existing.unreadCount++;
          }
        }
      }

      // Sort by most recent first
      final threads = threadMap.values.toList()
        ..sort((a, b) =>
            (b.lastMessage?.createdAt ?? DateTime(2000))
                .compareTo(a.lastMessage?.createdAt ?? DateTime(2000)));

      recentChats.assignAll(threads);
    } catch (e) {
      // If recent conversations fail, just leave empty — not critical
      debugPrint('[Chat] loadRecentChats error: $e');
    }
  }

  Future<void> loadGroups() async {
    try {
      final list = await _repo.getGroups();
      groups.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  Future<void> selectUser(ChatUser user) async {
    selectedUser.value = user;
    selectedGroup.value = null;
    await loadConversation(user.id);
    _markReadSafe(user.id);
  }

  Future<void> selectGroup(ChatGroup group) async {
    selectedGroup.value = group;
    selectedUser.value = null;
    await loadGroupMessages(group.id);
  }

  void clearSelection() {
    selectedUser.value = null;
    selectedGroup.value = null;
    currentMessages.clear();
    currentGroupMessages.clear();
  }

  // ── Conversation ──────────────────────────────────────────────────────────

  Future<void> loadConversation(int userId) async {
    try {
      isLoadingMessages.value = true;
      final msgs = await _repo.getConversation(userId);
      currentMessages.assignAll(msgs);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> loadGroupMessages(String groupId) async {
    try {
      isLoadingMessages.value = true;
      final detail = await _repo.getGroupDetail(groupId);

      // Update the selected group with full detail if available
      if (detail.containsKey('group')) {
        selectedGroup.value =
            ChatGroup.fromJson(detail['group'] as Map<String, dynamic>);
      }

      final messages = (detail['messages'] as List<dynamic>?)
              ?.map((m) => GroupMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
      currentGroupMessages.assignAll(messages);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // ── Send messages ─────────────────────────────────────────────────────────

  Future<void> sendMessage() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty || selectedUser.value == null) return;

    try {
      isSending.value = true;
      final msg = await _repo.sendMessage(
        toUserId: selectedUser.value!.id,
        message: text,
        replyId: replyingTo.value?.id,
      );
      currentMessages.add(msg);
      messageCtrl.clear();
      cancelReply();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendGroupMessage() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty || selectedGroup.value == null) return;

    try {
      isSending.value = true;
      final msg = await _repo.sendGroupMessage(
        groupId: selectedGroup.value!.id,
        message: text,
      );
      currentGroupMessages.add(msg);
      messageCtrl.clear();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    } finally {
      isSending.value = false;
    }
  }

  // ── Reply ─────────────────────────────────────────────────────────────────

  void replyToMessage(Conversation msg) {
    replyingTo.value = msg;
  }

  void cancelReply() {
    replyingTo.value = null;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteMessage(int id) async {
    try {
      await _repo.deleteMessage(id);
      currentMessages.removeWhere((m) => m.id == id);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  // ── Search users ──────────────────────────────────────────────────────────

  Future<List<ChatUser>> searchUsers(String query) async {
    try {
      return await _repo.searchUsers(query: query);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
      return [];
    }
  }

  // ── Create group ──────────────────────────────────────────────────────────

  Future<void> createGroup(String name, List<int> userIds) async {
    try {
      await _repo.createGroup(name: name, userIds: userIds);
      await loadGroups();
      Get.snackbar('Success', 'Group created successfully');
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  // ── Invitations ──────────────────────────────────────────────────────────

  Future<void> loadInvitations() async {
    try {
      isLoadingInv.value = true;
      final list = await _repo.getInvitations();
      invitations.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    } finally {
      isLoadingInv.value = false;
    }
  }

  Future<void> searchInvitationUsers() async {
    if (invSearchQuery.value.trim().isEmpty) {
      invSearchResults.clear();
      return;
    }
    try {
      final users = await _repo.searchUsers(
        query: invSearchQuery.value,
        userType: invUserType.value == 'all' ? null : invUserType.value,
      );
      // Exclude already-invited users
      final invitedIds = invitations
          .map((i) => i.toUser.id)
          .toSet();
      invSearchResults.assignAll(users.where((u) => !invitedIds.contains(u.id)));
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  Future<void> sendInvitation(int toUserId) async {
    try {
      await _repo.sendInvitation(toUserId);
      Get.snackbar('Success', 'Invitation sent');
      invSearchResults.removeWhere((u) => u.id == toUserId);
      await loadInvitations();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  Future<void> acceptInvitation(int invId) async {
    try {
      await _repo.acceptInvitation(invId);
      Get.snackbar('Success', 'Invitation accepted');
      await loadInvitations();
      await loadConnectedUsers();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  Future<void> declineInvitation(int invId) async {
    try {
      await _repo.declineInvitation(invId);
      Get.snackbar('Success', 'Invitation declined');
      await loadInvitations();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  // ── Blocked users ────────────────────────────────────────────────────────

  Future<void> loadBlockedUsers() async {
    try {
      isLoadingBlocked.value = true;
      final list = await _repo.getBlockedUsers();
      blockedUsers.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    } finally {
      isLoadingBlocked.value = false;
    }
  }

  Future<void> searchBlockableUsers() async {
    if (blockedSearchQuery.value.trim().isEmpty) {
      blockedSearchResults.clear();
      return;
    }
    try {
      final users = await _repo.searchUsers(query: blockedSearchQuery.value);
      final blockedIds = blockedUsers.map((u) => u.id).toSet();
      blockedSearchResults.assignAll(users.where((u) => !blockedIds.contains(u.id)));
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  Future<void> blockUser(int userId) async {
    try {
      await _repo.blockUser(userId);
      Get.snackbar('Success', 'User blocked');
      blockedSearchResults.removeWhere((u) => u.id == userId);
      await loadBlockedUsers();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  Future<void> unblockUser(int userId) async {
    try {
      await _repo.unblockUser(userId);
      Get.snackbar('Success', 'User unblocked');
      await loadBlockedUsers();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e));
    }
  }

  // ── Online status helpers (fire-and-forget) ───────────────────────────────

  void _setOnlineSafe() {
    _repo.setOnline().catchError((_) {});
  }

  void _setOfflineSafe() {
    _repo.setOffline().catchError((_) {});
  }

  void _markReadSafe(int userId) {
    _repo.markRead(userId).catchError((_) {});
  }
}
