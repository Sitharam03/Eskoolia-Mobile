import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_models.dart';
import '../../../core/widgets/school_loader.dart';

// ── Theme constants ─────────────────────────────────────────────────────────
const _kPri = Color(0xFF6366F1);
const _kVio = Color(0xFF7C3AED);

const _kAvatarPalette = [
  Color(0xFF6366F1),
  Color(0xFF7C3AED),
  Color(0xFF06B6D4),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF10B981),
];

Color _accentFor(String name) =>
    _kAvatarPalette[name.isEmpty ? 0 : name.codeUnitAt(0) % 6];

// ── Search Mode ─────────────────────────────────────────────────────────────

enum ChatSearchMode { single, group }

// ── Show helper ─────────────────────────────────────────────────────────────

Future<void> showUserSearchModal(
  BuildContext context, {
  ChatSearchMode mode = ChatSearchMode.single,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _UserSearchSheet(mode: mode),
  );
}

// ── Main Sheet ──────────────────────────────────────────────────────────────

class _UserSearchSheet extends StatefulWidget {
  final ChatSearchMode mode;
  const _UserSearchSheet({required this.mode});

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final _ctrl = Get.find<ChatController>();
  final _searchCtrl = TextEditingController();
  final _groupNameCtrl = TextEditingController();

  final _results = <ChatUser>[];
  final _selectedIds = <int>{};
  bool _loading = false;
  String _filter = 'All'; // All | Students | Staff
  String _query = '';

  static const _filters = ['All', 'Students', 'Staff'];

  @override
  void initState() {
    super.initState();
    _doSearch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _groupNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    setState(() => _loading = true);
    try {
      final users = await _ctrl.searchUsers(_query);
      if (!mounted) return;

      setState(() {
        _results.clear();
        if (_filter == 'All') {
          _results.addAll(users);
        } else {
          final type = _filter == 'Students' ? 'student' : 'staff';
          _results.addAll(users.where((u) => u.userType == type));
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String val) {
    _query = val.trim();
    _doSearch();
  }

  void _onFilterTap(String f) {
    if (_filter == f) return;
    setState(() => _filter = f);
    _doSearch();
  }

  void _onUserTap(ChatUser user) {
    if (widget.mode == ChatSearchMode.single) {
      Navigator.pop(context);
      _ctrl.selectUser(user);
    } else {
      setState(() {
        if (_selectedIds.contains(user.id)) {
          _selectedIds.remove(user.id);
        } else {
          _selectedIds.add(user.id);
        }
      });
    }
  }

  Future<void> _createGroup() async {
    final name = _groupNameCtrl.text.trim();
    if (name.isEmpty || _selectedIds.isEmpty) {
      Get.snackbar('Missing info', 'Please enter a group name and select members');
      return;
    }
    Navigator.pop(context);
    await _ctrl.createGroup(name, _selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isGroup = widget.mode == ChatSearchMode.group;

    return Container(
      constraints: BoxConstraints(maxHeight: h * 0.88),
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Gradient top strip + drag handle ─────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF0EDFF),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [_kPri, _kVio],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  isGroup ? 'Create Group' : 'New Chat',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),

          // ── Group name input (group mode) ────────────────────────
          if (isGroup)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _groupNameCtrl,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Group name',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(Icons.group_rounded,
                        size: 20, color: _kPri.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),

          // ── Filter pills ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.map((f) {
                final active = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _onFilterTap(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: active
                            ? const LinearGradient(colors: [_kPri, _kVio])
                            : null,
                        color: active ? null : Colors.grey.shade50,
                        border: active
                            ? null
                            : Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        f,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Search input ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 20, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Selected count (group mode) ──────────────────────────
          if (isGroup && _selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_selectedIds.length} member${_selectedIds.length > 1 ? 's' : ''} selected',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kPri,
                  ),
                ),
              ),
            ),

          // ── User list ────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const SchoolLoader(message: 'Searching users...')
                : _results.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        itemCount: _results.length,
                        itemBuilder: (_, i) =>
                            _buildUserTile(_results[i]),
                      ),
          ),

          // ── Create group button (group mode) ────────────────────
          if (isGroup)
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: _selectedIds.isNotEmpty
                          ? const LinearGradient(colors: [_kPri, _kVio])
                          : null,
                      color: _selectedIds.isEmpty
                          ? Colors.grey.shade200
                          : null,
                    ),
                    child: MaterialButton(
                      onPressed:
                          _selectedIds.isEmpty ? null : _createGroup,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Create Group',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _selectedIds.isNotEmpty
                              ? Colors.white
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── User tile ────────────────────────────────────────────────────────────

  Widget _buildUserTile(ChatUser user) {
    final accent = _accentFor(user.fullName);
    final checked = _selectedIds.contains(user.id);
    final isGroup = widget.mode == ChatSearchMode.group;

    return InkWell(
      onTap: () => _onUserTap(user),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            // Checkbox (group mode)
            if (isGroup)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: checked
                        ? const LinearGradient(colors: [_kPri, _kVio])
                        : null,
                    border: checked
                        ? null
                        : Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: checked
                      ? const Icon(Icons.check_rounded,
                          size: 15, color: Colors.white)
                      : null,
                ),
              ),
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, accent.withValues(alpha: 0.7)],
                ),
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.email.isNotEmpty)
                    Text(
                      user.email,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Type badge
            if (user.userType != null && user.userType!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: user.userType == 'student'
                      ? const Color(0xFF06B6D4).withValues(alpha: 0.1)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                ),
                child: Text(
                  user.userType == 'student' ? 'Student' : 'Staff',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: user.userType == 'student'
                        ? const Color(0xFF06B6D4)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kPri.withValues(alpha: 0.12),
                  _kVio.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Icon(
              Icons.person_search_rounded,
              size: 30,
              color: _kPri.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _query.isEmpty ? 'Search for users' : 'No users found',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          if (_query.isNotEmpty)
            Text(
              'Try a different search term',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
        ],
      ),
    );
  }
}
