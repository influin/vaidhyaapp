import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/video_call_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String doctorName;
  final bool isVideoCall;
  
  const VideoCallScreen({
    Key? key,
    required this.channelName,
    required this.doctorName,
    this.isVideoCall = true,
  }) : super(key: key);
  
  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final VideoCallService _videoCallService = VideoCallService();
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _initializeCall();
  }
  
  Future<void> _initializeCall() async {
    try {
      // Set up callbacks
      _videoCallService.onJoinChannelSuccess = () {
        setState(() {
          _isLoading = false;
        });
      };
      
      _videoCallService.onUserJoined = (uid, elapsed) {
        setState(() {});
      };
      
      _videoCallService.onUserOffline = (uid, reason) {
        setState(() {});
      };
      
      _videoCallService.onError = (err) {
        setState(() {
          _errorMessage = 'Call error: $err';
          _isLoading = false;
        });
      };
      
      // Initialize and join channel
      await _videoCallService.initialize();
      
      // Generate a simple token (in production, get this from your backend)
      const String token = ''; // Leave empty for testing, use temp token from Agora console
      const int uid = 0; // Use 0 to let Agora assign UID
      
      await _videoCallService.joinChannel(widget.channelName, token, uid);
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize call: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _videoCallService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Call with ${widget.doctorName}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Connecting...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Remote video (full screen)
                    if (widget.isVideoCall && _videoCallService.remoteUid != null)
                      Positioned.fill(
                        child: AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _videoCallService.engine!,
                            canvas: VideoCanvas(uid: _videoCallService.remoteUid),
                            connection: RtcConnection(channelId: widget.channelName),
                          ),
                        ),
                      ),
                    
                    // Local video (small window)
                    if (widget.isVideoCall && _videoCallService.localUserJoined)
                      Positioned(
                        top: 50,
                        right: 20,
                        width: 120,
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _videoCallService.engine!,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ),
                        ),
                      ),
                    
                    // Audio call UI
                    if (!widget.isVideoCall)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, size: 80, color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.doctorName,
                              style: const TextStyle(color: Colors.white, fontSize: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _videoCallService.remoteUid != null ? 'Connected' : 'Calling...',
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    
                    // Control buttons
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Mute button
                          FloatingActionButton(
                            onPressed: () {
                              _videoCallService.toggleMute();
                              setState(() {});
                            },
                            backgroundColor: _videoCallService.muted ? Colors.red : Colors.grey,
                            child: Icon(
                              _videoCallService.muted ? Icons.mic_off : Icons.mic,
                              color: Colors.white,
                            ),
                          ),
                          
                          // End call button
                          FloatingActionButton(
                            onPressed: () {
                              _videoCallService.leaveChannel();
                              Navigator.pop(context);
                            },
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.call_end, color: Colors.white),
                          ),
                          
                          // Video toggle button (only for video calls)
                          if (widget.isVideoCall)
                            FloatingActionButton(
                              onPressed: () {
                                _videoCallService.toggleVideo();
                                setState(() {});
                              },
                              backgroundColor: _videoCallService.videoEnabled ? Colors.grey : Colors.red,
                              child: Icon(
                                _videoCallService.videoEnabled ? Icons.videocam : Icons.videocam_off,
                                color: Colors.white,
                              ),
                            ),
                          
                          // Switch camera button (only for video calls)
                          if (widget.isVideoCall)
                            FloatingActionButton(
                              onPressed: () => _videoCallService.switchCamera(),
                              backgroundColor: Colors.grey,
                              child: const Icon(Icons.switch_camera, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}