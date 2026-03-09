import 'dart:ui';
import 'package:flutter/material.dart';

class GlassNavigationDrawer extends StatelessWidget {
  const GlassNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 320,
      child: Stack(
        children: [
          // Glass Background
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13A4EC).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Safe Area
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    
                    // User Profile Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        border: Border(
                          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFF13A4EC),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF13A4EC).withOpacity(0.2),
                                      blurRadius: 16,
                                    ),
                                  ],
                                  color: Colors.grey.shade800,
                                ),
                                child: const Icon(Icons.person, size: 40, color: Colors.white54),
                                // Uncomment for actual image:
                                // child: ClipRRect(
                                //   borderRadius: BorderRadius.circular(22),
                                //   child: Image.network('url', fit: BoxFit.cover),
                                // ),
                              ),
                              Positioned(
                                bottom: -4,
                                right: -4,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF13A4EC),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF101E22),
                                      width: 4,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Alex Rivers',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'alex.rivers@bubbles.io',
                            style: TextStyle(
                              color: Color(0xFF13A4EC),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Navigation Menu
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Column(
                          children: [
                            _buildDrawerItem(
                              icon: Icons.home,
                              label: 'Home',
                              isActive: true,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _buildDrawerItem(
                              icon: Icons.auto_stories,
                              label: 'Library',
                              isActive: false,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _buildDrawerItem(
                              icon: Icons.notifications_active,
                              label: 'Alerts',
                              isActive: false,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _buildDrawerItem(
                              icon: Icons.person,
                              label: 'Profile',
                              isActive: false,
                              onTap: () {},
                            ),
                            
                            const SizedBox(height: 16),
                            Divider(color: Colors.white.withOpacity(0.1)),
                            const SizedBox(height: 16),
                            
                            _buildDrawerItem(
                              icon: Icons.settings,
                              label: 'Settings',
                              isActive: false,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _buildDrawerItem(
                              icon: Icons.help_outline,
                              label: 'Help & Support',
                              isActive: false,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Connection Status
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Connected',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF13A4EC).withOpacity(0.2) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? const Color(0xFF13A4EC).withOpacity(0.3) : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF13A4EC) : Colors.white54,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
