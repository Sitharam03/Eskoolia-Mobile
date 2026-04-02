import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/chat_controller.dart';
import '../../../core/widgets/school_loader.dart';
import 'chat_sidebar.dart';
import 'chat_window.dart';
import 'user_search_modal.dart';
import 'invitation_tab.dart';
import 'blocked_users_tab.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CHAT VIEW — main chat page with sidebar + chat window
// ═══════════════════════════════════════════════════════════════════════════════

const _kPri = Color(0xFF6366F1);
const _kVio = Color(0xFF7C3AED);

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  // ── Responsive breakpoint ──
  static const double _wideBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= _wideBreakpoint;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // On narrow: if a chat is open, go back to sidebar
        if (!isWide && _hasChatSelected) {
          controller.clearSelection();
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F3FF),
          appBar: _buildAppBar(context),
          body: Stack(
            children: [
              // ── Background decorative circles ──
              Positioned(
                right: -60, top: -30,
                child: Container(width: 180, height: 180,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: _kPri.withValues(alpha: 0.04))),
              ),
              Positioned(
                left: -40, bottom: 80,
                child: Container(width: 120, height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: _kVio.withValues(alpha: 0.04))),
              ),
              // ── Floating chat-themed particles ──
              const Positioned.fill(
                child: IgnorePointer(child: _ChatParticles()),
              ),
              // ── School scene (bus, children) ──
              const Positioned.fill(
                child: IgnorePointer(child: _ChatSchoolScene()),
              ),
              // ── Module tabs + main content ──
              Column(
                children: [
                  // ── Tab selector (Chat / Invitation / Blocked) ──
                  _buildModuleTabs(),
                  // ── Tab content ──
                  Expanded(
                    child: Obx(() {
                      if (controller.moduleTab.value == 1) {
                        return const InvitationTab();
                      }
                      if (controller.moduleTab.value == 2) {
                        return const BlockedUsersTab();
                      }
                      // Tab 0 = Chat
                      if (controller.isLoadingUsers.value) {
                        return const Center(child: SchoolLoader(message: 'Loading chats...'));
                      }
                      if (isWide) return _buildWideLayout();
                      return _buildNarrowLayout();
                    }),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: Obx(() => _buildFab(context) ?? const SizedBox.shrink()),
        ),
      ),
    );
  }

  // ── Check if a conversation or group is selected ──
  bool get _hasChatSelected =>
      controller.selectedUser.value != null ||
      controller.selectedGroup.value != null;

  // ── Module tabs (Chat / Invitation / Blocked) ──
  Widget _buildModuleTabs() {
    const tabs = ['Chat', 'Invitations', 'Blocked'];
    const icons = [Icons.chat_rounded, Icons.mail_rounded, Icons.block_rounded];
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF5F3FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: _kPri.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Obx(() => Row(
            children: List.generate(tabs.length, (i) {
              final active = controller.moduleTab.value == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => controller.moduleTab.value = i,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                                colors: [_kPri, _kVio])
                            : null,
                        color: active
                            ? null
                            : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: active
                            ? null
                            : Border.all(
                                color: _kPri.withValues(alpha: 0.10)),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color:
                                      _kPri.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icons[i],
                              size: 15,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF6B7280)),
                          const SizedBox(width: 5),
                          Text(
                            tabs[i],
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          )),
    );
  }

  // ── Gradient AppBar matching app_scaffold pattern ──
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 60,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kPri, Color(0xFF4F46E5), _kVio],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -15,
              bottom: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Get.offAllNamed(AppRoutes.dashboard),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.chat_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Chat',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kPri.withValues(alpha: 0.0),
                const Color(0xFF818CF8).withValues(alpha: 0.5),
                _kPri.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Wide layout: sidebar + chat window side by side ──
  Widget _buildWideLayout() {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: ChatSidebar(),
        ),
        // Vertical divider
        Container(
          width: 1,
          color: _kPri.withValues(alpha: 0.08),
        ),
        Expanded(
          child: Obx(() {
            if (!_hasChatSelected) {
              return _buildEmptyState();
            }
            return ChatWindow();
          }),
        ),
      ],
    );
  }

  // ── Narrow layout: sidebar or chat window ──
  Widget _buildNarrowLayout() {
    return Obx(() {
      if (_hasChatSelected) {
        return ChatWindow();
      }
      return ChatSidebar();
    });
  }

  // ── Empty state when no chat selected ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient circle with chat icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kPri.withValues(alpha: 0.12),
                  _kVio.withValues(alpha: 0.18),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _kPri.withValues(alpha: 0.08),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kPri, _kVio],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kPri.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Select a conversation',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Choose a chat from the sidebar or start a new conversation with a teacher, student, or group.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Decorative school icons row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _emptyStateIcon(Icons.school_rounded, 0),
              const SizedBox(width: 12),
              _emptyStateIcon(Icons.chat_bubble_outline_rounded, 1),
              const SizedBox(width: 12),
              _emptyStateIcon(Icons.group_rounded, 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyStateIcon(IconData icon, int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF7C3AED),
      const Color(0xFF818CF8),
    ];
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors[index].withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: colors[index], size: 20),
    );
  }

  // ── FAB to start new chat ──
  Widget? _buildFab(BuildContext context) {
    // Hide FAB when a chat/group is open (it overlaps the input bar)
    if (controller.selectedUser.value != null ||
        controller.selectedGroup.value != null) {
      return null;
    }
    // Also hide on invitation/blocked tabs
    if (controller.moduleTab.value != 0) return null;

    return FloatingActionButton(
      onPressed: () => _showUserSearchModal(context),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kPri, _kVio],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _kPri.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  void _showUserSearchModal(BuildContext context) {
    showUserSearchModal(context);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHAT PARTICLES — floating chat-themed icons
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatParticles extends StatefulWidget {
  const _ChatParticles();
  @override
  State<_ChatParticles> createState() => _ChatParticlesState();
}

class _ChatParticlesState extends State<_ChatParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _icons = [
    (Icons.chat_bubble_rounded, 0.08, 18.0, 0.0),
    (Icons.forum_rounded, 0.85, 16.0, 0.15),
    (Icons.message_rounded, 0.22, 14.0, 0.30),
    (Icons.send_rounded, 0.70, 16.0, 0.45),
    (Icons.mark_chat_read_rounded, 0.48, 14.0, 0.60),
    (Icons.chat_outlined, 0.90, 15.0, 0.75),
    (Icons.textsms_rounded, 0.35, 13.0, 0.88),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Stack(
        children: _icons.map((p) {
          final (icon, xFrac, sz, phase) = p;
          final t = (_ctrl.value + phase) % 1.0;
          final y = h * (1.0 - t * 0.85);
          final opacity = t < 0.12 ? t / 0.12 : t > 0.78 ? (1.0 - t) / 0.22 : 1.0;
          return Positioned(
            left: xFrac * w, top: y,
            child: Opacity(
              opacity: (opacity * 0.12).clamp(0.0, 1.0),
              child: Icon(icon, color: _kPri, size: sz),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCHOOL SCENE — bus, children, buildings (chat version)
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatSchoolScene extends StatefulWidget {
  const _ChatSchoolScene();
  @override
  State<_ChatSchoolScene> createState() => _ChatSchoolSceneState();
}

class _ChatSchoolSceneState extends State<_ChatSchoolScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  static double _sin(double x) {
    x = x % 6.283;
    if (x > 3.1416) x -= 6.283;
    final x2 = x * x;
    return x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    const c = _kPri;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final busX = (t * (w + 120)) - 60;
        final bus2X = w - (((t * 0.7 + 0.5) % 1.0) * (w + 100)) + 50;
        final b1 = 6.0 * _sin(t * 12.566);
        final b2 = 5.0 * _sin((t + 0.25) * 12.566);
        final b3 = 7.0 * _sin((t + 0.5) * 12.566);
        final b4 = 4.0 * _sin((t + 0.75) * 12.566);
        final ballY = 18.0 * _sin(t * 18.85).abs();
        final birdX = ((t * 1.4) % 1.0) * (w + 40) - 20;
        final birdY = h * 0.08 + 8.0 * _sin(t * 9.42);

        return Stack(children: [
          // Ground strip
          Positioned(left: 0, right: 0, bottom: 0, height: 36,
            child: Container(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [c.withValues(alpha: 0.0), c.withValues(alpha: 0.06), c.withValues(alpha: 0.10)]),
            ))),
          // Road
          Positioned(left: 0, right: 0, bottom: 18,
            child: Container(height: 1.5, color: c.withValues(alpha: 0.08))),
          // School
          Positioned(left: 8, bottom: 20,
            child: Icon(Icons.school_rounded, size: 44, color: c.withValues(alpha: 0.10))),
          // Trees
          Positioned(right: 12, bottom: 20,
            child: Icon(Icons.park_rounded, size: 38, color: c.withValues(alpha: 0.08))),
          Positioned(left: w * 0.38, bottom: 20,
            child: Icon(Icons.nature_rounded, size: 30, color: c.withValues(alpha: 0.06))),
          Positioned(right: w * 0.3, bottom: 22,
            child: Icon(Icons.forest_rounded, size: 32, color: c.withValues(alpha: 0.05))),
          // Buses
          Positioned(left: busX, bottom: 20,
            child: Icon(Icons.directions_bus_rounded, size: 36, color: c.withValues(alpha: 0.14))),
          Positioned(left: bus2X, bottom: 28,
            child: Icon(Icons.airport_shuttle_rounded, size: 24, color: c.withValues(alpha: 0.08))),
          // Playing children
          Positioned(left: w * 0.15, bottom: 36 + b1,
            child: Icon(Icons.directions_run_rounded, size: 28, color: c.withValues(alpha: 0.12))),
          Positioned(left: w * 0.32, bottom: 36 + b2,
            child: Icon(Icons.directions_walk_rounded, size: 26, color: c.withValues(alpha: 0.10))),
          Positioned(left: w * 0.62, bottom: 38 + b3,
            child: Icon(Icons.boy_rounded, size: 28, color: c.withValues(alpha: 0.11))),
          Positioned(left: w * 0.82, bottom: 36 + b4,
            child: Icon(Icons.girl_rounded, size: 26, color: c.withValues(alpha: 0.09))),
          // Ball
          Positioned(left: w * 0.48, bottom: 38 + ballY,
            child: Icon(Icons.sports_soccer_rounded, size: 16, color: c.withValues(alpha: 0.12))),
          // Teacher
          Positioned(right: 16, top: h * 0.18,
            child: Icon(Icons.cast_for_education_rounded, size: 30, color: c.withValues(alpha: 0.06))),
          // Books
          Positioned(left: 12, top: h * 0.40,
            child: Icon(Icons.auto_stories_rounded, size: 26, color: c.withValues(alpha: 0.05))),
          // Birds
          Positioned(left: birdX, top: birdY,
            child: Icon(Icons.flutter_dash, size: 20, color: c.withValues(alpha: 0.07))),
          Positioned(left: birdX - 30, top: birdY + 12,
            child: Icon(Icons.flutter_dash, size: 14, color: c.withValues(alpha: 0.05))),
        ]);
      },
    );
  }
}
