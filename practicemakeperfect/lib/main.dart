// main.dart
//
// Screens
// - ScorePage: score list + summary. On wide screens uses master-detail layout.
// - Course detail: on phone opens frosted dialog; on wide shows right-side panel.
//
// Notes
// - Chart: replaced flutter_chart ChartBar with a CustomPainter histogram to match p4 style
//   (grid + soft tinted background + multi-color buckets). This also avoids the “bars not showing” issue.
// - Existing data + logic kept; only layout + header style + chart section + info-card details adjusted.
//
// deps (pubspec.yaml)
//   flutter:
//     sdk: flutter
//   google_fonts: ^6.2.1

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

/// Avoid Color.withOpacity deprecations on newer SDKs.
Color withOpacitySafe(Color c, double opacity) {
  final a = (opacity.clamp(0.0, 1.0) * 255).round();
  return c.withAlpha(a);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1677FF)),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.notoSansScTextTheme(base.textTheme),
      ),
      home: const ScorePage(),
    );
  }
}

/// ------------------------------
/// Data models
/// ------------------------------

class Course {
  final String name;
  final double credit;
  final double score; // total score
  final double gpa;
  final String type;
  final String teacher;
  final String schoolYear; // 2025-2026
  final int term; // 1/2

  const Course({
    required this.name,
    required this.credit,
    required this.score,
    required this.gpa,
    required this.type,
    required this.teacher,
    required this.schoolYear,
    required this.term,
  });

  String get termLabel => '$schoolYear 第$term学期';
}

class ScoreComponent {
  final String title; // 平时/期中/实验/期末
  final int percent;
  final double score;
  final Color color;

  const ScoreComponent({
    required this.title,
    required this.percent,
    required this.score,
    required this.color,
  });
}

/// Histogram point.
class HistBar {
  final int x; // 50..100
  final double y; // 0..20-ish
  final Color color;

  const HistBar({required this.x, required this.y, required this.color});
}

/// ------------------------------
/// Breakpoints
/// ------------------------------

class Breakpoints {
  static bool isTablet(double w) => w >= 700 && w < 980;
  static bool isDesktop(double w) => w >= 980;
}

