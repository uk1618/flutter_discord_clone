import 'package:cloud_firestore/cloud_firestore.dart';

class Server {
  final String creator;
  final String serverName;
  final String serverDesc;
  final String serverType;
  final Timestamp timestamp;

  Server(
      {required this.creator,
      required this.serverName,
      required this.serverDesc,
      required this.serverType,
      required this.timestamp
      });

  //* convert to a map
  Map<String, dynamic> toMap() {
    return {
      'creator': creator,
      'serverName': serverName,
      'serverDesc': serverDesc,
      'serverType': serverType,
      'timestamp': timestamp,
    };
  }
}
