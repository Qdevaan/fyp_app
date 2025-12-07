import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import '../services/api_service.dart';
import '../services/auth_service.dart';

class ConsultantScreen extends StatefulWidget {
  const ConsultantScreen({super.key});

  @override
  State<ConsultantScreen> createState() => _ConsultantScreenState();
}

class _ConsultantScreenState extends State<ConsultantScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, String>> _messages = [];
  
  bool _loading = false;
  bool _initializing = false;
  bool _historyLoaded = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0.0) {
      _scrollToBottom();
    }
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (maxScroll - currentScroll > 200) {
        if (!_showScrollToBottom) setState(() => _showScrollToBottom = true);
      } else {
        if (_showScrollToBottom) setState(() => _showScrollToBottom = false);
      }
    }
  }

  Future<void> _loadChatHistory() async {
    if (_historyLoaded) return;
    
    setState(() => _initializing = true);
    
    final user = AuthService.instance.currentUser;
    if (user == null) {
      setState(() => _initializing = false);
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('consultant_logs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          List<Map<String, String>> history = [];

          for (var log in response) {
            if (log['question'] != null) {
              history.add({"role": "user", "text": log['question']});
            }
            if (log['answer'] != null) {
              history.add({"role": "ai", "text": log['answer']});
            }
          }
          
          if (history.isNotEmpty) {
             _messages.insertAll(0, history);
             if (_messages.isEmpty) {
                _messages.add({
                  "role": "ai", 
                  "text": "Hello! I have access to your past conversation history. Ask me anything about what you've discussed previously."
                });
             }
          } else if (_messages.isEmpty) {
             _messages.add({
                "role": "ai", 
                "text": "Hello! I have access to your past conversation history. Ask me anything about what you've discussed previously."
              });
          }

          _initializing = false;
          _historyLoaded = true;
        });
        
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _saveInteraction(String question, String answer) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('consultant_logs').insert({
        'user_id': user.id,
        'question': question,
        'answer': answer,
      });
    } catch (e) {
      debugPrint("Error saving interaction: $e");
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = AuthService.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not logged in. Please log in to use this feature."),
            backgroundColor: Colors.redAccent,
          )
        );
      }
      return;
    }

    setState(() {
      _messages.add({"role": "user", "text": text});
      _loading = true;
      _controller.clear();
    });
    
    _scrollToBottom();

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final answer = await api.askConsultant(user.id, text);

      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "text": answer});
        });
        _scrollToBottom();
        
        await _saveInteraction(text, answer);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "text": "Error connecting to consultant: $e"});
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showCenterLoadButton = _messages.isEmpty && !_historyLoaded && !_initializing;
    final bool showInputLoadButton = _messages.isNotEmpty && !_historyLoaded && !_initializing;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Consultant AI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // --- CHAT HISTORY AREA ---
              Expanded(
                child: _initializing 
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty && !_historyLoaded
                    ? const SizedBox.shrink() // Blank screen initially
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          bool isUser = msg['role'] == "user";
                          
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                                ]
                              ),
                              child: isUser 
                                ? Text(
                                    msg['text']!, 
                                    style: const TextStyle(color: Colors.white, fontSize: 15)
                                  )
                                : MarkdownBody(
                                    data: msg['text']!, 
                                    styleSheet: MarkdownStyleSheet(
                                      p: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
                                    )
                                  ),
                            ),
                            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                        },
                      ),
              ),
              
              // --- LOADING INDICATOR ---
              if (_loading) 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)
                      ),
                      const SizedBox(width: 8),
                      Text("Consultant is thinking...", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),

              // --- INPUT AREA ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
                  ]
                ),
                child: Row(
                  children: [
                    // Circular Load History Button
                    if (showInputLoadButton)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: _loadChatHistory,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            child: Icon(Icons.history, color: theme.colorScheme.onSecondaryContainer, size: 20),
                          ),
                        ),
                        ),

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Ask something...",
                          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), 
                            borderSide: BorderSide.none
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _loading ? null : _sendMessage,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: _loading ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary,
                        child: Icon(Icons.send_rounded, color: _loading ? theme.colorScheme.onSurfaceVariant : Colors.white, size: 20),
                      ),
                    )
                  ],
                  
                ),
              )
            ],
          ),

          // --- CENTER LOAD BUTTON ---
          if (showCenterLoadButton)
            Center(
              child: ElevatedButton.icon(
                onPressed: _loadChatHistory,
                icon: const Icon(Icons.history),
                label: const Text("Load Previous Chat"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),

          // --- SCROLL TO BOTTOM BUTTON ---
          if (_showScrollToBottom)
            Positioned(
              bottom: 100, // Above the input area
              right: 20,
              child: GestureDetector(
                onTap: _scrollToBottom,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
            ),
        ],
      ),
    );
  }
}