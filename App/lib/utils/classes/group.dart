import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Group {
  late int groupID;
  String groupName;
  List<String> members = [];
  List<int> _expDatas = [];

  List<int> get expDatas => _expDatas;

  Group({required this.groupName}) {
    generateId().then((value) => groupID = value);
  }

  Group.fromJson(Map<String, Object?> json)
      : groupID = json['groupID'] as int,
        groupName = json['groupName'] as String,
        members = json['members'] as List<String>,
        _expDatas = json['expDatas'] as List<int>;

  Map<String, Object?> toJson(){
    return {
      'groupID': groupID,
      'groupName': groupName,
      'members': members,
      'expDatas': _expDatas,
    };
  }

  Future<int> generateId() async {
    final docs =
        (await FirebaseFirestore.instance.collection('group').get()).docs;
    List<String> ids = [];
    for (final doc in docs) {
      ids.add(doc.id);
    }
    while (true) {
      const max = 9999999999;
      const min = 1000000000;
      final num = Random().nextInt(max - min) + min;
      final numString = num.toString();
      bool isExist = false;
      for (final id in ids) {
        if (id == numString) {
          isExist = true;
          break;
        }
      }
      if (!isExist) {
        return num;
      }
    }
  }

  Future<void> save() async {
    await FirebaseFirestore.instance
        .collection('group')
        .doc(groupID.toString())
        .set({
      'groupID': groupID,
      'groupName': groupName,
      'members': members,
      'expDatas': _expDatas,
    });
  }

  static Future<Group?> getGroup(int groupID) async {
    final userRef = FirebaseFirestore.instance.collection('group').doc(groupID.toString()).withConverter<Group>(
      fromFirestore: (snapshot, _) => Group.fromJson(snapshot.data()!),
      toFirestore: (group, _) => group.toJson(),
    );
    final doc = await userRef.get();
    if (doc.exists) {
      return doc.data();
    } else {
      return null;
    }
  }

  void setData(String groupName) {
    this.groupName = groupName;
    return;
  }

  void addMember(String uid) {
    members.add(uid);
    return;
  }

  void removeMember(String uid) {
    members.remove(uid);
    return;
  }

  void addExpData(int expDataID) {
    if (_expDatas.contains(expDataID)) {
      return;
    } else {
      _expDatas.add(expDataID);
    }
    return;
  }

  void removeExpData(int expDataID) {
    if (_expDatas.contains(expDataID)) {
      _expDatas.remove(expDataID);
    }
    return;
  }

  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('group')
        .doc(groupID.toString())
        .update({
      'groupName': groupName,
      'members': members,
      'expDatas': _expDatas,
    });
  }

  Future<int> delete() async {
    await FirebaseFirestore.instance
        .collection('group')
        .doc(groupID.toString())
        .delete();
    return groupID;
  }
}
