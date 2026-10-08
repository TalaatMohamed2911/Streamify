import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../livestream_states/backstage_widget.dart';
import '../livestream_states/livestream_ended_widget.dart';
import '../livestream_states/livestream_live_widget.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({
    super.key,
    required this.liveStreamCall,
    required this.callId,
  });

  final Call liveStreamCall;
  final String callId;

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  @override
  Widget build(BuildContext context) {
    return PartialCallStateBuilder(
      call: widget.liveStreamCall,
      selector: (state) =>
          (isBackstage: state.isBackstage, endedAt: state.endedAt),
      builder: (context, callState) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              if (callState.isBackstage) {
                return BackstageWidget(
                  call: widget.liveStreamCall,
                  callId: widget.callId,
                );
              }
              if (callState.endedAt != null) {
                // الوقت خلص مفيش وقت خلاص
                // Livestream has ended
                return LivestreamEndedWidget(call: widget.liveStreamCall);
              }
              return LivestreamLiveWidget(
                call: widget.liveStreamCall,
                callId: widget.callId,
              );
            },
          ),
        );
      },
    );
  }
}
