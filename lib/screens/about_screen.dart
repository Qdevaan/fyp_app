import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const String appVersion = "1.0.0";

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Background (Static)
          const _AmbientBackground(),
          
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader(
                      theme,
                      icon: Icons.auto_awesome,
                      title: 'Project Abstract',
                    ),
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: Text(
                        'The aim of our project is to enhance communication skills by using AI and NLP to assist during and after conversations. It aims to recognize the tone and flow of discussions, provide real-time suggestions for impactful responses, and help users understand industry-specific jargon. By analysing conversations, it offers tailored tips to improve communication, ensuring users can refine their skills over time.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: Text(
                        'The tool not only transcribes and summarizes conversations but also finds key participants, highlights key details, and provides actionable insights. It includes a "replay" feature that suggests alternative phrases or approaches, helping users reflect on what could have been said more effectively. Whether it is a formal business meeting, an informal chat, or a professional negotiation, this AI-powered assistant is designed to support users in becoming more confident and articulate communicators.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 32),
                     _buildSectionHeader(
                      theme,
                      icon: Icons.lightbulb_circle,
                      title: 'Project Rationale',
                    ),
                     const SizedBox(height: 16),
                    _GlassCard(
                      child: Column(
                        children: [
                          Text(
                            'As a student, sometime after a conversation ends, I realize the words that I used were not appropriate for the conversation and I could have done it in a better way, or how could I have delivered my message more clearly and made my conversation more engaging? But then, after some time passes, I forget all the points that I wanted to keep in mind.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                               color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'The purpose of our project is to create a smart assistant that can not only capture, summarize, and analyze conversations in real-time but also assist people in improving their communication skills. The system will determine the tone of the conversation, map the flow of the conversation, provide instant responses, suggest strong phrases, and comment on the clarity, structure, and engagement of the conversation.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                               color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      theme,
                      icon: Icons.groups_rounded,
                      title: 'Meet the Team',
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(
                          child: _DeveloperInfoCard(
                            name: 'Muhammad Ahmad',
                            regNo: 'FA22-BCS-025',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _DeveloperInfoCard(
                            name: 'Attique Rehman',
                            regNo: 'FA22-BCS-164',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildAffiliationSection(theme),
                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Crafted with ❤️ by the Bubbles Team',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              'Version $appVersion',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                     const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'About Bubbles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
             Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Abstract shapes
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.tertiary.withOpacity(0.3),
                      theme.colorScheme.tertiary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const AppLogo(size: 120),
                const SizedBox(height: 16),
                Text(
                  'AI-powered Conversational Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 26),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAffiliationSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'In partial fulfillment of the degree of BS in Computer Science at',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _GlassCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_rounded,
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMSATS University',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Islamabad, Lahore Campus',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DeveloperInfoCard extends StatelessWidget {
  final String name;
  final String regNo;

  const _DeveloperInfoCard({
    required this.name,
    required this.regNo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                name.isNotEmpty ? name[0] : '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name, 
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            regNo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Top right ambient blob
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            ),
          ),
        ),
        // Bottom left ambient blob
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }
}