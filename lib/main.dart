import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_tutorial/signaling.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use platform-specific FirebaseOptions
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atom8',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize video renderers
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    // Set up callback for remote stream
    signaling.onAddRemoteStream = (MediaStream stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sanjay Kumar Assesment for Atom8"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  signaling.openUserMedia(_localRenderer, _remoteRenderer);
                },
                child: const Text("Open camera & microphone"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  roomId = await signaling.createRoom(_remoteRenderer);
                  if (roomId != null) {
                    textEditingController.text = roomId!;
                    setState(() {});
                  }
                },
                child: const Text("Create room"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
  onPressed: () {
    final roomId = textEditingController.text.trim();
    if (roomId.isNotEmpty) {
      signaling.joinRoom(roomId, _remoteRenderer);
    } else {
      print('Room ID cannot be empty');
    }
  },
  child: const Text("Join room"),
),

              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                },
                child: const Text("Hangup"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: RTCVideoView(
                      _localRenderer,
                      mirror: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RTCVideoView(_remoteRenderer),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                      hintText: "Enter Room ID",
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
