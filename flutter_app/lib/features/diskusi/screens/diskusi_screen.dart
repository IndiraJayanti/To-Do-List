import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:flutter_app/models/discussion_message.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/graphql/client.dart';

class DiskusiScreen extends StatefulWidget {
  const DiskusiScreen({super.key});

  @override
  State<DiskusiScreen> createState() => _DiskusiScreenState();
}

class _DiskusiScreenState extends State<DiskusiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<DiscussionMessage> _messages = [];
  late WebSocketChannel _channel;
  String _username = 'Guest';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _connectWebSocket();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          if (payload['name'] != null) {
            setState(() {
              _username = payload['name'];
            });
          }
        }
      } catch (e) {
        print('Error decoding token for username: $e');
      }
    }
  }

  void _connectWebSocket() {
    // Construct WebSocket URL. Use 'ws://' for http, 'wss://' for https.
    // Ensure this matches your server's WebSocket endpoint.
    // For Android Emulator, use 10.0.2.2. For web/iOS/desktop, use localhost.
    String wsEndpoint;
    if (graphqlEndpoint.contains('10.0.2.2')) {
      wsEndpoint = 'ws://10.0.2.2:8080/ws';
    } else {
      wsEndpoint = 'ws://localhost:8080/ws';
    }

    _channel = WebSocketChannel.connect(Uri.parse(wsEndpoint));

    _channel.stream.listen(
      (message) {
        // Handle incoming messages
        final decodedMessage = jsonDecode(message);
        final msg = DiscussionMessage.fromJson(decodedMessage);
        setState(() {
          _messages.add(msg);
        });
      },
      onDone: () {
        setState(() {
          _isConnected = false;
        });
        print('WebSocket disconnected');
        // Optional: Reconnect logic here
      },
      onError: (error) {
        setState(() {
          _isConnected = false;
        });
        print('WebSocket error: $error');
        // Optional: Reconnect logic here
      },
    );

    setState(() {
      _isConnected = true;
    });
    print('WebSocket connected to $wsEndpoint');
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = DiscussionMessage(
        username: _username,
        content: _messageController.text,
        timestamp: '',
      );
      _channel.sink.add(jsonEncode(message.toJson()));
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color greenText = const Color(0xFF3F6B3F);
    final Color pastelGreen = const Color(0xFFCDEAC0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diskusi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: greenText,
      ),
      body: Column(
        children: [
          _isConnected
              ? Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.green[100],
                  child: Center(
                    child: Text(
                      'Connected as $_username',
                      style: TextStyle(color: greenText),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.red[100],
                  child: const Center(
                    child: Text(
                      'Disconnected from chat. Please restart app.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMyMessage = msg.username == _username; 

                return Align(
                  alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: isMyMessage ? greenText.withOpacity(0.8) : pastelGreen,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMyMessage ? 'You' : msg.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMyMessage ? Colors.white : greenText,
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          msg.content,
                          style: TextStyle(
                            color: isMyMessage ? Colors.white : Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          msg.timestamp,
                          style: TextStyle(
                            color: isMyMessage ? Colors.white70 : Colors.grey[600],
                            fontSize: 10.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: pastelGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _isConnected ? _sendMessage : null,
                  backgroundColor: greenText,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}