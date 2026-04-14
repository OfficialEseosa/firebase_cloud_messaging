import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/fcm_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();

  String _statusText = 'Waiting for a cloud message...';
  String _imagePath = 'assets/images/default.png';
  String? _networkImageUrl;
  String? _fcmToken;
  String? _lastPayload;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    await _fcmService.initialize(onData: _handleMessage);
    final token = await _fcmService.getToken();
    setState(() {
      _fcmToken = token;
    });
  }

  void _handleMessage(RemoteMessage message) {
    final imageUrl = message.data['image'] ?? message.notification?.android?.imageUrl;
    final asset = message.data['asset'] ?? 'default';
    final validAssets = ['default', 'promo', 'alert'];
    final resolvedAsset = validAssets.contains(asset) ? asset : 'default';

    setState(() {
      _statusText = message.notification?.title ?? 'Payload received';
      if (imageUrl != null && imageUrl.toString().startsWith('http')) {
        _networkImageUrl = imageUrl.toString();
      } else {
        _networkImageUrl = null;
        _imagePath = 'assets/images/$resolvedAsset.png';
      }
      _lastPayload =
          'Title: ${message.notification?.title ?? 'N/A'}\n'
          'Body: ${message.notification?.body ?? 'N/A'}\n'
          'Data: ${message.data}';
    });
  }

  void _copyToken() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.notifications, size: 40, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    Text(
                      _statusText,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image driven by payload
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _networkImageUrl != null
                  ? Image.network(
                      _networkImageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey.shade100,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 60),
                      ),
                    )
                  : Image.asset(
                      _imagePath,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 60),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Last payload display
            if (_lastPayload != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Message Received',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _lastPayload!,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // FCM Token display
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Device FCM Token',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: _copyToken,
                        ),
                      ],
                    ),
                    SelectableText(
                      _fcmToken ?? 'Fetching token...',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
