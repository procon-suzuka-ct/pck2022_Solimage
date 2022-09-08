import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:solimage/utils/auth.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

class ExpData {
  late final int _dataId;
  late final String _userId;
  int? rootId;
  List<int> childIds = [];

  late String _word;
  late String _meaning;

  //5W1H
  String? _why;
  String? _what;
  String? _where;
  String? _when;
  String? _who;
  String? _how;

  String? _imageUrl;

  int get dataId => _dataId;
  String get userId => _userId;
  String? get word => _word;
  String? get meaning => _meaning;
  String? get why => _why;
  String? get what => _what;
  String? get where => _where;
  String? get when => _when;
  String? get who => _who;
  String? get how => _how;
  String? get imageUrl => _imageUrl;

  ExpData(
      {required String word,
      required String meaning,
      this.rootId,
      String? userID}) {
    _word = word;
    _meaning = meaning;
    rootId ??= 0;
    _dataId = 0;
    _userId = userID ?? "None";
  }

  ExpData.fromJson(Map<String, Object?> json): _dataId = json['dataId'] as int,
    _userId = json['userId'] as String,
    rootId = json['rootId'] as int?,
    childIds = (json['childIds'] as List<dynamic>).cast<int>(),
    _word = json['word'] as String,
    _meaning = json['meaning'] as String,
    _why = json['why'] as String?,
    _what = json['what'] as String?,
    _where = json['where'] as String?,
    _when = json['when'] as String?,
    _who = json['who'] as String?,
    _how = json['how'] as String?,
    _imageUrl = json['imageUrl'] as String?;

  Map<String, Object?> toJson(){
    return {
      "dataId": _dataId,
      'userId': _userId,
      'rootId': rootId,
      'childIds': childIds,
      'word': _word,
      'meaning': _meaning,
      'why': _why,
      'what': _what,
      'where': _where,
      'when': _when,
      'who': _who,
      'how': _how,
      'imageUrl': _imageUrl,
    };
  }

  void init() async {
    await generateId().then((value) => _dataId = value);
    return;
  }

  void setData(
      {String? word,
      String? meaning,
      String? why,
      String? what,
      String? where,
      String? when,
      String? who,
      String? how,
      String? imageUrl}) {
    if (Auth().currentUser()!.uid != _userId) {
      throw Exception('userId is not match');
    }
    _word = word ?? _word;
    _meaning = meaning ?? _meaning;
    _why = why ?? _why;
    _what = what ?? _what;
    _where = where ?? _where;
    _when = when ?? _when;
    _who = who ?? _who;
    _how = how ?? _how;
    _imageUrl = imageUrl ?? _imageUrl;
    return;
  }

