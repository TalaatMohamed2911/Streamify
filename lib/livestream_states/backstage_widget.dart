/*the BackstageWidget will display  a "countdown timer" 
and "a message indicating that the livestream is starting soon" 
and "the number of participants waiting to join".
We'll also add a button to transition the call from backstage mode 
"to live mode" or "to leave the call".
By calling call.goLive() the call will transition from backstage mode 
to live mode and allow other participants to join the call.

All permissions can also be adjusted in the Stream Video Dashboard. */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class BackstageWidget extends StatelessWidget {
  const BackstageWidget({super.key, required this.call, required this.callId});

  final Call call;
  final String callId;

  @override
  Widget build(BuildContext context) {
    return PartialCallStateBuilder(
      call: call,
      selector: (callState) => callState.callParticipants
          .where((participant) => !participant.roles.contains('host'))
          .length,
      builder: (context, waitingParticipantsCount) {
        return Center(
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PartialCallStateBuilder(
                call: call,
                selector: (state) => state.startsAt,
                builder: (context, startsAt) {
                  return Text(
                    startsAt != null
                        ? 'Livestream starting at ${DateFormat('HH:mm').format(startsAt.toLocal())}'
                        : 'Livestream starting soon',
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                },
              ),
              if (waitingParticipantsCount > 0)
                Text('$waitingParticipantsCount participants waiting'),
              ElevatedButton(
                onPressed: () {
                  call.goLive();
                },
                child: const Text('Go Live'),
              ),
              ElevatedButton(
                onPressed: () {
                  call.leave();
                  Navigator.pop(context);
                },
                child: const Text('Leave Livestream'),
              ),
            ],
          ),
        );
      },
    );
  }
}
