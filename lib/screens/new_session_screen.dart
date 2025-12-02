import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/livekit_service.dart';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  // --- CORE VARIABLES ---
  
  // State Flags
  bool _isSessionActive = false;
  bool _isSaving = false;
  bool _swapSpeakers = false; // Manual toggle for "Diarization Drift"
  
  // Data
  final List<Map<String, dynamic>> _sessionLogs = [];
  String _currentSuggestion = "Tap mic to start Wingman...";
  
  // Controllers
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen to LiveKit updates
    final liveKit = Provider.of<LiveKitService>(context, listen: false);
    liveKit.addListener(_onLiveKitUpdate);
  }

  @override
  void dispose() {
    final liveKit = Provider.of<LiveKitService>(context, listen: false);
    liveKit.removeListener(_onLiveKitUpdate);
    liveKit.disconnect(); // Ensure we disconnect when leaving
    _scrollController.dispose();
    super.dispose();
  }

  void _onLiveKitUpdate() {
    if (!mounted) return;
    final liveKit = Provider.of<LiveKitService>(context, listen: false);
    
    // Check for new transcript
    if (liveKit.currentTranscript.isNotEmpty) {
      // In a real app, we'd handle partial vs final more gracefully.
      // For now, let's just add it if it's new or update the last one.
      // Since the service just gives us the latest string event, we might need to be smarter.
      // But for this demo, let's assume the service notifies us on every new sentence.
      
      // Simple de-duplication or just append for now
      if (_sessionLogs.isEmpty || _sessionLogs.last['text'] != liveKit.currentTranscript) {
         setState(() {
            _sessionLogs.add({
              "speaker": _swapSpeakers ? "Other" : "User", // Simple assumption for now
              "text": liveKit.currentTranscript
            });
            _scrollToBottom();
         });
      }
    }
  }

  // ===========================================================
  // 🎤 CORE LOGIC: START / STOP
  // ===========================================================

  void _toggleSession() async {
    final liveKit = Provider.of<LiveKitService>(context, listen: false);

    if (_isSessionActive) {
      // STOP
      await liveKit.disconnect();
      _endSessionAndSave();
    } else {
      // START
      setState(() { 
        _isSessionActive = true; 
        _sessionLogs.clear(); 
        _currentSuggestion = "Connecting to LiveKit..."; 
      });
      
      await liveKit.connect();
      
      if (mounted) {
        setState(() {
          if (liveKit.isConnected) {
            _currentSuggestion = "Listening...";
          } else {
            _isSessionActive = false;
            _currentSuggestion = "Connection Failed";
          }
        });
      }
    }
  }

  // This function is responsible for saving the history when the user stops
  Future<void> _endSessionAndSave() async {
    setState(() { _isSessionActive = false; });
    
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
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    Icon(Icons.mic_none, size: 60, color: Colors.grey[400])
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2000.ms),
                    const SizedBox(height: 10),
                    Text("Ready to listen...", style: TextStyle(color: Colors.grey[500], fontSize: 16))
                        .animate().fadeIn(delay: 500.ms),
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
                        color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
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
                              color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                              fontSize: 16
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slide(
                    begin: isMe ? const Offset(0.2, 0) : const Offset(-0.2, 0),
                    end: Offset.zero,
                    curve: Curves.easeOutQuad,
                  );
                },
              ),
          ),
          
          // 2. HUD (The "Wingman" Panel)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              children: [
                // Suggestion Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: Colors.indigo[400]),
                          const SizedBox(width: 8),
                          Text("AI INSIGHT", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentSuggestion,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, height: 1.4, fontWeight: FontWeight.w500),
                      ).animate(key: ValueKey(_currentSuggestion)).fadeIn(),
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
                  ).animate().fadeIn()
                else
                  GestureDetector(
                    onTap: _toggleSession,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: _isSessionActive ? theme.colorScheme.error : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isSessionActive ? theme.colorScheme.error : theme.colorScheme.primary).withOpacity(0.4),
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
                    ).animate(target: _isSessionActive ? 1 : 0).shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.5)),
                  ),
                  
                const SizedBox(height: 12),
                if (!_isSaving)
                  Text(
                    _isSessionActive ? "Listening..." : "Tap to Start",
                    style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                  ).animate().fadeIn(),
              ],
            ),
          ).animate().slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}