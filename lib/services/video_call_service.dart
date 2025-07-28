import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class VideoCallService {
  static const String appId =
      '936e24e035914aaeb245627690805d7c'; // Replace with your Agora App ID

  RtcEngine? _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _muted = false;
  bool _videoEnabled = true;

  // Getters
  bool get localUserJoined => _localUserJoined;
  int? get remoteUid => _remoteUid;
  bool get muted => _muted;
  bool get videoEnabled => _videoEnabled;
  RtcEngine? get engine => _engine;

  // Callbacks
  Function(int uid, int elapsed)? onUserJoined;
  Function(int uid, UserOfflineReasonType reason)? onUserOffline;
  Function()? onJoinChannelSuccess;
  Function(ErrorCodeType err)? onError;

  Future<void> initialize() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RTC engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // Register event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _localUserJoined = true;
          onJoinChannelSuccess?.call();
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          _remoteUid = uid;
          onUserJoined?.call(uid, elapsed);
        },
        onUserOffline: (
          RtcConnection connection,
          int uid,
          UserOfflineReasonType reason,
        ) {
          _remoteUid = null;
          onUserOffline?.call(uid, reason);
        },
        onError: (ErrorCodeType err, String msg) {
          onError?.call(err);
        },
      ),
    );

    // Enable video
    await _engine!.enableVideo();
    await _engine!.enableAudio();
    await _engine!.startPreview();
  }

  Future<void> joinChannel(String channelName, String token, int uid) async {
    await _engine?.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
    _localUserJoined = false;
    _remoteUid = null;
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    await _engine?.muteLocalAudioStream(_muted);
  }

  Future<void> toggleVideo() async {
    _videoEnabled = !_videoEnabled;
    await _engine?.muteLocalVideoStream(!_videoEnabled);
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}
