import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:charity_trust/src/data/utils/globals.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer';

typedef MessageCallback = void Function(Map<String, dynamic> message);
typedef StatusCallback = void Function(SocketStatus status);
typedef HistoryCallback = void Function(
  List<dynamic> messages,
  int totalCount,
  String? error,
);
typedef GenericAckCallback = void Function(String? error);

enum SocketStatus { connected, disconnected, connecting, error }

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  SocketStatus status = SocketStatus.disconnected;
  bool debug = true;
  bool verbose = false;

  StatusCallback? onStatusChange;
  void Function(List<dynamic> conversations)? onConversationsList;
  void Function(Map<String, dynamic> message)? onMessageReceived;
  void Function(Map<String, dynamic> status)? onTyping;
  void Function(Map<String, dynamic> msg)? onDelivered;
  void Function(Map<String, dynamic> msg)? onSeen;
  void Function(dynamic status)? onUserStatus;

  void connect() {
    if (_socket != null && _socket!.connected) {
      _log("Already connected. Skipping reconnect.");
      return;
    }

    _log("Attempting to connect to socket...");
    status = SocketStatus.connecting;
    _notifyStatus();

    _socket = IO.io(
      'https://api.charity_trust.org',
      {
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {
          'api_key': dotenv.env['API_KEY'] ?? '',
          'token': token,
        }
      },
    );

    _socket!.connect();

    _socket!
      ..onConnect((_) {
        status = SocketStatus.connected;
        _log("✅ Connected to socket: ID = ${_socket?.id}");
        _notifyStatus();
      })
      ..onDisconnect((reason) {
        status = SocketStatus.disconnected;
        _log("⚠️ Disconnected: $reason");
        _notifyStatus();
      })
      ..onError((err) {
        status = SocketStatus.error;
        _log("❌ Socket error: $err", isError: true);
        _notifyStatus();
      })
      ..onConnectError((err) {
        status = SocketStatus.error;
        _log("❌ Connect error: $err", isError: true);
        _notifyStatus();
      });

    _log("Connection initiated.");
  }

  void disconnect() {
    _log("Disconnecting socket...");
    _socket?.disconnect();
    _socket = null;
    status = SocketStatus.disconnected;
    _notifyStatus();
  }

  void subscribeConversations({GenericAckCallback? onAck}) {
    const event = 'conversations:subscribe';
    _logEmit(event, null);

    _socket?.emitWithAck(event, null, ack: (data) {
      if (data is List) {
        onAck?.call(null);
      } else {
        onAck?.call(data?.toString());
      }
    });

    const listenEvent = 'conversations:list';
    _logEvent(listenEvent);
    _socket?.on(listenEvent, (data) {
      _log("📥 Received '$listenEvent': ${data?.toString()}");
      onConversationsList?.call(data);
    });
  }

  void joinChat(String conversationId) {
    socket?.emit(
      'chat:join',
      conversationId,
    );

    socket?.on('chat:join', (data) {
      print('joined: $data');
    });
  }

  void fetchHistory(
    String conversationId, {
    int page = 1,
    int limit = 20,
    required HistoryCallback onHistory,
  }) {
    const event = 'chat:history';
    final payload = {
      'conversation_id': conversationId,
      'page': page,
      'limit': limit,
    };

    _logEmit(event, payload);
    print('[Socket] Emitting $event with payload: $payload');

    _socket?.emitWithAck(event, payload, ack: (response) {
      log('[Socket] Received ack for $event: $response');

      try {
        if (response is List && response.length >= 3) {
          final error = response[0];
          final messages = response[1];
          final totalCount = response[2];

          print(
              '[Socket] Parsed response: error=$error, totalCount=$totalCount');
          print('[Socket] Messages type: ${messages.runtimeType}');

          if (error == null && messages is List && totalCount is int) {
            onHistory(messages, totalCount, null);
          } else {
            final errorMsg = 'Invalid data structure in response: '
                'error=$error, messagesType=${messages.runtimeType}, totalCountType=${totalCount.runtimeType}';
            print('[Socket][Error] $errorMsg');
            onHistory([], 0, errorMsg);
          }
        } else {
          final errorMsg =
              'Unexpected response format: Expected List with at least 3 elements';
          print('[Socket][Error] $errorMsg');
          onHistory([], 0, errorMsg);
        }
      } catch (e, stackTrace) {
        final errorMsg = 'Exception while parsing socket response: $e';
        print('[Socket][Exception] $errorMsg');
        print(stackTrace);
        onHistory([], 0, errorMsg);
      }
    });
  }

  void sendMessage(
    String conversationId,
    String message, {
    List<Map<String, dynamic>> attachments = const [],
    Function(String? error, Map<String, dynamic>? message)? onAck,
  }) {
    const event = 'chat:message';
    final payload = {
      'conversation_id': conversationId,
      'message': message,
      'attachments': attachments,
    };

    _logEmit(event, payload);

    if (_socket == null) {
      log('[Socket] sendMessage failed: socket is null');
      onAck?.call('Socket is not connected', null);
      return;
    }

    try {
      _socket!.emitWithAck(event, payload, ack: (data) {
        log('[Socket] Acknowledgement received for $event');

        if (data == null) {
          log('[Socket] Ack data is null');
          onAck?.call('No response from server', null);
          return;
        }

        log('[Socket] Ack data: $data');

        try {
          if (data is List &&
              data.length >= 2 &&
              data[1] is Map<String, dynamic>) {
            onAck?.call(null, data[1] as Map<String, dynamic>);
          } else if (data is Map<String, dynamic>) {
            onAck?.call(null, data);
          } else {
            onAck?.call('Unexpected response format: $data', null);
          }
        } catch (e, stack) {
          log('[Socket] Ack processing error: $e');
          log(stack.toString());
          onAck?.call('Error processing server response', null);
        }
      });
    } catch (e, stack) {
      log('[Socket] emitWithAck failed: $e');
      log(stack.toString());
      onAck?.call('Failed to emit message', null);
    }
  }

  void markDelivered(String messageId) {
    const event = 'chat:delivered';
    final data = {'message_id': messageId};
    _logEmit(event, data);
    _socket?.emit(event, data);
  }

  void markSeen(String messageId) {
    const event = 'chat:seen';
    final data = {'message_id': messageId};
    _logEmit(event, data);
    _socket?.emit(event, data);
  }

  void sendTyping(String conversationId, bool isTyping) {
    const event = 'chat:typing';
    final data = {
      'conversation_id': conversationId,
      'is_typing': isTyping,
    };
    _logEmit(event, data);
    _socket?.emit(event, data);
  }

  void listenChatEvents() {
    _registerEvent('chat:message', onMessageReceived);
    _registerEvent('chat:typing', onTyping);
    _registerEvent('chat:delivered', onDelivered);
    _registerEvent('chat:seen', onSeen);
    _registerEvent('user:status', onUserStatus);
  }

  void _registerEvent(String eventName, Function? callback) {
    _logEvent(eventName);
    _socket?.on(eventName, (data) {
      _log("📥 Event '$eventName': $data");
      if (callback != null) callback(data);
    });
  }

  void _notifyStatus() {
    if (onStatusChange != null) {
      _log("Status changed to: $status");
      onStatusChange!(status);
    }
  }

  void _log(String message, {bool isError = false}) {
    if (debug) {
      final logMsg = '[SocketService] $message';
      isError ? log(logMsg, level: 1000) : log(logMsg);
    }
  }

  void _logEmit(String event, dynamic data) {
    if (debug && verbose) {
      _log("📤 Emitting event: '$event' with data: $data");
    }
  }

  void _logEvent(String event) {
    if (debug && verbose) {
      _log("📥 Listening for event: '$event'");
    }
  }

  IO.Socket? get socket => _socket;
}
