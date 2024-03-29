import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  int groupID = 0;
  String groupName;
  List<String> members = [];
  List<int> _expDatas = [];
  late String _adminId;

  String get adminId => _adminId;
  List<int> get expDatas => _expDatas;

  Group({required this.groupName, required String adminId}) {
    _adminId = adminId;
  }

  Future<void> init() async {
    await generateId().then((value) => groupID = value);
  }

  Group.fromJson(Map<String, Object?> json)
      : groupID = json['groupID'] as int,
        groupName = json['groupName'] as String,
        members = (json['members'] as List<dynamic>).cast<String>(),
        _expDatas = (json['expDatas'] as List<dynamic>).cast<int>(),
        _adminId = json['adminId'] as String;

  Map<String, Object?> toJson() {
    return {
      'groupID': groupID,
      'groupName': groupName,
      'members': members,
      'expDatas': _expDatas,
      'adminId': _adminId,
    };
  }

  Future<int> generateId() async {
    final docs =
        (await FirebaseFirestore.instance.collection('group').get()).docs;
    List<String> ids = [];
    for (final doc in docs) {
      ids.add(doc.id);
    }
    int num = 0;
    bool isExist = true;
    while (isExist) {
      const max = 999999999;
      const min = 100000000;
      num = Random().nextInt(max - min) + min;
      final numString = num.toString();
      isExist = ids.contains(numString);
    }
    return num;
  }

  Future<void> save() {
    return FirebaseFirestore.instance
        .collection('group')
        .doc(groupID.toString())
        .set(toJson());
  }

  static Future<Group?> getGroup(int groupID) async {
    final userRef = FirebaseFirestore.instance
        .collection('group')
        .doc(groupID.toString())
        .withConverter<Group>(
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

  static Future<List<Group>> getGroups(String uid) async {
    final ref =
        FirebaseFirestore.instance.collection("group").withConverter<Group>(
              fromFirestore: (snapshot, _) => Group.fromJson(snapshot.data()!),
              toFirestore: (group, _) => group.toJson(),
            );
    final doc = await ref.get();
    final datas = doc.docs;
    List<Group> groups = [];
    for (var data in datas) {
      final group = data.data();
      group.members.contains(uid) ? groups.add(group) : null;
    }
    return groups;
  }

  Stream<DocumentSnapshot> listner() {
    return FirebaseFirestore.instance
        .collection('group')
        .doc(groupID.toString())
        .snapshots();
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

  Future<void> kickMember(String kickUserId, String uid) async {
    if (uid == _adminId) {
      members.remove(kickUserId);
      await save();
    }
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