/// ------------------------------
/// Score Page (responsive master-detail)
/// ------------------------------

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  int tabIndex = 0;
  Course? selected; // used on wide screens

  // Data (from your excel, hard-coded)
  final List<Course> courses = const [
    Course(
      name: '算法设计基础',
      score: 90,
      credit: 2.0,
      gpa: 4.3,
      type: '专业必修课',
      teacher: '张里博',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '算法设计基础实验',
      score: 93,
      credit: 1.0,
      gpa: 4.6,
      type: '专业选修课',
      teacher: '张里博',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: 'PHOTOSHOP数字图像处理',
      score: 96,
      credit: 2.0,
      gpa: 4.8,
      type: '跨专业选修课',
      teacher: '毛春',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '马克思主义基本原理',
      score: 88,
      credit: 3.0,
      gpa: 4.0,
      type: '通识必修课',
      teacher: '万雪飞',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '大学物理实验',
      score: 94,
      credit: 1.5,
      gpa: 4.6,
      type: '学科必修课',
      teacher: '高子叶',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '最优化方法',
      score: 96,
      credit: 3.0,
      gpa: 4.8,
      type: '专业选修课',
      teacher: '张林霞',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '国家安全教育',
      score: 99,
      credit: 1.0,
      gpa: 5.0,
      type: '通识必修课',
      teacher: '孙一博;汪易玲;王惠娟',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '毛泽东思想和中国特色社会主义理论体系概论',
      score: 84,
      credit: 3.0,
      gpa: 3.6,
      type: '通识必修课',
      teacher: '汪易玲',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '数字电路',
      score: 79,
      credit: 3.0,
      gpa: 3.0,
      type: '专业必修课',
      teacher: '何晨',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '体育C(乒乓球)',
      score: 89,
      credit: 1.0,
      gpa: 4.0,
      type: '通识必修课',
      teacher: '体24',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '数据结构',
      score: 89,
      credit: 4.0,
      gpa: 4.0,
      type: '专业必修课',
      teacher: '刘亚风',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '大学英语ⅠC（学术英语听说）',
      score: 89,
      credit: 2.5,
      gpa: 4.0,
      type: '通识必修课',
      teacher: '马俊明',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '矩阵论',
      score: 93,
      credit: 3.0,
      gpa: 4.6,
      type: '专业选修课',
      teacher: '杨颂华',
      schoolYear: '2025-2026',
      term: 1,
    ),
    Course(
      name: '单片机技术',
      score: 92,
      credit: 3.0,
      gpa: 4.3,
      type: '专业选修课',
      teacher: '杨颂华',
      schoolYear: '2025-2026',
      term: 1,
    ),
  ];

  String get termLabel => '2025-2026 第1学期';

  double get totalCredits => courses.fold(0.0, (a, b) => a + b.credit);

  double get weightedAvgScore {
    if (totalCredits == 0) return 0;
    final s = courses.fold(0.0, (a, c) => a + c.score * c.credit);
    return s / totalCredits;
  }

  double get weightedGpa {
    if (totalCredits == 0) return 0;
    final s = courses.fold(0.0, (a, c) => a + c.gpa * c.credit);
    return s / totalCredits;
  }

  int get passCount => courses.where((c) => c.score >= 60).length;

  Color _scoreBg(double score) {
    if (score < 60) return const Color(0xFFFFE8E8);
    if (score < 80) return const Color(0xFFFFF0DE);
    if (score >= 85) return const Color(0xFFE5F3FF);
    return const Color(0xFFEAF7E9);
  }

  Color _scoreText(double score) {
    if (score < 60) return const Color(0xFFE53935);
    if (score < 80) return const Color(0xFFFB8C00);
    if (score >= 85) return const Color(0xFF1677FF);
    return const Color(0xFF2E7D32);
  }

  Widget _circleAction(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: const Color(0xFF666666)),
        ),
      ),
    );
  }

  Widget _segmentedTabs() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EBEF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _tabItem(0, '总体成绩'),
          _tabItem(1, '保研成绩'),
          _tabItem(2, '综测成绩'),
        ],
      ),
    );
  }

  Widget _tabItem(int idx, String text) {
    final selectedTab = tabIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selectedTab ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selectedTab ? FontWeight.w800 : FontWeight.w600,
              color: selectedTab ? Colors.black : const Color(0xFF8D8D8D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学业总结',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1677FF)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryMetric('加权平均分', weightedAvgScore.toStringAsFixed(0)),
              _summaryMetric('预计排名', '1-20'),
              _summaryMetric('绩点', weightedGpa.toStringAsFixed(2)),
              _summaryMetric('通过', '$passCount/${courses.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _pill({required String text, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: fg)),
    );
  }

  Widget _courseTile(Course c, {required bool isWide}) {
    final isSelected = isWide && selected?.name == c.name;

    return InkWell(
      onTap: () async {
        if (isWide) {
          setState(() => selected = c);
          return;
        }
        await showCourseDetailDialog(context, c);
      },
      child: Container(
        color: isSelected ? const Color(0xFFEEF4FF) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _scoreBg(c.score),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                c.score.toInt().toString(),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _scoreText(c.score)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${c.type}  ${c.teacher}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8D8D8D), height: 1.15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _pill(
                  text: '${c.credit.toStringAsFixed(1)} 学分',
                  bg: const Color(0xFFE5F3FF),
                  fg: const Color(0xFF1677FF),
                ),
                const SizedBox(height: 10),
                _pill(
                  text: '${c.gpa.toStringAsFixed(1)} 绩点',
                  bg: const Color(0xFFEAF7E9),
                  fg: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Header to match sample p1 (top area) - used on phone/tablet list
  Widget _pageHeader() {
    return Column(
      children: [
        // top row: back + actions
        Row(
          children: [
            _circleAction(Icons.arrow_back, () {}),
            const Spacer(),
            _circleAction(Icons.info_outline, () {}),
            const SizedBox(width: 12),
            _circleAction(Icons.refresh, () {}),
            const SizedBox(width: 12),
            _circleAction(Icons.calendar_month_outlined, () {}),
          ],
        ),
        const SizedBox(height: 10),
        // second row: title + term label at right
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('成绩', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
            const Spacer(),
            Text(
              termLabel,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1677FF)),
            ),
          ],
        ),
      ],
    );
  }

  /// Wide header like sample p1: frosted full-width bar + actions + term + tabs
  Widget _wideTopHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: withOpacitySafe(const Color(0xFFF3F4F6), 0.90),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 18, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _circleAction(Icons.arrow_back, () {}),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '成绩',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _circleAction(Icons.info_outline, () {}),
                          const SizedBox(width: 10),
                          _circleAction(Icons.refresh, () {}),
                          const SizedBox(width: 10),
                          _circleAction(Icons.calendar_month_outlined, () {}),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        termLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1677FF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _segmentedTabs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftListPane({required bool isWide, bool includeHeader = true}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        if (includeHeader) ...[
          _pageHeader(),
          const SizedBox(height: 14),
          _segmentedTabs(),
          const SizedBox(height: 14),
        ],
        _summaryCard(),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < courses.length; i++) ...[
                _courseTile(courses[i], isWide: isWide),
                if (i != courses.length - 1)
                  const Divider(height: 1, thickness: 0.6, color: Color(0xFFEDEDED)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(w);

    // wide: master-detail
    if (isDesktop) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _wideTopHeader(),
              Expanded(
                child: Row(
                  children: [
                    // left list (no header/tabs here; they are in the top bar now)
                    Expanded(
                      flex: 6,
                      child: _leftListPane(isWide: true, includeHeader: false),
                    ),

                    // right detail (p4-like container)
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 14, 16, 18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: withOpacitySafe(Colors.white, 0.88),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 12)),
                                ],
                              ),
                              child: selected == null
                                  ? const _EmptyDetailPanel()
                                  : CourseDetailPanel(
                                course: selected!,
                                onPrev: () {
                                  final idx = courses.indexWhere((e) => e.name == selected!.name);
                                  if (idx <= 0) return;
                                  setState(() => selected = courses[idx - 1]);
                                },
                                onNext: () {
                                  final idx = courses.indexWhere((e) => e.name == selected!.name);
                                  if (idx < 0 || idx >= courses.length - 1) return;
                                  setState(() => selected = courses[idx + 1]);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // phone/tablet: single list, tap -> dialog
    return Scaffold(
      body: SafeArea(child: _leftListPane(isWide: false, includeHeader: true)),
    );
  }
}

class _EmptyDetailPanel extends StatelessWidget {
  const _EmptyDetailPanel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('单科成绩详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('请在左侧面板选中需要查看的科目', style: TextStyle(color: Color(0xFF8D8D8D), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// ------------------------------
/// Phone dialog (frosted)
/// ------------------------------

Future<void> showCourseDetailDialog(BuildContext context, Course course) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'detail',
    barrierColor: withOpacitySafe(Colors.black, 0.10),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, a1, a2) {
      final size = MediaQuery.of(ctx).size;
      final isWide = size.width >= 700;

      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: withOpacitySafe(Colors.white, 0.10)),
          ),
          Center(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 18 : 14, vertical: isWide ? 18 : 14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 560 : double.infinity,
                    maxHeight: isWide ? size.height * 0.90 : size.height * 0.92,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: _CourseDetailSheet(course: course),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (ctx, anim, sec, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

/// ------------------------------
/// Shared detail logic (components + histogram data)
/// ------------------------------

class DetailLogic {
  static const Color blue = Color(0xFF1677FF);
  static const Color orange = Color(0xFFFB8C00);
  static const Color green = Color(0xFF2ECC71);
  static const Color red = Color(0xFFE53935);

  static Color bucketColor(int x) {
    if (x < 60) return red;
    if (x < 80) return orange;
    if (x < 90) return green;
    return blue;
  }

  static List<ScoreComponent> buildComponents(Course c) {
    final seed = c.name.hashCode ^ (c.score.toInt() * 997);
    final rnd = Random(seed);

    if (c.name.contains('体育')) {
      final usual = (c.score - 2 + rnd.nextDouble() * 4).clamp(60, 100).toDouble();
      final mid = (c.score - 1 + rnd.nextDouble() * 3).clamp(60, 100).toDouble();
      final fin = (c.score + rnd.nextDouble() * 2).clamp(60, 100).toDouble();
      return [
        ScoreComponent(title: '平时', percent: 20, score: usual, color: const Color(0xFF20C997)),
        ScoreComponent(title: '期中', percent: 20, score: mid, color: const Color(0xFF20C997)),
        ScoreComponent(title: '期末', percent: 60, score: fin, color: blue),
      ];
    }

    if (c.name.contains('实验')) {
      final lab = (c.score + 2 + rnd.nextDouble() * 3).clamp(60, 100).toDouble();
      final fin = (c.score - 1 + rnd.nextDouble() * 3).clamp(60, 100).toDouble();
      return [
        ScoreComponent(title: '实验成绩', percent: 40, score: lab, color: blue),
        ScoreComponent(title: '期末成绩', percent: 60, score: fin, color: blue),
      ];
    }

    final usual = (c.score - 8 + rnd.nextDouble() * 10).clamp(50, 100).toDouble();
    final fin = (c.score + rnd.nextDouble() * 6).clamp(50, 100).toDouble();
    return [
      ScoreComponent(title: '平时成绩', percent: 40, score: usual, color: orange),
      ScoreComponent(title: '期末成绩', percent: 60, score: fin, color: blue),
    ];
  }

  static List<HistBar> buildDistribution(Course c) {
    final seed = c.name.hashCode ^ (c.score.toInt() * 1237);
    final rnd = Random(seed);

    final mean = (c.score - 8 + rnd.nextDouble() * 6).clamp(68, 88).toDouble();
    final sigma = (5 + rnd.nextDouble() * 4);

    double gauss(double x) {
      final z = (x - mean) / sigma;
      return exp(-0.5 * z * z);
    }

    final xs = List<int>.generate(51, (i) => 50 + i); // 50..100
    final raw = xs.map((x) => gauss(x.toDouble())).toList();
    final maxRaw = raw.reduce(max);

    final peak = (15 + rnd.nextInt(6)).toDouble(); // 15..20
    final bars = <HistBar>[];

    for (int i = 0; i < xs.length; i++) {
      final x = xs[i];
      final y = ((raw[i] / maxRaw) * peak).clamp(0.0, peak);
      bars.add(HistBar(x: x, y: y, color: bucketColor(x)));
    }

    // a few low-score outliers for the red bucket
    for (int k = 0; k < 3; k++) {
      final x = 50 + rnd.nextInt(11);
      bars[x - 50] = HistBar(x: x, y: 1.5, color: red);
    }

    return bars;
  }

  static double avg(Course c) => (c.score - 6).clamp(60, 100).toDouble();
  static double maxScore(Course c) => min(100.0, c.score + 6);
  static double minScore(Course c) => max(40.0, c.score - 30);
  static double passRate(Course c) => (0.86 + (c.score - 80) / 200).clamp(0.75, 0.99).toDouble();
}

/// ------------------------------
/// Detail Sheet (dialog version)
/// - Removed redundant back/close icons: only “我知道了”
/// ------------------------------

class _CourseDetailSheet extends StatelessWidget {
  final Course course;

  const _CourseDetailSheet({required this.course});

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: withOpacitySafe(Colors.white, 0.80),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: withOpacitySafe(Colors.white, 0.55)),
            boxShadow: const [
              BoxShadow(color: Color(0x0E000000), blurRadius: 14, offset: Offset(0, 10)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }

  String _fmtScore(double s) => (s % 1 == 0) ? s.toInt().toString() : s.toStringAsFixed(2);

  Widget _componentRow(ScoreComponent comp) {
    final pillBg = withOpacitySafe(comp.color, 0.12);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(18)),
            child: Text(
              _fmtScore(comp.score),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: comp.color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comp.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('占比${comp.percent}%', style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (comp.score / 100.0).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFEFF2F6),
                    valueColor: AlwaysStoppedAnimation(comp.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String left, String right) {
    return Row(
      children: [
        Text(left, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const Spacer(),
        Flexible(
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 18, color: Color(0xFF7A7A7A), fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final comps = DetailLogic.buildComponents(course);
    final bars = DetailLogic.buildDistribution(course);

    final avg = DetailLogic.avg(course);
    final maxScore = DetailLogic.maxScore(course);
    final minScore = DetailLogic.minScore(course);
    final passRate = DetailLogic.passRate(course);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: withOpacitySafe(Colors.white, 0.84),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: withOpacitySafe(Colors.white, 0.55)),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 28, offset: Offset(0, 18)),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(color: const Color(0xFFD8D8D8), borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(height: 8),

              // title only (no back/close)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    course.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '学期：${course.termLabel}',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF8D8D8D), fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              // content scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // total card
                      _glassCard(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: (course.score / 100.0).clamp(0.0, 1.0),
                                strokeWidth: 7,
                                backgroundColor: const Color(0xFFE8ECF2),
                                valueColor: const AlwaysStoppedAnimation(DetailLogic.blue),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _metric('总评', course.score.toInt().toString()),
                                  _metric('学分', course.credit.toStringAsFixed(1)),
                                  _metric('绩点', course.gpa.toStringAsFixed(1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // components card
                      _glassCard(
                        child: Column(
                          children: [
                            for (int i = 0; i < comps.length; i++) ...[
                              _componentRow(comps[i]),
                              if (i != comps.length - 1)
                                const Divider(height: 1, thickness: 0.7, color: Color(0xFFECECEC)),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('课程详情',
                            style: TextStyle(fontSize: 14, color: Color(0xFF8D8D8D), fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 10),

                      // detail metrics
                      _glassCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _metric('平均分', avg.toStringAsFixed(1)),
                            _metric('通过率', '${(passRate * 100).toStringAsFixed(1)}%'),
                            _metric('最高分', maxScore.toStringAsFixed(0)),
                            _metric('最低分', minScore.toStringAsFixed(0)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('班级得分分布',
                            style: TextStyle(fontSize: 14, color: Color(0xFF8D8D8D), fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 10),

                      // histogram (p4 style)
                      _glassCard(
                        child: SizedBox(
                          height: 240,
                          child: HistogramCard(
                            bars: bars,
                            maxY: 20,
                            showYTicks: const [5, 10, 15, 20],
                            showXTicks: const [50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // info card
                      _glassCard(
                        child: Column(
                          children: [
                            _infoRow('任课教师', course.teacher),
                            const Divider(height: 22, thickness: 1, color: Color(0xFFF0F0F0)),
                            _infoRow('课程性质', course.type),
                            const Divider(height: 22, thickness: 1, color: Color(0xFFF0F0F0)),
                            _infoRow('授课学期', course.termLabel),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),

              // bottom button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DetailLogic.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('我知道了',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------
/// Wide detail panel (right side, fig 3/4)
/// ------------------------------

class CourseDetailPanel extends StatelessWidget {
  final Course course;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const CourseDetailPanel({
    super.key,
    required this.course,
    required this.onPrev,
    required this.onNext,
  });

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: child,
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }

  String _fmtScore(double s) => (s % 1 == 0) ? s.toInt().toString() : s.toStringAsFixed(2);

  Widget _componentRow(ScoreComponent comp) {
    final pillBg = withOpacitySafe(comp.color, 0.12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(18)),
            child: Text(_fmtScore(comp.score),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: comp.color)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comp.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('占比${comp.percent}%',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (comp.score / 100.0).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFEFF2F6),
                    valueColor: AlwaysStoppedAnimation(comp.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String left, String right) {
    return Row(
      children: [
        Text(left, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const Spacer(),
        Flexible(
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 18, color: Color(0xFF7A7A7A), fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final comps = DetailLogic.buildComponents(course);
    final bars = DetailLogic.buildDistribution(course);

    final avg = DetailLogic.avg(course);
    final maxScore = DetailLogic.maxScore(course);
    final minScore = DetailLogic.minScore(course);
    final passRate = DetailLogic.passRate(course);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(course.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('我的分数', style: TextStyle(color: Color(0xFF8D8D8D), fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              children: [
                _card(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: (course.score / 100.0).clamp(0.0, 1.0),
                          strokeWidth: 7,
                          backgroundColor: const Color(0xFFE8ECF2),
                          valueColor: const AlwaysStoppedAnimation(DetailLogic.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _metric('总评', course.score.toInt().toString()),
                            _metric('学分', course.credit.toStringAsFixed(1)),
                            _metric('绩点', course.gpa.toStringAsFixed(1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _card(
                  child: Column(
                    children: [
                      for (int i = 0; i < comps.length; i++) ...[
                        _componentRow(comps[i]),
                        if (i != comps.length - 1)
                          const Divider(height: 1, thickness: 0.7, color: Color(0xFFECECEC)),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                const Text('课程详情',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8D8D8D), fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),

                _card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metric('平均分', avg.toStringAsFixed(1)),
                      _metric('通过率', '${(passRate * 100).toStringAsFixed(1)}%'),
                      _metric('最高分', maxScore.toStringAsFixed(0)),
                      _metric('最低分', minScore.toStringAsFixed(0)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                const Text('班级得分分布',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8D8D8D), fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),

                _card(
                  child: SizedBox(
                    height: 240,
                    child: HistogramCard(
                      bars: bars,
                      maxY: 20,
                      showYTicks: const [5, 10, 15, 20],
                      showXTicks: const [50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _card(
                  child: Column(
                    children: [
                      _infoRow('任课教师', course.teacher),
                      const Divider(height: 22, thickness: 1, color: Color(0xFFF0F0F0)),
                      _infoRow('课程性质', course.type),
                      const Divider(height: 22, thickness: 1, color: Color(0xFFF0F0F0)),
                      _infoRow('授课学期', course.termLabel),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DetailLogic.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: onPrev,
                    child: const Text('上一科', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DetailLogic.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: onNext,
                    child: const Text('下一科', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// Histogram (p4 style background + grid + bars)
/// ------------------------------

class HistogramCard extends StatelessWidget {
  final List<HistBar> bars;
  final double maxY;
  final List<int> showXTicks;
  final List<int> showYTicks;

  const HistogramCard({
    super.key,
    required this.bars,
    required this.maxY,
    required this.showXTicks,
    required this.showYTicks,
  });

  @override
  Widget build(BuildContext context) {
    // subtle tinted background like p4
    final bg = BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          withOpacitySafe(DetailLogic.orange, 0.08),
          withOpacitySafe(DetailLogic.green, 0.06),
          withOpacitySafe(DetailLogic.blue, 0.08),
        ],
      ),
    );

    return Container(
      decoration: bg,
      child: CustomPaint(
        painter: HistogramPainter(
          bars: bars,
          maxY: maxY,
          showXTicks: showXTicks,
          showYTicks: showYTicks,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class HistogramPainter extends CustomPainter {
  final List<HistBar> bars;
  final double maxY;
  final List<int> showXTicks;
  final List<int> showYTicks;

  HistogramPainter({
    required this.bars,
    required this.maxY,
    required this.showXTicks,
    required this.showYTicks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // padding inside chart area (keeps labels like the sample)
    const leftPad = 34.0;
    const rightPad = 10.0;
    const topPad = 12.0;
    const bottomPad = 34.0;

    final plot = Rect.fromLTWH(
      leftPad,
      topPad,
      max(0, size.width - leftPad - rightPad),
      max(0, size.height - topPad - bottomPad),
    );

    // grid lines
    final gridPaint = Paint()
      ..color = const Color(0x1A000000)
      ..strokeWidth = 1;

    for (final yTick in showYTicks) {
      final t = (yTick / maxY).clamp(0.0, 1.0);
      final y = plot.bottom - t * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);

      // y labels
      final tp = TextPainter(
        text: TextSpan(
          text: yTick.toString(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF8D8D8D), fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(6, y - tp.height / 2));
    }

    // x axis baseline
    canvas.drawLine(Offset(plot.left, plot.bottom), Offset(plot.right, plot.bottom), gridPaint);

    // map x: 50..100
    const minX = 50;
    const maxX = 100;
    double xToPx(int x) {
      final t = ((x - minX) / (maxX - minX)).clamp(0.0, 1.0);
      return plot.left + t * plot.width;
    }

    // x tick labels
    for (final xTick in showXTicks) {
      final x = xToPx(xTick);
      final tp = TextPainter(
        text: TextSpan(
          text: xTick.toString(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF8D8D8D), fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, plot.bottom + 10));
    }

    // bars
    final barCount = (maxX - minX + 1); // 51
    final gap = 3.2;
    final barW = max(2.0, (plot.width - (barCount - 1) * gap) / barCount);

    for (final b in bars) {
      final idx = (b.x - minX).clamp(0, barCount - 1);
      final left = plot.left + idx * (barW + gap);
      final t = (b.y / maxY).clamp(0.0, 1.0);
      final h = t * plot.height;

      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, plot.bottom - h, barW, h),
        const Radius.circular(3),
      );

      final paint = Paint()..color = b.color;
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HistogramPainter oldDelegate) {
    return oldDelegate.bars != bars || oldDelegate.maxY != maxY;
  }
}
