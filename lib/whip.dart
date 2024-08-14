import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc/const/bitrate.dart';
import 'package:web_rtc/const/local_contrainst.dart';
import 'package:web_rtc/const/offer_contrainst.dart';
import 'package:web_rtc/http_clinent.dart';
import 'package:web_rtc/server.dart';

class RtcWhip extends StatefulWidget {
  const RtcWhip({super.key});

  @override
  State<RtcWhip> createState() => _RtcWhipState();
}

class _RtcWhipState extends State<RtcWhip> {
  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  final _localRender = RTCVideoRenderer();
  final _serverCtrl = TextEditingController();

  Future<MediaStream> getUserMediaFromNavigator() async =>
      await navigator.mediaDevices.getUserMedia(LOCAL_MEDIA_CONTRIANST);

  void _addTrack() {
    _localStream?.getTracks().forEach((track) async {
      _peerConnection?.addTrack(track, _localStream!);
    });
  }

  void _settingBitrate() async {
    var senders = await _peerConnection?.getSenders();
    senders?.forEach((sender) {
      var senderParam = sender.parameters;
      senderParam.encodings?[0].maxBitrate = DEFAULT_BITRATE;
      senderParam.encodings?[0].minBitrate = DEFAULT_BITRATE;

      sender.setParameters(senderParam);
    });
  }

  void _createInitPeerConnection() async {
    _peerConnection = await createPeerConnection({});
    _localStream = await getUserMediaFromNavigator();
    _localRender.srcObject = _localStream;
    _addTrack();
    _settingBitrate();
    setState(() {});
  }

  void _connect(String url) async {
    // Tạo offer và gửi lên
    final desc = await _peerConnection?.createOffer(OFFER_MEDIA_CONTRIANS);
    await _peerConnection?.setLocalDescription(desc!);
    final response = await post(url, desc?.sdp ?? "");
    // Nhận answer và set remote descriptions
    final answer = RTCSessionDescription(response?.data, 'answer');
    try {
      await _peerConnection?.setRemoteDescription(answer);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Whip thanh cong")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Whip that bai")));
    }
  }

  @override
  void initState() {
    _serverCtrl.text = server;
    _localRender.initialize().then((val) {
      _createInitPeerConnection();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _serverCtrl,
            ),
            Expanded(
              child: RTCVideoView(
                _localRender,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _connect(_serverCtrl.text),
      ),
    );
  }
}
