import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CallActionButtons extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String? appointmentId;
  final bool showVideoCall;
  final bool showVoiceCall;
  final VoidCallback? onCallStarted;

  const CallActionButtons({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    this.appointmentId,
    this.showVideoCall = true,
    this.showVoiceCall = true,
    this.onCallStarted,
  }) : super(key: key);

  void _startCall(BuildContext context, bool isVideoCall) {
    final channelName =
        appointmentId != null
            ? 'appointment_$appointmentId'
            : 'doctor_${doctorId}_${DateTime.now().millisecondsSinceEpoch}';

    Navigator.pushNamed(
      context,
      '/video_call',
      arguments: {
        'channelName': channelName,
        'doctorName': doctorName,
        'isVideoCall': isVideoCall,
      },
    );

    onCallStarted?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!showVideoCall && !showVoiceCall) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (showVideoCall) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startCall(context, true),
              icon: const Icon(Icons.videocam, size: 18),
              label: const Text('Video Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (showVoiceCall) const SizedBox(width: 8),
        ],
        if (showVoiceCall) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startCall(context, false),
              icon: const Icon(Icons.call, size: 18),
              label: const Text('Voice Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
