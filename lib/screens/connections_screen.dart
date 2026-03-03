import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/design_tokens.dart';
import '../services/connection_service.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});
  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final _urlController = TextEditingController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = Provider.of<ConnectionService>(context, listen: false);
      _urlController.text = service.serverUrl;
    });
  }

  void _saveAndTest() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final service = Provider.of<ConnectionService>(context, listen: false);
    await service.saveUrl(url);

    if (mounted) {
      if (service.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("âœ… Connected to Brain!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("âŒ Connection Failed. Check URL."), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scanQr() {
    setState(() => _isScanning = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.black,
      builder: (ctx) => Scaffold(
        appBar: AppBar(
          title: Text("Scan Server QR", style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.surfaceDark,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(ctx),
          ),
        ),
        body: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                final code = barcode.rawValue!;
                if (code.startsWith('http')) {
                  setState(() {
                    _urlController.text = code;
                    _isScanning = false;
                  });
                  Navigator.pop(ctx);
                  _saveAndTest();
                }
                break;
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectionService = Provider.of<ConnectionService>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Connect Brain',
                  style: GoogleFonts.manrope(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Status Card ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: connectionService.isConnected
                              ? AppColors.success.withOpacity(0.3)
                              : AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: connectionService.isConnected
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              connectionService.isConnected ? Icons.wifi : Icons.wifi_off,
                              color: connectionService.isConnected ? AppColors.success : AppColors.error,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  connectionService.isConnected ? 'Connected' : 'Disconnected',
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: connectionService.isConnected ? AppColors.success : AppColors.error,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  connectionService.isConnected
                                      ? 'Brain is online & ready.'
                                      : 'Connect to Colab to activate AI.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- QR Scan Button ---
                    GestureDetector(
                      onTap: _scanQr,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, const Color(0xFF1E88E5)]),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Scan QR from Colab',
                              style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Manual Input ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Server URL',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        TextField(
                          controller: _urlController,
                          style: GoogleFonts.manrope(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'https://xxxx.ngrok-free.app',
                            hintStyle: GoogleFonts.manrope(color: const Color(0xFF64748B)),
                            prefixIcon: Icon(Icons.link, size: 20, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- Save Button ---
                    GestureDetector(
                      onTap: connectionService.status == ConnectionStatus.connecting ? null : _saveAndTest,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: connectionService.status == ConnectionStatus.connecting
                              ? (isDark ? AppColors.surfaceDark : Colors.grey.shade200)
                              : null,
                          gradient: connectionService.status == ConnectionStatus.connecting
                              ? null
                              : LinearGradient(colors: [Theme.of(context).colorScheme.primary, const Color(0xFF1E88E5)]),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: connectionService.status == ConnectionStatus.connecting
                              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
                              : Text(
                                  'Save & Test Connection',
                                  style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
