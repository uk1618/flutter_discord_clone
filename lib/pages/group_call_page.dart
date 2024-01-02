import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../utils.dart';

class GroupCallPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String callId;
  const GroupCallPage({super.key, required this.userId, required this.userName, required this.callId});

  @override
  State<GroupCallPage> createState() => _GroupCallPageState();
}

class _GroupCallPageState extends State<GroupCallPage> {
  ZegoUIKitPrebuiltCallController? callController;

   @override
  void initState() {
    super.initState();

    callController = ZegoUIKitPrebuiltCallController();
  }

  @override
  void dispose() {
    super.dispose();

    callController = null;
  }

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: Utils()
          .group_call_appId, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign: Utils()
          .group_call_appSignIn, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: widget.userId,
      userName: widget.userName,
      callID: widget.callId,
      controller: callController,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config:  ZegoUIKitPrebuiltCallConfig.groupVideoCall()
    );
  }
}
