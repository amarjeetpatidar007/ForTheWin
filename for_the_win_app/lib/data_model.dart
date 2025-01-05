import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';

// Data Models
class LangflowResponse {
  final String sessionId;
  final List<OutputWrapper> outputs;

  LangflowResponse({
    required this.sessionId,
    required this.outputs,
  });

  factory LangflowResponse.fromJson(Map<String, dynamic> json) {
    return LangflowResponse(
      sessionId: json['session_id'] ?? '',
      outputs: (json['outputs'] as List)
          .map((output) => OutputWrapper.fromJson(output))
          .toList(),
    );
  }
}

class OutputWrapper {
  final Map<String, dynamic> inputs;
  final List<OutputContent> outputs;

  OutputWrapper({
    required this.inputs,
    required this.outputs,
  });

  factory OutputWrapper.fromJson(Map<String, dynamic> json) {
    return OutputWrapper(
      inputs: json['inputs'] as Map<String, dynamic>,
      outputs: (json['outputs'] as List)
          .map((output) => OutputContent.fromJson(output))
          .toList(),
    );
  }
}

class OutputContent {
  final MessageResult results;

  OutputContent({
    required this.results,
  });

  factory OutputContent.fromJson(Map<String, dynamic> json) {
    return OutputContent(
      results: MessageResult.fromJson(json['results']),
    );
  }
}

class MessageResult {
  final MessageData message;

  MessageResult({
    required this.message,
  });

  factory MessageResult.fromJson(Map<String, dynamic> json) {
    return MessageResult(
      message: MessageData.fromJson(json['message']),
    );
  }
}

class MessageData {
  final String text;
  final String sender;
  final String senderName;
  final String sessionId;
  final DateTime timestamp;
  final bool error;
  final bool edit;
  final MessageProperties properties;

  MessageData({
    required this.text,
    required this.sender,
    required this.senderName,
    required this.sessionId,
    required this.timestamp,
    required this.error,
    required this.edit,
    required this.properties,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      text: json['data']['text'] ?? '',
      sender: json['data']['sender'] ?? '',
      senderName: json['data']['sender_name'] ?? '',
      sessionId: json['data']['session_id'] ?? '',
      timestamp: DateTime.parse(json['data']['timestamp']),
      error: json['data']['error'] ?? false,
      edit: json['data']['edit'] ?? false,
      properties: MessageProperties.fromJson(json['data']['properties']),
    );
  }
}

class MessageProperties {
  final String textColor;
  final String backgroundColor;
  final bool edited;
  final MessageSource source;
  final String icon;
  final bool allowMarkdown;
  final String state;

  MessageProperties({
    required this.textColor,
    required this.backgroundColor,
    required this.edited,
    required this.source,
    required this.icon,
    required this.allowMarkdown,
    required this.state,
  });

  factory MessageProperties.fromJson(Map<String, dynamic> json) {
    return MessageProperties(
      textColor: json['text_color'] ?? '',
      backgroundColor: json['background_color'] ?? '',
      edited: json['edited'] ?? false,
      source: MessageSource.fromJson(json['source']),
      icon: json['icon'] ?? '',
      allowMarkdown: json['allow_markdown'] ?? false,
      state: json['state'] ?? '',
    );
  }
}

class MessageSource {
  final String id;
  final String displayName;
  final String source;

  MessageSource({
    required this.id,
    required this.displayName,
    required this.source,
  });

  factory MessageSource.fromJson(Map<String, dynamic> json) {
    return MessageSource(
      id: json['id'] ?? '',
      displayName: json['display_name'] ?? '',
      source: json['source'] ?? '',
    );
  }
}

// Chat Message UI Model
class ChatMessage {
  final String text;
  final bool isUser;
  final String senderName;
  final DateTime timestamp;
  final String sessionId;
  final MessageProperties? properties;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.senderName,
    required this.timestamp,
    required this.sessionId,
    this.properties,
  });

  factory ChatMessage.fromMessageData(MessageData data) {
    return ChatMessage(
      text: data.text,
      isUser: data.sender != 'Machine',
      senderName: data.senderName,
      timestamp: data.timestamp,
      sessionId: data.sessionId,
      properties: data.properties,
    );
  }
}
