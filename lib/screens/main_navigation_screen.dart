import 'package:flutter/material.dart';
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
                  activeIcon: Icons.home_rounded,
                  inactiveIcon: Icons.home_outlined,
                  label: 'Home',
                ),
                // 2. Communities
                _buildNavItem(
                  index: 1,
                  activeIcon: Icons.groups_rounded,
                  inactiveIcon: Icons.groups_outlined,
                  label: 'Groups',
                ),
                // 3. Create (Middle Accent button)
                _buildCreateNavItem(),
                // 4. Search
                _buildNavItem(
                  index: 3,
                  activeIcon: Icons.search_rounded,
                  inactiveIcon: Icons.search_rounded, // search is solid usually
                  label: 'Search',
                ),
                // 5. Profile
                _buildNavItem(
                  index: 4,
                  activeIcon: Icons.person_rounded,
                  inactiveIcon: Icons.person_outline_rounded,
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

    Widget childWidget;
    
    if (index == 4) {
      // Profile Tab: Instagram-style circular avatar
      final borderCol = isSelected ? activeColor : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder);
      childWidget = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderCol,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF222222) : const Color(0xFFE1E8ED),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.person_rounded,
            size: 16,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF536471),
          ),
        ),
      );    } else {
      // Standard Tab: Icon
      childWidget = Icon(
        isSelected ? activeIcon : inactiveIcon,
        color: isSelected ? activeColor : inactiveColor,
        size: 28,
      );
    }

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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppTheme.primaryBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.add_rounded,
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
