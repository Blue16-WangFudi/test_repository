import 'package:flutter/material.dart';
import 'widgets.dart';

// Custom Colors
const Color kBackgroundColor = Color(0xFFF2F5F9);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF2D3748);
const Color kSecondaryTextColor = Color(0xFF718096);
const Color kAccentColor = Color(0xFF6B8AFB);
const Color kMintGreen = Color(0xFFE6FFFA);
const Color kMintGreenText = Color(0xFF38B2AC);
const Color kLightYellow = Color(0xFFFFFBEB);
const Color kLightYellowText = Color(0xFFF6E05E);
const Color kLightBlue = Color(0xFFEBF8FF);
const Color kLightBlueText = Color(0xFF4299E1);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: const NeumorphicIconButton(icon: Icons.arrow_back_ios_new),
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kPrimaryTextColor,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: const [
          NeumorphicIconButton(icon: Icons.info_outline),
          SizedBox(width: 12),
          NeumorphicIconButton(icon: Icons.refresh),
          SizedBox(width: 12),
          NeumorphicIconButton(icon: Icons.calendar_today_outlined),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Southwest University',
                    style: TextStyle(
                      color: kAccentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: kAccentColor),
                ],
              ),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildAcademicSnapshot(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildAiAssistant(),
              const SizedBox(height: 24),
              _buildRecommended(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kAccentColor,
        unselectedItemColor: kSecondaryTextColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kCardColor,
        elevation: 10,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).toInt()),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search schedule, grades, events, errands',
          hintStyle: TextStyle(color: kSecondaryTextColor, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: kSecondaryTextColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildNeumorphicCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.04).toInt()),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withAlpha((255 * 0.6).toInt()),
            spreadRadius: -2,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAcademicSnapshot() {
    return _buildNeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Academic Snapshot',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: kPrimaryTextColor,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.update,
                      size: 14,
                      color: kSecondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Updated just now',
                      style: TextStyle(
                        color: kSecondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSnapshotItem('Weighted Avg', '88.5'),
                _buildSnapshotItem('Rank Est.', 'Top 10-15%'),
                _buildSnapshotItem('GPA', '3.82'),
                _buildSnapshotItem('Credits', '18/18'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kSecondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: kPrimaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return _buildNeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: kPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: const [
                _QuickActionItem(
                  icon: Icons.schedule,
                  label: 'Schedule',
                  color: Color(0xFF6B8AFB),
                ),
                _QuickActionItem(
                  icon: Icons.grade_outlined,
                  label: 'Grades',
                  color: Color(0xFF38B2AC),
                ),
                _QuickActionItem(
                  icon: Icons.credit_card_outlined,
                  label: 'Campus Card',
                  color: Color(0xFFF6E05E),
                ),
                _QuickActionItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Errands',
                  color: Color(0xFF4299E1),
                ),
                _QuickActionItem(
                  icon: Icons.star_border_outlined,
                  label: 'Events',
                  color: Color(0xFF38B2AC),
                ),
                _QuickActionItem(
                  icon: Icons.book_outlined,
                  label: 'Lectures',
                  color: Color(0xFFF6E05E),
                ),
                _QuickActionItem(
                  icon: Icons.work_outline,
                  label: 'Internships',
                  color: Color(0xFF4299E1),
                ),
                _QuickActionItem(
                  icon: Icons.support_agent_outlined,
                  label: 'AI Assistant',
                  color: Color(0xFF6B8AFB),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAssistant() {
    return _buildNeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Assistant',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: kPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Get things done in one sentence',
              style: TextStyle(color: kSecondaryTextColor, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                PillTag(
                  text: 'Find free time this week',
                  backgroundColor: kLightBlue,
                  textColor: kLightBlueText,
                ),
                PillTag(
                  text: 'Remind me tomorrow 8:00',
                  backgroundColor: kLightBlue,
                  textColor: kLightBlueText,
                ),
                PillTag(
                  text: 'Recommend campus events',
                  backgroundColor: kLightBlue,
                  textColor: kLightBlueText,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ask AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommended() {
    return _buildNeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: kPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              icon: Icons.calendar_today,
              color: kMintGreenText,
              title: 'Campus Music Festival',
              subtitle: 'Today, 18:00 ?Main Square',
              tags: [
                PillTag(
                  text: 'Free',
                  backgroundColor: kLightBlue,
                  textColor: kLightBlueText,
                ),
                PillTag(
                  text: 'Today',
                  backgroundColor: kLightYellow,
                  textColor: kLightYellowText,
                ),
              ],
            ),
            const Divider(color: kBackgroundColor, height: 20, thickness: 1),
            _buildRecommendationItem(
              icon: Icons.chat_bubble_outline,
              color: kAccentColor,
              title: 'Career Development Seminar',
              subtitle: 'Tomorrow, 14:00 ?Room 201',
              tags: [
                PillTag(
                  text: 'Register',
                  backgroundColor: kMintGreen,
                  textColor: kMintGreenText,
                ),
              ],
            ),
            const Divider(color: kBackgroundColor, height: 20, thickness: 1),
            _buildRecommendationItem(
              icon: Icons.auto_stories_outlined,
              color: kLightBlueText,
              title: 'New Library Services',
              subtitle: 'Available Now ?Central Library',
              tags: [
                PillTag(
                  text: 'New',
                  backgroundColor: kLightBlue,
                  textColor: kLightBlueText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<Widget> tags,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha((255 * 0.1).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: kSecondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Wrap(spacing: 4.0, runSpacing: 4.0, children: tags),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha((255 * 0.1).toInt()),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: kSecondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
