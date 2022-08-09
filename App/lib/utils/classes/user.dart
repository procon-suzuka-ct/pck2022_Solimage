import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String uid; //userID
  String name; //userName
  List<String> groups = []; //所属しているグループ
  List<String> histories = []; //検索履歴
  List<String> favorites = []; //お気に入り

  AppUser({required this.uid, required this.name});

  //ユーザー情報をFirestoreに保存する
  Future<void> save() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'groups': groups,
      'histories': histories,
    });
  }

  //ユーザー情報をFirestoreから取得する
  Future<void> getUser(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      uid = doc["uid"];
      name = doc["name"];
      groups = doc["groups"];
      histories = doc["histories"];
    } else {
      return;
    }
  }

  void setData(String uid, String name) {
    this.uid = uid;
    this.name = name;
    return;
  }
}
