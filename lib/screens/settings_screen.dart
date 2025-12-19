import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/settings_tile.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _currentNavIndex = 3;

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppStyles.heading2,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.textDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // User Profile Card
            _buildUserProfileCard(),
            const SizedBox(height: 16),
            // GENERAL Section
            _buildSectionHeader('GENERAL'),
            _buildGeneralSection(),
            const SizedBox(height: 16),
            // INFORMATION Section
            _buildSectionHeader('INFORMATION'),
            _buildInformationSection(),
            const SizedBox(height: 16),
            // Log Out Button
            _buildLogOutButton(),
            const SizedBox(height: 16),
            // Footer
            _buildFooter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigate to Home
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          } else {
            setState(() {
              _currentNavIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return GestureDetector(
      onTap: _navigateToProfile,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.avatarOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.avatarOrange.withRed(200),
                      size: 32,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.onlineGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jane Doe',
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Student • Bachelors of IT',
                    style: AppStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: AppStyles.sectionHeader,
      ),
    );
  }

  Widget _buildGeneralSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            SettingsTileWithSwitch(
              icon: Icons.notifications,
              iconBackgroundColor: AppColors.iconBlueBg,
              iconColor: AppColors.primaryBlue,
              title: 'Notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SettingsTileWithChevron(
              icon: Icons.lock,
              iconBackgroundColor: AppColors.iconGreenBg,
              iconColor: AppColors.success,
              title: 'Security & PIN',
              onTap: () {},
            ),
            SettingsTileWithValue(
              icon: Icons.language,
              iconBackgroundColor: AppColors.iconBlueBg,
              iconColor: AppColors.primaryBlue,
              title: 'Language',
              value: 'English',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            SettingsTileWithChevron(
              icon: Icons.help_outline,
              iconBackgroundColor: AppColors.iconRedBg,
              iconColor: AppColors.danger,
              title: 'Help & Support',
              onTap: () {},
            ),
            SettingsTileWithChevron(
              icon: Icons.shield_outlined,
              iconBackgroundColor: AppColors.iconBlueBg,
              iconColor: AppColors.primaryBlue,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            SettingsTileWithChevron(
              icon: Icons.description_outlined,
              iconBackgroundColor: AppColors.iconGrayBg,
              iconColor: AppColors.textGray,
              title: 'Terms of Service',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle logout
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Log Out',
                style: AppStyles.dangerButtonText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Report Safely for MUST',
        style: AppStyles.bodySmall.copyWith(
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
