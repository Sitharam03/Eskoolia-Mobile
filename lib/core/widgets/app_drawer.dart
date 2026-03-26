import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/menu_data.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9FBFF),
      child: SafeArea(
        child: Column(
          children: [
            // Brand Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Eskoolia',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            
            // Menu Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: MenuData.items.length,
                itemBuilder: (context, index) {
                  return _SidebarSection(
                    item: MenuData.items[index],
                    depth: 0,
                  );
                },
              ),
            ),
            
            // Logout Button at Bottom
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              title: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                // To be wired to AuthService.logout()
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final SidebarItem item;
  final int depth;

  const _SidebarSection({required this.item, required this.depth});

  bool _isRouteActive(String currentRoute, String? route) {
    if (route == null) return false;
    if (currentRoute == route) return true;
    return currentRoute.startsWith('$route/');
  }

  bool _hasActiveDescendant(String currentRoute, SidebarItem node) {
    if (_isRouteActive(currentRoute, node.route)) return true;
    if (node.children == null || node.children!.isEmpty) return false;
    return node.children!.any((child) => _hasActiveDescendant(currentRoute, child));
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isActiveOrHasActiveChild = _hasActiveDescendant(currentRoute, item);
    
    // Padding increases with depth to indent subgroups
    final double paddingLeft = 16.0 + (depth * 24.0);
    
    // Icon configuration
    IconData? iconData;
    if (item.iconCodePoint != null) {
      iconData = IconData(item.iconCodePoint!, fontFamily: 'MaterialIcons');
    }

    if (!hasChildren) {
      // Leaf Node (Clickable link)
      final isActive = _isRouteActive(currentRoute, item.route);
      return ListTile(
        contentPadding: EdgeInsets.only(left: paddingLeft, right: 16.0),
        minLeadingWidth: 24,
        leading: iconData != null
            ? Icon(
                iconData,
                color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
                size: depth == 0 ? 22 : 18,
              )
            : SizedBox(width: depth == 0 ? 22 : 18),
        title: Text(
          item.name,
          style: GoogleFonts.inter(
            fontSize: depth == 0 ? 15 : 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF374151),
          ),
        ),
        tileColor: isActive ? const Color(0xFFEEF2FF) : null,
        onTap: () {
          Get.back(); // close drawer
          if (item.route != null && currentRoute != item.route) {
            Get.offNamed(item.route!); // navigate without keeping huge backstack
          }
        },
      );
    }

    // Node with children (Expandable group)
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // removes lines
      child: ExpansionTile(
        initiallyExpanded: isActiveOrHasActiveChild, // auto expand if child is active
        tilePadding: EdgeInsets.only(left: paddingLeft, right: 16.0),
        leading: iconData != null
            ? Icon(
                iconData,
                color: isActiveOrHasActiveChild ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
                size: 22,
              )
            : null,
        title: Text(
          item.name,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: isActiveOrHasActiveChild ? FontWeight.w600 : FontWeight.w500,
            color: isActiveOrHasActiveChild ? const Color(0xFF4F46E5) : const Color(0xFF1F2937),
          ),
        ),
        iconColor: const Color(0xFF4F46E5),
        collapsedIconColor: const Color(0xFF6B7280),
        children: item.children!
            .map((child) => _SidebarSection(item: child, depth: depth + 1))
            .toList(),
      ),
    );
  }
}
