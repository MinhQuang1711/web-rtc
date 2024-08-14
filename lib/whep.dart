import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc/const/offer_contrainst.dart';
import 'package:web_rtc/server.dart';
import 'http_clinent.dart';

class RTCWhep extends StatefulWidget {
  const RTCWhep({super.key});

  @override
  State<RTCWhep> createState() => _RTCWhepState();
}

class _RTCWhepState extends State<RTCWhep> {
  RTCPeerConnection? _peerConnection;
  final _remoteRender = RTCVideoRenderer();
  final _serverCtrl = TextEditingController();

  @override
  void initState() {
    _serverCtrl.text = whepServer;
    _remoteRender.initialize().then((val) {
      _createInitPeerConnection();
    });
    super.initState();
  }

  void _createInitPeerConnection() async {
    _peerConnection = await createPeerConnection({});
    _peerConnection?.onTrack = (event) {
      _remoteRender.srcObject = event.streams[0];
    };
    setState(() {});
  }

  void connect(String url) async {
    // Tạo và gửi offer
    final desc = await _peerConnection?.createOffer(OFFER_MEDIA_CONTRIANS);
    await _peerConnection?.setLocalDescription(desc!);
    final response = await post(url, desc?.sdp ?? "");
    // Nhận answer và set remote description
    final answer = RTCSessionDescription(response?.data, 'answer');
    await _peerConnection?.setRemoteDescription(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            TextFormField(
              controller: _serverCtrl,
            ),
            Expanded(
              child: RTCVideoView(
                _remoteRender,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => connect(_serverCtrl.text),
      ),
    );
  }
}
