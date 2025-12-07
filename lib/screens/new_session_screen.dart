import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/deepgram_service.dart';

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
    // Listen to Deepgram updates
    final deepgram = Provider.of<DeepgramService>(context, listen: false);
    deepgram.addListener(_onDeepgramUpdate);
  }

  @override
  void dispose() {
    final deepgram = Provider.of<DeepgramService>(context, listen: false);
    deepgram.removeListener(_onDeepgramUpdate);
    deepgram.disconnect(); // Ensure we disconnect when leaving
    _scrollController.dispose();
    super.dispose();
  }

  void _onDeepgramUpdate() {
    if (!mounted) return;
    final deepgram = Provider.of<DeepgramService>(context, listen: false);
    
    // Check for new transcript
    if (deepgram.currentTranscript.isNotEmpty) {
      // Simple de-duplication or just append for now
      if (_sessionLogs.isEmpty || _sessionLogs.last['text'] != deepgram.currentTranscript) {
         setState(() {
            // Determine speaker based on server info + manual swap
            String serverSpeaker = deepgram.currentSpeaker == "user" ? "User" : "Other";
            String finalSpeaker = serverSpeaker;
            
            if (_swapSpeakers) {
              finalSpeaker = serverSpeaker == "User" ? "Other" : "User";
            }

            _sessionLogs.add({
              "speaker": finalSpeaker,
              "text": deepgram.currentTranscript
            });
            _scrollToBottom();
            
            // If speaker is Other, ask Wingman
            if (finalSpeaker == "Other") {
               _askWingman(deepgram.currentTranscript);
            }
         });
      }
    }
  }

  Future<void> _askWingman(String transcript) async {
    final api = Provider.of<ApiService>(context, listen: false);
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    // Show loading state in suggestion box? Optional.
    // setState(() => _currentSuggestion = "Thinking...");

    final advice = await api.sendTranscriptToWingman(user.id, transcript);
    if (advice != null && mounted) {
       setState(() {
          _currentSuggestion = advice;
       });
    }
  }

  // ===========================================================
  // 🎤 CORE LOGIC: START / STOP
  // ===========================================================

  void _toggleSession() async {
    final deepgram = Provider.of<DeepgramService>(context, listen: false);
    final user = AuthService.instance.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found. Please login again.")),
        );
      }
      return;
    }

    if (_isSessionActive) {
      // STOP
      await deepgram.disconnect();
      _endSessionAndSave();
    } else {
      // START
      setState(() { 
        _isSessionActive = true; 
        _sessionLogs.clear(); 
        _currentSuggestion = "Connecting to Deepgram..."; 
      });
      
      await deepgram.connect();
      
      if (mounted) {
        setState(() {
          if (deepgram.isConnected) {
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

  Widget _buildAdviceContent(ThemeData theme) {
    // 1. Check if it's a structured response
    if (_currentSuggestion.contains("**Context-Based Advice:**")) {
      List<Widget> sections = [];
      
      // Regex to capture content between headers
      final adviceMatch = RegExp(r"\*\*Context-Based Advice:\*\*\s*(.*?)(?=\*\*Clarification Request:|\*\*Apology & Confirmation Statement:|$)", dotAll: true).firstMatch(_currentSuggestion);
      final clarificationMatch = RegExp(r"\*\*Clarification Request:\*\*\s*(.*?)(?=\*\*Apology & Confirmation Statement:|$)", dotAll: true).firstMatch(_currentSuggestion);
      final apologyMatch = RegExp(r"\*\*Apology & Confirmation Statement:\*\*\s*(.*)", dotAll: true).firstMatch(_currentSuggestion);

      if (adviceMatch != null && adviceMatch.group(1)!.trim().isNotEmpty) {
        sections.add(_buildSectionCard(
          theme, 
          "ADVICE", 
          adviceMatch.group(1)!.trim(), 
          Colors.green.shade100, 
          Colors.green.shade900,
          Icons.lightbulb_outline
        ));
      }

      if (clarificationMatch != null && clarificationMatch.group(1)!.trim().isNotEmpty) {
        sections.add(_buildSectionCard(
          theme, 
          "CLARIFICATION", 
          clarificationMatch.group(1)!.trim(), 
          Colors.amber.shade100, 
          Colors.amber.shade900,
          Icons.help_outline
        ));
      }

      if (apologyMatch != null && apologyMatch.group(1)!.trim().isNotEmpty) {
        sections.add(_buildSectionCard(
          theme, 
          "CONFIRMATION", 
          apologyMatch.group(1)!.trim(), 
          Colors.blueGrey.shade100, 
          Colors.blueGrey.shade900,
          Icons.info_outline
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      );
    } 
    
    // 2. Fallback / Status Message
    return Text(
      _currentSuggestion,
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, height: 1.4, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildSectionCard(ThemeData theme, String title, String content, Color bg, Color fg, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
          ),
        ],
      ),
    );
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
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.85, // Max 85% of screen height
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: _buildAdviceContent(theme),
                          ),
                        ),
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
          ),
        ],
      ),
    );
  }
}