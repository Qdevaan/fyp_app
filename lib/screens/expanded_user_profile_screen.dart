import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';

class ExpandedUserProfileScreen extends StatefulWidget {
  const ExpandedUserProfileScreen({super.key});

  @override
  State<ExpandedUserProfileScreen> createState() => _ExpandedUserProfileScreenState();
}

class _ExpandedUserProfileScreenState extends State<ExpandedUserProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _nameCtrl = TextEditingController(
      text: (user?.userMetadata?['full_name'] ?? '') as String,
    );
    _bioCtrl = TextEditingController(
      text: (user?.userMetadata?['bio'] ?? '') as String,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': _nameCtrl.text, 'bio': _bioCtrl.text}),
      );
      if (mounted) setState(() => _editing = false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

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
                    _buildAvatar(avatarUrl),
                    const SizedBox(height: 24),
                    _buildInfoCard(email),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    if (!_editing) _buildBadges(),
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
            Expanded(child: Text('Profile', style: GoogleFonts.manrope(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: BubblesColors.textPrimaryDark,
            ))),
            IconButton(
              icon: Icon(_editing ? Icons.close : Icons.edit_outlined,
                color: BubblesColors.primary),
              onPressed: () => setState(() => _editing = !_editing),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: BubblesColors.primary.withOpacity(0.2),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'U',
                  style: GoogleFonts.manrope(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: BubblesColors.primary,
                  ))
              : null,
        ),
        if (_editing)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle, color: BubblesColors.primary,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String email) {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_editing) ...[
            AppInput(controller: _nameCtrl, label: 'Full Name', hint: 'Your name'),
            const SizedBox(height: 12),
            AppInput(controller: _bioCtrl, label: 'Bio', hint: 'Tell us about yourself…', maxLines: 3),
            const SizedBox(height: 16),
            AppButton(
              label: 'Save Changes',
              loading: _saving,
              onPressed: _editing ? _save : null,
            ),
          ] else ...[
            Text(_nameCtrl.text.isEmpty ? 'Set your name' : _nameCtrl.text,
              style: GoogleFonts.manrope(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: BubblesColors.textPrimaryDark,
              )),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(
              fontSize: 12, color: BubblesColors.textSecondaryDark,
            )),
            if (_bioCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_bioCtrl.text, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: BubblesColors.textSecondaryDark, height: 1.5)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatCard('24', 'Sessions')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard('142', 'Insights')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard('8', 'Badges')),
      ],
    );
  }

  Widget _buildBadges() {
    const badges = [
      ('🎯', 'Focused', 'Completed 5 deep sessions'),
      ('💬', 'Communicator', 'Used AI Consultant 10 times'),
      ('🌟', 'Achiever', 'Profile fully complete'),
    ];
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BADGES', style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 1.2, color: BubblesColors.textMutedDark,
          )),
          const SizedBox(height: 12),
          ...badges.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(b.$1, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.$2, style: GoogleFonts.manrope(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: BubblesColors.textPrimaryDark,
                      )),
                      Text(b.$3, style: TextStyle(
                        fontSize: 11, color: BubblesColors.textSecondaryDark,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  const _StatCard(this.value, this.label);
  @override
  Widget build(BuildContext context) => GlassBox(
    borderRadius: 14, padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      children: [
        Text(value, style: GoogleFonts.manrope(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: BubblesColors.primary,
        )),
        Text(label, style: TextStyle(
          fontSize: 10, color: BubblesColors.textSecondaryDark,
        )),
      ],
    ),
  );
}
