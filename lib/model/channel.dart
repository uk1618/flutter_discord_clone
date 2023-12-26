
class Channel {
  final String channelName;
  final String channelDesc;
  final String channelType;

  Channel({required this.channelName, required this.channelDesc, required this.channelType});


  //* convert to a map
  Map<String, dynamic> toMap() {
    return {
      'channelName': channelName,
      'channelDesc': channelDesc,
      'channelType': channelType,
    };
  }
}