  Future<int> generateId() async {
    final docs =
        (await FirebaseFirestore.instance.collection('expData').get()).docs;
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

  //Firestoreに保存する
  Future<void> save() async {
    if (Auth().currentUser()!.uid != _userId) {
      throw Exception('userId is not match');
    }
    if (_dataId == 0) {
      throw Exception("dataId is not set");
    }

    AppUser.getUser(_userId).then((value) {
      if (value != null) {
        value.addExpData(_dataId);
        for (var groupId in value.groups) {
          Group.getGroup(groupId).then((group) {
            if (group != null) {
              group.addExpData(_dataId);
            }
          });
        }
      }
    });

    FirebaseFirestore.instance.collection('expDataIndex').doc(_word).update({
      "index": FieldValue.arrayUnion([_dataId])
    });

    await FirebaseFirestore.instance
        .collection('expData')
        .doc(_dataId.toString())
        .set({
      "dataId": _dataId,
      'userId': _userId,
      'word': _word,
      'meaning': _meaning,
      'why': _why,
      'what': _what,
      'where': _where,
      'when': _when,
      'who': _who,
      'how': _how,
      'imageUrl': _imageUrl,
      'childIds': childIds,
      'rootId': rootId,
    });
    return;
  }

  //Firestoreから取得する
  static Future<ExpData?> getExpData(int dataId) async {
    final userRef = FirebaseFirestore.instance.collection('expData').doc(dataId.toString()).withConverter<ExpData>(
      fromFirestore: (snapshot, _) => ExpData.fromJson(snapshot.data()!),
      toFirestore: (expData, _) => expData.toJson(),
    );
    final doc = await userRef.get();
    return doc.data();
  }

  /// keywordからデータを取得する関数です
  ///
  /// 返ってくる[ExpData]オブジェクトは複数あるデータからランダムで抽出され構成されます
  ///
  /// [onlyGroup]をtrueにすると、所属しているグループのみを対象にします
  static Future<ExpData?> getExpDataByWord(
      {required String word, bool onlyGroup = false}) async {
    final doc = await FirebaseFirestore.instance
        .collection('expDataIndex')
        .doc(word)
        .get();

    if (doc.exists) {
      List<Future<ExpData?>> expDataList = [];
      for (final dataId in doc['index']) {
        expDataList.add(getExpData(dataId));
      }
      final expDataListResult = await Future.wait(expDataList);
      List<String> meanings = [];
      List<String> whyList = [];
      List<String> whatList = [];
      List<String> whereList = [];
      List<String> whenList = [];
      List<String> whoList = [];
      List<String> howList = [];
      List<String> imageUrls = [];

      List<Group> groups = [];
      List<int> expDataIDs = [];
      if (onlyGroup) {
        final user = await AppUser.getUser(Auth().currentUser()!.uid);
        if (user == null) {
          return null;
        }
        final groupIDs = user.groups;
        for (final groupId in groupIDs) {
          final group = await Group.getGroup(groupId);
          if (group != null) {
            groups.add(group);
          }
        }
        for (final group in groups) {
          for (final wordId in group.expDatas) {
            expDataIDs.add(wordId);
          }
        }
      }

      for (final expData in expDataListResult) {
        if (expData != null &&
            (!onlyGroup ||
                expDataIDs.contains(expData.dataId) ||
                (expData.dataId >= 0 && expData.dataId < 1000000000))) {
          meanings.add(expData.meaning!);
          whyList.add(expData.why!);
          whatList.add(expData.what!);
          whereList.add(expData.where!);
          whenList.add(expData.when!);
          whoList.add(expData.who!);
          howList.add(expData.how!);
          imageUrls.add(expData.imageUrl!);
        }
      }

      final random = Random();
      final meaning = random.nextInt(meanings.length);
      final why = whyList.isNotEmpty ? random.nextInt(whyList.length) : null;
      final what = whatList.isNotEmpty ? random.nextInt(whatList.length) : null;
      final where =
          whereList.isNotEmpty ? random.nextInt(whereList.length) : null;
      final when = whenList.isNotEmpty ? random.nextInt(whenList.length) : null;
      final who = whoList.isNotEmpty ? random.nextInt(whoList.length) : null;
      final how = howList.isNotEmpty ? random.nextInt(howList.length) : null;
      final imageUrl =
          imageUrls.isNotEmpty ? random.nextInt(imageUrls.length) : null;

      ExpData data = ExpData(
        word: word,
        meaning: meanings[meaning],
      );
      data.setData(
        why: why != null ? whyList[why] : null,
        what: what != null ? whatList[what] : null,
        where: where != null ? whereList[where] : null,
        when: when != null ? whenList[when] : null,
        who: who != null ? whoList[who] : null,
        how: how != null ? howList[how] : null,
        imageUrl: imageUrl != null ? imageUrls[imageUrl] : null,
      );
      return data;
    }
    return null;
  }

  // Firestoreからデータを削除
  Future<void> delete() async {
    if (Auth().currentUser()!.uid != _userId) {
      throw Exception('userId is not match');
    }
    if (_dataId == 0) {
      throw Exception("dataId is not set");
    }

    AppUser.getUser(_userId).then((value) {
      if (value != null) {
        value.removeExpData(_dataId);
        for (var groupId in value.groups) {
          Group.getGroup(groupId).then((group) {
            if (group != null) {
              group.removeExpData(_dataId);
            }
          });
        }
      }
    });

    FirebaseFirestore.instance.collection('expDataIndex').doc(_word).update({
      "index": FieldValue.arrayRemove([_dataId])
    });

    await FirebaseFirestore.instance
        .collection('expData')
        .doc(_dataId.toString())
        .delete();
    return;
  }
}
