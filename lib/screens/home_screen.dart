import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import 'live_stream_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? createLoadingText;
  String? viewLoadingText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestreaming Tutorial'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () {})],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            ElevatedButton(
              onPressed: createLoadingText == null
                  ? () async {
                      setState(
                        () => createLoadingText = 'creating livestream...',
                      );
                      await _createLivestream();
                      setState(() => createLoadingText = null);
                    }
                  : null,
              child: Text(createLoadingText ?? 'Create a Livestream'),
            ),
            ElevatedButton(
              onPressed: viewLoadingText == null
                  ? () {
                      setState(() => viewLoadingText = 'Joining Livestream...');
                      _viewLivestream();
                      setState(() => viewLoadingText = null);
                    }
                  : null,
              child: Text(viewLoadingText ?? 'View a Livestream'),
            ),
          ],
        ),
      ),
    );
  }

  String _generateRandomCallId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _createLivestream() async {
    // Generate a random short call ID
    final callId = _generateRandomCallId();

    // initialize call instance(Call<=makeCall() method)with the callType liveStream
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.liveStream(),
      id: callId, // Unique ID for the call, can be any string
    );

    // Create the call and set the current user as a host
    final result = await call.getOrCreate(
      // ringing: true, // If true, the call will ring when a user joins
      members: [
        MemberRequest(
          userId: StreamVideo.instance.currentUser.id,
          role: 'host',
        ),
      ],
    );

    if (result.isFailure) {
      log('Not able to create a call.');
      return;
    }

    // Configure the call to allow users to join before it starts by setting a future start time
    // and specifying how many seconds in advance they can join via `joinAheadTimeSeconds`
    final updateResult = await call.update(
      startsAt: DateTime.now().toUtc().add(Duration(seconds: 120)),
      backstage: StreamBackstageSettings(
        enabled: true, //by default, backstage is enabled
        // If backstage mode is enabled,
        //the call hosts can join and see each other but the call will be invisible to others until `call.goLive()` is called.
        joinAheadTimeSeconds: 300, //If you want to allow users to join before the livestream starts,
        // you can set the joinAheadTimeSeconds parameter when creating the call.
      ),
    );
    if (updateResult.isFailure) {
      log('Not able to update the call.');
      return;
    }

    // Set some default behaviour for how our devices should be configured once we join a call
    final connectOptions = CallConnectOptions(
      camera: TrackOption.enabled(),
      microphone: TrackOption.enabled(),
      // screenShare: TrackOption.enabled(),
    );
    // Our local app user can join and receive events
    await call.join(connectOptions: connectOptions);

    // Navigate to the call screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            LiveStreamScreen(liveStreamCall: call, callId: callId),
      ),
    );
  }

  Future<void> _viewLivestream() async {
    // Show dialog to get call ID from user
    final callId = await _showCallIdDialog();
    if (callId == null || callId.isEmpty) {
      return;
    }
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.liveStream(),
      id: callId,
    );

    final result = await call.getOrCreate();
    if (result.isSuccess) {
      final connectOptions = CallConnectOptions(
        camera: TrackOption.enabled(),
        microphone: TrackOption.enabled(),
      );
      await call.join(connectOptions: connectOptions);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Livestream'),
              leading: IconButton(
                onPressed: () {
                  call.leave();
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: LivestreamPlayer(
              call: call,
              joinBehaviour: LivestreamJoinBehaviour.autoJoinAsap,
              connectOptions: connectOptions,
            ),
          ),
        ),
      );
    } else {
      log('Not able to create a call.');
    }
  }

  Future<String?> _showCallIdDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Call ID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter the livestream call ID',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
