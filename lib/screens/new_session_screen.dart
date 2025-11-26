import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  // --- CORE VARIABLES ---
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  // State Flags
  bool _isSessionActive = false;
  bool _isUploading = false;
  bool _isSaving = false;
  bool _swapSpeakers = false; // Manual toggle for "Diarization Drift"
  
  // Data
  final List<Map<String, dynamic>> _sessionLogs = [];
  String _currentSuggestion = "Tap mic to start Wingman...";
  
  // Controllers
  Timer? _loopTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _stopLoop(); // Safety kill
    _audioRecorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ===========================================================
  // 🎤 CORE LOGIC: START / STOP / LOOP
  // ===========================================================

  void _toggleSession() {
    if (_isSessionActive) {
      _endSessionAndSave();
    } else {
      setState(() { 
        _isSessionActive = true; 
        _sessionLogs.clear(); 
        _currentSuggestion = "Listening for conversation..."; 
      });
      _startLoop();
    }
  }

  // This function is responsible for saving the history when the user stops
  Future<void> _endSessionAndSave() async {
    _stopLoop();
    
    final user = AuthService.instance.currentUser;
    
    // Only save if we actually recorded something
    if (user != null && _sessionLogs.isNotEmpty) {
      setState(() => _isSaving = true);
      
      try {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Saving Session to Memory..."))
          );
        }
        
        final api = Provider.of<ApiService>(context, listen: false);
        // This sends the entire list of {_speaker, _text} maps to the backend
        bool success = await api.saveSession(user.id, _sessionLogs);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Session Saved to Memory!"), 
                backgroundColor: Colors.green
              )
            );
            Navigator.pop(context); // Go back to Home
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to save session."), 
                backgroundColor: Colors.red
              )
            );
          }
        }
      } catch (e) {
        print("Save failed: $e");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Error: $e")));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else {
      if(mounted) Navigator.pop(context);
    }
  }

  void _startLoop() async {
    if (!_isSessionActive) return;

    try {
      // 1. Prepare File Path
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/chunk_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      // 2. Check Permissions
      if (!await _audioRecorder.hasPermission()) {
        _stopLoop();
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Microphone permission denied")));
        return;
      }

      // 3. Start Recording (AAC is efficient for upload)
      await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);

      // 4. The "Heartbeat": Stop after 1.5 seconds
      _loopTimer = Timer(const Duration(milliseconds: 1500), () async {
        if (!_isSessionActive) return;
        
        final recordedPath = await _audioRecorder.stop();
        
        // 5. Restart Loop IMMEDIATELY (Don't wait for upload)
        _startLoop();

        // 6. Process the chunk in background
        if (recordedPath != null) {
          _processChunk(recordedPath); 
        }
      });

    } catch (e) {
      print("Mic Error: $e");
      _stopLoop();
    }
  }

  void _stopLoop() async {
    _loopTimer?.cancel();
    if (await _audioRecorder.isRecording()) await _audioRecorder.stop();
    if (mounted) setState(() { _isSessionActive = false; });
  }

  // ===========================================================
  // ☁️ API PROCESSING & STATE UPDATES
  // ===========================================================

  Future<void> _processChunk(String path) async {
    if (!mounted) return;
    
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final result = await api.processAudioChunk(path);
      
      if (!mounted) return;

      setState(() {
        // 1. Update Advice (Only if valid)
        if (result['suggestion'] != "WAITING" && result['suggestion'] != "" && result['suggestion'] != null) {
          _currentSuggestion = result['suggestion'];
        }

        // 2. Parse Transcript & Add to Logs
        String raw = result['transcript'] ?? "";
        List<String> lines = raw.split('\n');
        
        bool addedNewLogs = false;

        for (var line in lines) {
          if (line.trim().isEmpty) continue;
          
          String speaker = "Unknown";
          String text = line;

          // Speaker Logic: "User" vs "Other"
          // We use the _swapSpeakers flag to let the user manually correct the AI
          if (line.contains("User:")) {
            speaker = _swapSpeakers ? "Other" : "User";
            text = line.replaceAll("User:", "").trim();
          } else if (line.contains("Other:")) {
            speaker = _swapSpeakers ? "User" : "Other";
            text = line.replaceAll("Other:", "").trim();
          }
          
          // Only add if text is substantial
          if (text.isNotEmpty) {
            _sessionLogs.add({"speaker": speaker, "text": text});
            addedNewLogs = true;
          }
        }

        // Auto-scroll if new logs came in
        if (addedNewLogs) {
          _scrollToBottom();
        }
      });
    } catch (e) {
      print("Upload Error: $e");
    } finally {
      // Clean up temp file to save space
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print("Cleanup error: $e");
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Using a slight delay ensures the list renders the new item before scrolling
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0.0, // Since list is reversed, 0.0 is the "bottom" (start of list)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // ===========================================================
  // 📱 UI BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB), // Light Grey-Blue
      appBar: AppBar(
        title: const Text("Live Wingman", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          // SWAP BUTTON: Fixes "Diarization Drift"
          IconButton(
            icon: Icon(_swapSpeakers ? Icons.swap_horiz_rounded : Icons.compare_arrows_rounded),
            tooltip: "Swap Speakers (If AI confuses you)",
            onPressed: () {
              setState(() => _swapSpeakers = !_swapSpeakers);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Speakers Swapped!"), duration: Duration(milliseconds: 500))
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. CHAT HISTORY (Transcript)
          Expanded(
            child: _sessionLogs.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_none, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text("Ready to listen...", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  ],
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                reverse: true, // Auto-scroll to bottom by reversing list logic
                padding: const EdgeInsets.all(16),
                itemCount: _sessionLogs.length,
                itemBuilder: (context, index) {
                  // Because list is reversed, index 0 is the LAST item added (bottom of screen)
                  final msg = _sessionLogs[_sessionLogs.length - 1 - index];
                  bool isMe = msg['speaker'] == "User";
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isMe ? theme.colorScheme.primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                          bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) // Show label for other person
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                "Other",
                                style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
                              ),
                            ),
                          Text(
                            msg['text'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 16
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),
          
          // 2. HUD (The "Wingman" Panel)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              children: [
                // Suggestion Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: Colors.indigo[400]),
                          const SizedBox(width: 8),
                          Text("AI INSIGHT", style: TextStyle(color: Colors.indigo[400], fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentSuggestion,
                        style: TextStyle(color: Colors.indigo[900], fontSize: 16, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                
                // Mic Button (with Saving State)
                if (_isSaving)
                  Column(
                    children: [
                      CircularProgressIndicator(color: theme.colorScheme.primary),
                      const SizedBox(height: 10),
                      const Text("Saving Memories...", style: TextStyle(color: Colors.grey))
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _toggleSession,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: _isSessionActive ? Colors.redAccent : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isSessionActive ? Colors.redAccent : theme.colorScheme.primary).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2
                          )
                        ],
                      ),
                      child: Icon(
                        _isSessionActive ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 12),
                if (!_isSaving)
                  Text(
                    _isSessionActive ? "Listening..." : "Tap to Start",
                    style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}