import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  bool _connected = false;
  final _urlCtrl = TextEditingController();
  String _status = 'Not Connected';

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  void _connect() {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _connected = true;
      _status = 'Connected';
    });
  }

  void _disconnect() {
    setState(() {
      _connected = false;
      _status = 'Not Connected';
      _urlCtrl.clear();
    });
  }

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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: BubblesBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) Navigator.pop(context);
        },
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
              child: Text('Connections', style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: BubblesColors.textPrimaryDark,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 24),
          _buildConnectCard(),
          const SizedBox(height: 24),
          if (_connected) _buildConnectedInfo(),
          const SizedBox(height: 24),
          _buildQrSection(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final c = _connected ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
    final bg = c.withOpacity(0.08);
    final border = c.withOpacity(0.3);
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(20),
      bgColor: bg, borderColor: border,
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: c.withOpacity(0.18),
              border: Border.all(color: c.withOpacity(0.4)),
            ),
            child: Icon(
              _connected ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: c, size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connection Status', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 1.1, color: BubblesColors.textMutedDark,
                )),
                const SizedBox(height: 4),
                Text(_status, style: GoogleFonts.manrope(
                  fontSize: 18, fontWeight: FontWeight.w700, color: c,
                )),
              ],
            ),
          ),
          StatusBadge(
            status: _connected ? ConnectionStatus.connected : ConnectionStatus.disconnected,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectCard() {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SERVER URL', style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 1.1, color: BubblesColors.textMutedDark,
          )),
          const SizedBox(height: 12),
          AppInput(
            controller: _urlCtrl,
            label: 'Connection URL',
            hint: 'wss://your-server.example.com',
            enabled: !_connected,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          if (!_connected)
            AppButton(
              label: 'Connect',
              onPressed: _connect,
            )
          else
            AppButton(
              label: 'Disconnect',
              variant: AppButtonVariant.danger,
              onPressed: _disconnect,
            ),
        ],
      ),
    );
  }

  Widget _buildConnectedInfo() {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(20),
      bgColor: BubblesColors.glassPrimary,
      borderColor: BubblesColors.glassPrimaryBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: BubblesColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('Connection Details', style: GoogleFonts.manrope(
                fontSize: 12, fontWeight: FontWeight.w700, color: BubblesColors.primary,
              )),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow('URL', _urlCtrl.text),
          _InfoRow('Latency', '42ms'),
          _InfoRow('Protocol', 'WebSocket'),
          _InfoRow('Encryption', 'TLS 1.3'),
        ],
      ),
    );
  }

  Widget _buildQrSection(BuildContext context) {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUICK CONNECT', style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 1.1, color: BubblesColors.textMutedDark,
          )),
          const SizedBox(height: 4),
          Text('Scan a QR code to auto-fill connection details.',
            style: TextStyle(fontSize: 12, color: BubblesColors.textSecondaryDark),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Scan QR Code',
            variant: AppButtonVariant.outlined,
            leadingIcon: Icons.qr_code_scanner,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(
              fontSize: 11, color: BubblesColors.textMutedDark,
            )),
          ),
          Expanded(child: Text(value, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: BubblesColors.textPrimaryDark,
          ), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
