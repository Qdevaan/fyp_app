import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF101e22), Color(0xFF0d2a33)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHero(),
                    const SizedBox(height: 28),
                    _PlanCard(
                      name: 'Free',
                      price: '\$0',
                      period: '/month',
                      features: const [
                        '5 AI Consultant sessions/month',
                        '2 Live Wingman sessions/month',
                        'Basic knowledge graph',
                        'Standard response time',
                      ],
                      current: true,
                      cta: 'Current Plan',
                    ),
                    const SizedBox(height: 16),
                    _PlanCard(
                      name: 'Pro',
                      price: '\$9.99',
                      period: '/month',
                      features: const [
                        'Unlimited AI Consultant sessions',
                        'Unlimited Live Wingman sessions',
                        'Advanced knowledge graph',
                        'Priority response time',
                        'AI Insights Dashboard',
                        'Custom voice profiles',
                      ],
                      current: false,
                      highlighted: true,
                      cta: 'Upgrade to Pro',
                    ),
                    const SizedBox(height: 16),
                    _PlanCard(
                      name: 'Enterprise',
                      price: 'Custom',
                      period: '',
                      features: const [
                        'Everything in Pro',
                        'Team accounts & admin panel',
                        'Dedicated server',
                        'SLA & priority support',
                        'Custom integrations',
                      ],
                      current: false,
                      cta: 'Contact Us',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: const BoxDecoration(
          color: BubblesColors.glassHeaderDark,
          border: Border(bottom: BorderSide(color: Color(0x1A13BDEC))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: BubblesColors.textPrimaryDark),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text('Subscription', style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: BubblesColors.textPrimaryDark,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF13bdec), Color(0xFF0ea5d0)],
            ),
            boxShadow: [
              BoxShadow(
                color: BubblesColors.primary.withOpacity(0.4),
                blurRadius: 24,
              ),
            ],
          ),
          child: const Icon(Icons.diamond_outlined, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 16),
        Text('Choose Your Plan', style: GoogleFonts.manrope(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: BubblesColors.textPrimaryDark,
        )),
        const SizedBox(height: 6),
        Text('Unlock the full power of your AI coach',
          style: TextStyle(fontSize: 13, color: BubblesColors.textSecondaryDark),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name, price, period, cta;
  final List<String> features;
  final bool current, highlighted;

  const _PlanCard({
    required this.name, required this.price, required this.period,
    required this.features, required this.current, required this.cta,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlassBox(
          borderRadius: 20,
          bgColor: highlighted ? BubblesColors.glassPrimary : BubblesColors.glassDark,
          borderColor: highlighted ? BubblesColors.glassPrimaryBorder : BubblesColors.glassBorderDark,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: highlighted ? BubblesColors.primary : BubblesColors.textPrimaryDark,
                  )),
                  if (highlighted) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: BubblesColors.primary,
                      ),
                      child: const Text('POPULAR', style: TextStyle(
                        fontSize: 8, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 0.8,
                      )),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: price, style: GoogleFonts.manrope(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: BubblesColors.textPrimaryDark,
                    )),
                    TextSpan(text: period, style: TextStyle(
                      fontSize: 13, color: BubblesColors.textSecondaryDark,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...features.map((f) => _FeatureRow(f)),
              const SizedBox(height: 20),
              AppButton(
                label: cta,
                variant: current
                    ? AppButtonVariant.outlined
                    : highlighted
                        ? AppButtonVariant.filled
                        : AppButtonVariant.outlined,
                onPressed: current ? null : () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: BubblesColors.primary, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(
          fontSize: 12, color: BubblesColors.textPrimaryDark,
        ))),
      ],
    ),
  );
}
