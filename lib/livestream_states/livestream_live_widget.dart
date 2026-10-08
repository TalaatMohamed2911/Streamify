/*the LivestreamLiveWidget will display the host's livestream video feed 
and controls. */

import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class LivestreamLiveWidget extends StatelessWidget {
  const LivestreamLiveWidget({
    super.key,
    required this.call,
    required this.callId,
  });

  final Call call;
  final String callId;

  @override
  Widget build(BuildContext context) {
    // When the livestream is live we have to listen to all call state changes.
    return StreamCallContainer(
      call: call,
      callContentWidgetBuilder: (context, call) {
        return PartialCallStateBuilder(
          call: call,
          selector: (state) => state.callParticipants
              .where((participant) => participant.roles.contains('host'))
              .toList(),
          builder: (context, hosts) {
            if (hosts.isEmpty) {
              return const Center(
                child: Text("The host's video is not available"),
              );
            }
            return StreamCallContent(
              call: call,
              callAppBarWidgetBuilder: (context, call) => CallAppBar(
                call: call,
                showBackButton: false,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PartialCallStateBuilder(
                      call: call,
                      selector: (state) => state.callParticipants.length,
                      builder: (context, count) => Text('Viewers: $count'),
                    ),
                    Text(
                      'Call ID: $callId',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                onLeaveCallTap: () {
                  call.stopLive();
                },
              ),

              callParticipantsWidgetBuilder: (context, call) {
                return StreamCallParticipants(call: call, participants: hosts);
              },
            );
          },
        );
      },
    );
  }
}
