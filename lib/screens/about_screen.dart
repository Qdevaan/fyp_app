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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(
                  theme,
                  icon: Icons.flag_outlined,
                  title: 'Project Abstract',
                ),
                const SizedBox(height: 12),
                Text(
                  'The aim of our project is to enhance communication skills by using AI and NLP to assist during and after conversations. It aims to recognize the tone and flow of discussions, provide real-time suggestions for impactful responses, and help users understand industry-specific jargon. By analysing conversations, it offers tailored tips to improve communication, ensuring users can refine their skills over time.',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 12),
                Text(
                  'The tool not only transcribes and summarizes conversations but also finds key participants, highlights key details, and provides actionable insights. It includes a "replay" feature that suggests alternative phrases or approaches, helping users reflect on what could have been said more effectively. Whether it is a formal business meeting, an informal chat, or a professional negotiation, this AI-powered assistant is designed to support users in becoming more confident and articulate communicators.',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const Divider(height: 40),
                 _buildSectionHeader(
                  theme,
                  icon: Icons.lightbulb_outline,
                  title: 'Project Rationale',
                ),
                 const SizedBox(height: 12),
                Text(
                  'As a student, sometime after a conversation ends, I realize the words that I used were not appropriate for the conversation and I could have done it in a better way, or how could I have delivered my message more clearly and made my conversation more engaging? But then, after some time passes, I forget all the points that I wanted to keep in mind.',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 12),
                Text(
                  'The purpose of our project is to create a smart assistant that can not only capture, summarize, and analyze conversations in real-time but also assist people in improving their communication skills. The system will determine the tone of the conversation, map the flow of the conversation, provide instant responses, suggest strong phrases, and comment on the clarity, structure, and engagement of the conversation.',
                   style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const Divider(height: 40),
                _buildSectionHeader(
                  theme,
                  icon: Icons.people_outline,
                  title: 'Developed By',
                ),
                const SizedBox(height: 12),
                const _DeveloperInfoCard(
                  name: 'Muhammad Ahmad',
                  regNo: 'FA22-BCS-025',
                ),
                const SizedBox(height: 8),
                const _DeveloperInfoCard(
                  name: 'Attique Rehman',
                  regNo: 'FA22-BCS-164',
                ),
                const Divider(height: 40),
                _buildAffiliationSection(theme),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Version $appVersion',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                 const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'About Bubbles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(size: 100),
              const SizedBox(height: 16),
              Text(
                'AI-powered Conversational Assistant',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
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
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
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
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'COMSATS University Islamabad,\nLahore Campus',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeveloperInfoCard extends StatelessWidget {
  final String name;
  final String regNo;

  const _DeveloperInfoCard({required this.name, required this.regNo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            name.isNotEmpty ? name[0] : '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          name, 
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          )
        ),
        subtitle: Text(
          regNo,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}