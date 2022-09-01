import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String uid; //userID
  String name; //userName
  List<String> groups = []; //所属しているグループ
  List<String> histories = []; //検索履歴
  List<int> favorites = []; //お気に入り
  List<int> _expDatas = []; //作成したデータ

  List<int> get expDatas => _expDatas;

  AppUser({required this.uid, required this.name});

  //ユーザー情報をFirestoreに保存する
  Future<void> save() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'groups': groups,
      'histories': histories,
      'favorites': favorites,
      'expDatas': _expDatas,
    });
  }

  void setData(String uid, String name) {
    this.uid = uid;
    this.name = name;
    return;
  }

  //ユーザー情報をFirestoreから取得する
  static Future<AppUser?> getUser(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final appUser = AppUser(uid: doc['uid'], name: doc['name']);
      appUser.groups = doc['groups'];
      appUser.histories = doc['histories'];
      appUser.favorites = doc['favorites'];
      appUser._expDatas = doc['expDatas'];
      return appUser;
    } else {
      return null;
    }
  }
}
