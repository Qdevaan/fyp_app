import 'dart:ui';
import 'package:flutter/material.dart';

class AiInsightsDashboardScreen extends StatelessWidget {
  const AiInsightsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold background will handle the gradient mesh in the future
    return Scaffold(
      backgroundColor: const Color(0xFF101E22), // Deep teal-black dark mode background
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Background Mesh Orbs
          Positioned(
            top: -100,
            left: -100,
            child: _buildOrb(const Color(0xFF13A4EC), 400, opacity: 0.15),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: _buildOrb(const Color(0xFF818CF8), 350, opacity: 0.15),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 50,
            child: _buildOrb(const Color(0xFF0B8BC9), 300, opacity: 0.2),
          ),
          
          Column(
            children: [
              // Glass Header
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      bottom: 16,
                      left: 16,
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101E22).withOpacity(0.8),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF13A4EC).withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.bubble_chart,
                          color: Color(0xFF13A4EC),
                          size: 32,
                        ),
                        const Text(
                          'AI Insights',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Recent Sessions Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Recent Sessions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'View All',
                              style: TextStyle(
                                color: const Color(0xFF13A4EC),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recent Sessions List
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildSessionAvatar('Team Sync', true),
                            _buildSessionAvatar('Interview', false),
                            _buildSessionAvatar('Pitch', false),
                            _buildSessionAvatar('Review', false),
                            _buildSessionAvatar('Strategy', false),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Emotional Trends Chart
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13A4EC).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF13A4EC).withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Emotional Trends',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Sentiment analysis over last 7 days',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF13A4EC).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'HIGH POSITIVITY',
                                      style: TextStyle(
                                        color: Color(0xFF13A4EC),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Chart Visualization
                              SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: _ChartPainter(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildChartLabel('MON'),
                                  _buildChartLabel('WED'),
                                  _buildChartLabel('FRI'),
                                  _buildChartLabel('SUN'),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Key Discoveries
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Key Discoveries',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                          children: [
                            _buildDiscoveryCard(
                              icon: Icons.person_search,
                              type: 'PERSON',
                              title: 'Sarah Jenkins',
                              desc: 'Mentioned in 4/5 recent project syncs.',
                            ),
                            _buildDiscoveryCard(
                              icon: Icons.rocket_launch,
                              type: 'PROJECT',
                              title: 'Nebula v2.0',
                              desc: 'Identified as high-priority milestone.',
                            ),
                            _buildDiscoveryCard(
                              icon: Icons.payments,
                              type: 'ENTITY',
                              title: 'Q3 Budget',
                              desc: 'Primary blocker for resource allocation.',
                            ),
                            _buildDiscoveryCard(
                              icon: Icons.location_on,
                              type: 'LOCATION',
                              title: 'Berlin HQ',
                              desc: 'Offsite venue confirmed for October.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // AI Recommendation Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13A4EC).withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFF13A4EC).withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFF13A4EC),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AI Recommendation',
                                      style: TextStyle(
                                        color: Color(0xFF13A4EC),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                        children: [
                                          TextSpan(text: 'Based on your last 3 interviews, there is a consistent pain point regarding '),
                                          TextSpan(
                                            text: 'API latency',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          TextSpan(text: '. Consider scheduling a tech audit.'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar (Glass)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                    top: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101E22).withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFF13A4EC).withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildNavItem(Icons.home, 'Home', false),
                      _buildNavItem(Icons.insights, 'Insights', true),
                      // Floating Action Button
                      Transform.translate(
                        offset: const Offset(0, -24),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF13A4EC),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF13A4EC).withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 32),
                        ),
                      ),
                      _buildNavItem(Icons.folder_outlined, 'Library', false),
                      _buildNavItem(Icons.settings_outlined, 'Settings', false),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(Color color, double size, {double opacity = 0.2}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildSessionAvatar(String label, bool isHighlighted) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHighlighted 
                  ? const Color(0xFF13A4EC).withOpacity(0.2)
                  : const Color(0xFF1E293B),
              border: isHighlighted
                  ? Border.all(color: const Color(0xFF13A4EC).withOpacity(0.4), width: 2)
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.3),
                // Normally use NetworkImage or AssetImage here
              ),
              child: const Icon(Icons.person, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDiscoveryCard({
    required IconData icon,
    required String type,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13A4EC).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF13A4EC).withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF13A4EC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF13A4EC)),
          ),
          const SizedBox(height: 12),
          Text(
            type,
            style: const TextStyle(
              color: Color(0xFF13A4EC),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            desc,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF13A4EC) : Colors.white54,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF13A4EC) : Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF13A4EC)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Simulating emotional trend data points
    final p1 = Offset(0, size.height * 0.8);
    final p2 = Offset(size.width * 0.25, size.height * 0.5);
    final p3 = Offset(size.width * 0.5, size.height * 0.3);
    final p4 = Offset(size.width * 0.75, size.height * 0.6);
    final p5 = Offset(size.width, size.height * 0.1);

    path.moveTo(p1.dx, p1.dy);
    
    // Smooth curves between points
    path.quadraticBezierTo(
      size.width * 0.125, size.height * 0.2, 
      p2.dx, p2.dy,
    );
    path.quadraticBezierTo(
      size.width * 0.375, size.height * 0.8, 
      p3.dx, p3.dy,
    );
    path.quadraticBezierTo(
      size.width * 0.625, size.height * -0.2, 
      p4.dx, p4.dy,
    );
    path.quadraticBezierTo(
      size.width * 0.875, size.height * 1.4, 
      p5.dx, p5.dy,
    );

    // Create gradient fill below path
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF13A4EC).withOpacity(0.4),
          const Color(0xFF13A4EC).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data point circles
    final circlePaint = Paint()
      ..color = const Color(0xFF13A4EC)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(p2, 4, circlePaint);
    canvas.drawCircle(p3, 4, circlePaint);
    canvas.drawCircle(p5, 4, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
