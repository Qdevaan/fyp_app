import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
    // Pre-fill with current URL
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
          const SnackBar(content: Text("✅ Connected to Brain!"), backgroundColor: Colors.green)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Connection Failed. Check URL."), backgroundColor: Colors.red)
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
          title: const Text("Scan Server QR", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
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
                // Basic validation: ensure it looks like a URL
                if (code.startsWith('http')) {
                  setState(() {
                    _urlController.text = code;
                    _isScanning = false;
                  });
                  Navigator.pop(ctx); // Close scanner
                  _saveAndTest(); // Auto-save
                }
                break; // Stop after first valid code
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectionService = Provider.of<ConnectionService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Connect Brain")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: connectionService.isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: connectionService.isConnected ? Colors.green : Colors.red.withOpacity(0.5),
                  width: 2
                )
              ),
              child: Row(
                children: [
                  Icon(
                    connectionService.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: connectionService.isConnected ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connectionService.isConnected ? "Connected" : "Disconnected",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: connectionService.isConnected ? Colors.green[800] : Colors.red[800]
                          ),
                        ),
                        Text(
                          connectionService.isConnected 
                            ? "Brain is online & ready." 
                            : "Connect to Colab to activate AI.",
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),
            
            // QR Button
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner, size: 24),
              label: const Text("Scan QR from Colab"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _scanQr,
            ),
            
            const SizedBox(height: 20),
            const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.all(8.0), child: Text("OR")), Expanded(child: Divider())]),
            const SizedBox(height: 20),
            
            // Manual Input
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Server URL",
                hintText: "https://xxxx.ngrok-free.app",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.link),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: connectionService.status == ConnectionStatus.connecting ? null : _saveAndTest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: connectionService.status == ConnectionStatus.connecting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Save & Test Connection"),
            ),
          ],
        ),
      ),
    );
  }
}