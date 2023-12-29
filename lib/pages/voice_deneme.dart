// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/utils.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

// Project imports:
import '../constants/layout_mode.dart';

class LivePage extends StatelessWidget {
  final String roomID;
  final String userID;
  final String userName;
  final bool isHost;
  final LayoutMode layoutMode;

  const LivePage({
    Key? key,
    required this.roomID,
    required this.userID,
    required this.userName,
    this.layoutMode = LayoutMode.defaultLayout,
    required this.isHost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveAudioRoom(
          appID: Utils().appId /*input your AppID*/,
          appSign: Utils().appSignIn /*input your AppSign*/,
          userID: localUserID,
          userName: 'user_$localUserID',
          roomID: roomID,
          config: (isHost
              ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
              : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience())
            ..takeSeatIndexWhenJoining = isHost ? getHostSeatIndex() : -1
            ..hostSeatIndexes = getLockSeatIndex()
            ..layoutConfig = getLayoutConfig()
            ..seatConfig = getSeatConfig()
            ..background = background()
            ..inRoomMessageConfig = getMessageViewConfig()
            // ..userAvatarUrl = 'your_avatar_url'
            ..onUserCountOrPropertyChanged = (List<ZegoUIKitUser> users) {
              debugPrint(
                  'onUserCountOrPropertyChanged:${users.map((e) => e.toString())}');
            }
            ..onSeatClosed = () {
              debugPrint('on seat closed');
            }
            ..onSeatsOpened = () {
              debugPrint('on seat opened');
            }
            ..onSeatsChanged = (
              Map<int, ZegoUIKitUser> takenSeats,
              List<int> untakenSeats,
            ) {
              debugPrint(
                  'on seats changed, taken seats:$takenSeats, untaken seats:$untakenSeats');
            }
            ..onSeatTakingRequested = (ZegoUIKitUser audience) {
              debugPrint(
                  'on seat taking requested, audience:${audience.toString()}');
            }
            ..onSeatTakingRequestCanceled = (ZegoUIKitUser audience) {
              debugPrint(
                  'on seat taking request canceled, audience:${audience.toString()}');
            }
            ..onInviteAudienceToTakeSeatFailed = () {
              debugPrint('on invite audience to take seat failed');
            }
            ..onSeatTakingInviteRejected = () {
              debugPrint('on seat taking invite rejected');
            }
            ..onSeatTakingRequestFailed = () {
              debugPrint('on seat taking request failed');
            }
            ..onSeatTakingRequestRejected = () {
              debugPrint('on seat taking request rejected');
            }
            ..onHostSeatTakingInviteSent = () {
              debugPrint('on host seat taking invite sent');
            }

          /// WARNING: will override prebuilt logic
          // ..onSeatClicked = (int index, ZegoUIKitUser? user) {
          //   debugPrint(
          //       'on seat clicked, index:$index, user:${user.toString()}');
          //
          //   showDemoBottomSheet(context);
          // }

          /// WARNING: will override prebuilt logic
          // ..onMemberListMoreButtonPressed = (ZegoUIKitUser user) {
          //   debugPrint(
          //       'on member list more button pressed, user:${user.toString()}');
          //
          //   showDemoBottomSheet(context);
          // },
          ),
    );
  }

  Widget background() {
    /// how to replace background view
    return Stack(
      children: [
        Container(
          color: CustomColors().dcGrey,
        ),
        const Positioned(
            top: 10,
            left: 10,
            child: Text(
              'Live Audio Room',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xff1B1B1B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            )),
        Positioned(
          top: 10 + 20,
          left: 10,
          child: Text(
            'ID: $roomID',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff606060),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }

  ZegoLiveAudioRoomSeatConfig getSeatConfig() {
    if (layoutMode == LayoutMode.hostTopCenter) {
      return ZegoLiveAudioRoomSeatConfig(
        backgroundBuilder: (
          BuildContext context,
          Size size,
          ZegoUIKitUser? user,
          Map<String, dynamic> extraInfo,
        ) {
          return Container(color: Colors.grey);
        },
      );
    }

    return ZegoLiveAudioRoomSeatConfig(
      avatarBuilder: avatarBuilder,
    );
  }

  ZegoInRoomMessageConfig getMessageViewConfig() {
    return ZegoInRoomMessageConfig(itemBuilder: (
      BuildContext context,
      ZegoInRoomMessage message,
      Map<String, dynamic> extraInfo,
    ) {
      /// how to use itemBuilder to custom message view
      return Stack(
        children: [
          ZegoInRoomMessageViewItem(message: message),

          /// add a red point
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              width: 10,
              height: 10,
            ),
          ),
        ],
      );
    });
  }

  Widget avatarBuilder(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    return CircleAvatar(
      maxRadius: size.width,
      backgroundImage: Image.asset(
              "assets/avatars/avatar_${((int.tryParse(user?.id ?? "") ?? 0) % 6).toString()}.png")
          .image,
    );
  }

  int getHostSeatIndex() {
    if (layoutMode == LayoutMode.hostCenter) {
      return 4;
    }

    return 0;
  }

  List<int> getLockSeatIndex() {
    if (layoutMode == LayoutMode.hostCenter) {
      return [4];
    }

    return [0];
  }

  ZegoLiveAudioRoomLayoutConfig getLayoutConfig() {
    final config = ZegoLiveAudioRoomLayoutConfig();
    switch (layoutMode) {
      case LayoutMode.defaultLayout:
        break;
      case LayoutMode.full:
        config.rowSpacing = 5;
        config.rowConfigs = [
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 4,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 4,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 4,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 4,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
        ];
        break;
      case LayoutMode.hostTopCenter:
        config.rowConfigs = [
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 1,
            alignment: ZegoLiveAudioRoomLayoutAlignment.center,
          ),
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 3,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 3,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 2,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceEvenly,
          ),
        ];
        break;
      case LayoutMode.hostCenter:
        config.rowSpacing = 5;
        config.rowConfigs = [
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 3,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 3,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 3,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
        ];
        break;
      case LayoutMode.fourPeoples:
        config.rowConfigs = [
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 4,
            alignment: ZegoLiveAudioRoomLayoutAlignment.spaceBetween,
          ),
        ];
        break;
    }
    return config;
  }

  void showDemoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xff111014),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      isDismissible: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      'Menu $index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
