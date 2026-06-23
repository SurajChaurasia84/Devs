import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'communities_screen.dart';
import 'create_post_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Change active index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Navigate back to home feed (e.g. after post creation)
  void _navigateToHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final theme = Theme.of(context);

    // List of screens corresponding to bottom nav tabs
    final List<Widget> screens = [
      const HomeScreen(),
      const CommunitiesScreen(),
      CreatePostScreen(onPostPublished: _navigateToHome),
      const SearchScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: borderCol, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Home
                _buildNavItem(
                  index: 0,
                  activeIcon: LucideIcons.home,
                  inactiveIcon: LucideIcons.home,
                  label: 'Home',
                ),
                // 2. Communities
                _buildNavItem(
                  index: 1,
                  activeIcon: LucideIcons.users,
                  inactiveIcon: LucideIcons.users,
                  label: 'Groups',
                ),
                // 3. Create (Middle Accent button)
                _buildCreateNavItem(),
                // 4. Search
                _buildNavItem(
                  index: 3,
                  activeIcon: LucideIcons.search,
                  inactiveIcon: LucideIcons.search,
                  label: 'Search',
                ),
                // 5. Profile
                _buildNavItem(
                  index: 4,
                  activeIcon: Iconsax.profile_circle,
                  inactiveIcon: Iconsax.profile_circle,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppTheme.primaryBlue;
    final inactiveColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    // Standard Tab: Icon
    Widget childWidget = Icon(
      isSelected ? activeIcon : inactiveIcon,
      color: isSelected ? activeColor : inactiveColor,
      size: 26,
    );

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 48,
        child: Center(
          child: childWidget,
        ),
      ),
    );
  }

  Widget _buildCreateNavItem() {
    final isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppTheme.primaryBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          LucideIcons.plus,
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
