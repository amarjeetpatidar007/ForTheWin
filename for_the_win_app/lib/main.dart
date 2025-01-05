import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data_model.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Analysis App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ChatScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media Analysis App'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Langflow Chat Analytics',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'This project leverages Langflow API and DataStax to build a chat-based analytics application for social media engagement insights. Users can input queries to retrieve data about various types of social media content like reels, carousels, and static images.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Features:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '1. Real-time chat-based interface to ask for insights.\n'
                    '2. Insightful engagement data on reels, carousels, and images.\n'
                    '3. Dynamic responses based on user queries.\n',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),

              const Text(
                'Objective:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'The goal of this project is to create an interactive platform that allows users to retrieve detailed social media engagement analytics, helping businesses or individuals understand the performance of their content.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
    );
  }
}




class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _currentSessionId;
  final String apiKey = dotenv.env['apiKey'] ?? "Key";
  final String apiUrl = 'https://api.langflow.astra.datastax.com/lf/e45ff30b-a86b-4fdd-ae0d-047d63109aa2/api/v1/run/01e9f89a-fdd9-4975-9a28-2fe47a2265d8?stream=false';




  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      senderName: 'User',
      timestamp: DateTime.now(),
      sessionId: _currentSessionId ?? '',
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $apiKey",
        },
        body: jsonEncode({
          'input_value': text,
          'output_type': 'chat',
          'input_type': 'chat',
          'tweaks': {
            'ChatInput-39jCB': {},
            'AstraDBToolComponent-6MlzD': {},
            'Prompt-ow0p5': {},
            'GoogleGenerativeAIModel-z7fUL': {},
            'ParseData-pw7Sb': {},
            'ChatOutput-fbqSQ': {}
          },
        }),
      );
      // print(response.body);
      // print(response.statusCode);

      if (response.statusCode == 200) {
        final langflowResponse = LangflowResponse.fromJson(jsonDecode(response.body));
        final messageData = langflowResponse.outputs.first.outputs.first.results.message;

        _currentSessionId = messageData.sessionId;

        final aiMessage = ChatMessage.fromMessageData(messageData);

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });
      } else {
        _handleError('Failed to get response from server');
      }
    } catch (e) {
      _handleError(e.toString());
    }

    _scrollToBottom();
  }

  void _handleError(String errorMessage) {
    setState(() {
      _messages.add(ChatMessage(
        text: 'Error: $errorMessage',
        isUser: false,
        senderName: 'System',
        timestamp: DateTime.now(),
        sessionId: _currentSessionId ?? '',
      ));
      _isLoading = false;
    });
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

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment:
        message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.senderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
              Text(
                ' • ${message.timestamp.toLocal().toString().substring(11, 16)}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
              if (message.properties?.source.displayName != null)
                Text(
                  ' • ${message.properties!.source.displayName}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4.0),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16.0),
                strong: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessage(_messages[index]),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: _handleSubmitted,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}