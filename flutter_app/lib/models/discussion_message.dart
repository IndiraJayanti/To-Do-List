// todo_fullstack8/flutter_app/lib/models/discussion_message.dart
class DiscussionMessage {
  final String username;
  final String content;
  final String timestamp;

  DiscussionMessage({
    required this.username,
    required this.content,
    required this.timestamp,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'content': content,
      'timestamp': timestamp,
    };
  }
}