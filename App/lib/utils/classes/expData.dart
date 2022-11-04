import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:solimage/utils/auth.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

class ExpData {
  late int _dataId;
  late String _userId;
  String? rootWord;
  List<int> childIds = [];

  int _views = 0;

  late String _word;
  late String _meaning;

  List<int> _goodUsers = [];
  List<int> _badUsers = [];

  //5W1H
  String? _why;
  String? _what;
  String? _where;
  String? _when;
  String? _who;
  String? _how;

  String? _imageUrl;

  int get views => _views;
  int get dataId => _dataId;
  String get userId => _userId;
  String get word => _word;
  String get meaning => _meaning;
  String? get why => _why;
  String? get what => _what;
  String? get where => _where;
  String? get when => _when;
  String? get who => _who;
  String? get how => _how;
  String? get imageUrl => _imageUrl;
  int get goodNum => _goodUsers.length;
  int get badNum => _badUsers.length;

  ExpData(
      {required String word,
      required String meaning,
      this.rootWord,
      String? userID}) {
    _word = word;
    _meaning = meaning;
    rootWord ??= "0";
    _dataId = -1;
    _userId = userID ?? "None";
  }

  ExpData.fromJson(Map<String, Object?> json)
      : _views = (json['views'] ?? 0) as int,
        _dataId = json['dataId'] as int,
        _userId = json['userId'] as String,
        rootWord = (json['rootWord'] ?? json['rootId']).toString(),
        childIds = ((json['childIds'] ?? []) as List<dynamic>).cast<int>(),
        _word = json['word'] as String,
        _meaning = json['meaning'] as String,
        _why = json['why'] as String?,
        _what = json['what'] as String?,
        _where = json['where'] as String?,
        _when = json['when'] as String?,
        _who = json['who'] as String?,
        _how = json['how'] as String?,
        _imageUrl = json['imageURL'] as String?,
        _goodUsers = ((json['goodUsers'] ?? []) as List<dynamic>).cast<int>(),
        _badUsers = ((json['badUsers'] ?? []) as List<dynamic>).cast<int>();

  Map<String, Object?> toJson() {
    return {
      "views": _views,
      "dataId": _dataId,
      'userId': _userId,
      'rootWord': rootWord,
      'childIds': childIds,
      'word': _word,
      'meaning': _meaning,
      'why': _why,
      'what': _what,
      'where': _where,
      'when': _when,
      'who': _who,
      'how': _how,
      'imageURL': _imageUrl,
      'goodUsers': _goodUsers,
      'badUsers': _badUsers
    };
  }

  static DocumentReference<ExpData> _getRef(String id) {
    return FirebaseFirestore.instance
        .collection('expData')
        .doc(id)
        .withConverter<ExpData>(
          fromFirestore: ((snapshot, _) => ExpData.fromJson(snapshot.data()!)),
          toFirestore: ((data, __) => data.toJson()),
        );
  }

  Future<int> init() async {
    return await generateId().then((value) => _dataId = value);
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
      const max = 999999999;
      const min = 100000000;
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

    await AppUser.getUser(_userId).then((value) async {
      if (value != null) {
        value.addExpData(_dataId);
        await value.save();
        for (var groupId in value.groups) {
          await Group.getGroup(groupId).then((group) async {
            if (group != null) {
              group.addExpData(_dataId);
              await group.save();
            }
          });
        }
      }
    });

    // expDataIndexの更新

    // ID
    final docRef =
        FirebaseFirestore.instance.collection("expDataIndex").doc(_word);

    await docRef.get().then((value) {
      if (value.exists) {
        final data = value.data()!;
        final list = ((data['dataIds'] ?? []) as List<dynamic>).cast<int>();
        list.contains(_dataId)
            ? null
            : docRef.update({
                "index": FieldValue.arrayUnion([_dataId]),
              });
      } else {
        docRef.set({
          "index": [_dataId],
        });
      }
    });

    // rootWord
    final rootRef =
        FirebaseFirestore.instance.collection("expDataIndex").doc(rootWord);
    await rootRef.get().then((value) {
      if (value.exists) {
        final data = value.data()!;
        final list =
            ((data["childWord"] ?? []) as List<dynamic>).cast<String>();
        list.contains(_word)
            ? null
            : rootRef.update({
                "childWord": FieldValue.arrayUnion([_word]),
              });
      }
    });

    await _getRef(_dataId.toString()).set(this);
    return;
  }

  //Firestoreから取得する
  static Future<ExpData?> getExpData(int dataId) async {
    final doc = await _getRef(dataId.toString()).get();
    return doc.data();
  }

  static Future<List<ExpData?>> getChilds({required String word}) async {
    final childs = (await FirebaseFirestore.instance
            .collection("words")
            .where("root", isEqualTo: word)
            .get())
        .docs;
    List<ExpData?> list = [];
    for (final child in childs) {
      final data = child.data();
      final word = data["word"];
      final expData = await getExpDataByWord(word: word);
      list.add(expData);
    }
    return list;
  }

  static Future<List<ExpData>> _getExpDatas() async {
    final ref = FirebaseFirestore.instance
        .collection("expData")
        .withConverter<ExpData>(
            fromFirestore: (snapshot, _) => ExpData.fromJson(snapshot.data()!),
            toFirestore: (expData, _) => expData.toJson());
    final doc = await ref.get();
    final datas = doc.docs;
    List<ExpData> expDatas = [];
    for (var data in datas) {
      final expData = data.data();
      expDatas.add(expData);
    }

    return expDatas;
  }

  /// keywordからデータを取得する関数です
  ///
  /// 返ってくる[ExpData]オブジェクトは複数あるデータからランダムで抽出され構成されます
  static Future<ExpData?> getExpDataByWord({required String word}) async {
    final doc = await FirebaseFirestore.instance
        .collection('expDataIndex')
        .doc(word)
        .get();
    if (!doc.exists) {
      return null;
    }
    final indexData = doc.data()!;
    final indexList = ((indexData["index"] ?? []) as List<dynamic>).cast<int>();
    List<ExpData> expDataList = [];
    for (final data in await _getExpDatas()) {
      indexList.contains(data._dataId) ? expDataList.add(data) : null;
    }

    List<ExpData> meanings = [];
    List<ExpData> whyList = [];
    List<ExpData> whatList = [];
    List<ExpData> whereList = [];
    List<ExpData> whenList = [];
    List<ExpData> whoList = [];
    List<ExpData> howList = [];
    List<ExpData> imageUrls = [];

    List<Group> groups = [];
    List<int> expDataIDs = [];
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

    for (final expData in expDataList) {
      if (expDataIDs.contains(expData.dataId) && expData.dataId >= 100000000) {
        meanings.add(expData);
        if (expData.why != null) whyList.add(expData);
        if (expData.what != null) whatList.add(expData);
        if (expData.where != null) whereList.add(expData);
        if (expData.when != null) whenList.add(expData);
        if (expData.who != null) whoList.add(expData);
        if (expData.how != null) howList.add(expData);
        if (expData.imageUrl != null) imageUrls.add(expData);
      }
    }

    for (final expData in expDataList) {
      if (expData.dataId >= 100000000) {
        continue;
      }
      meanings.isEmpty ? meanings.add(expData) : null;
      (whyList.isEmpty && expData.why != null) ? whyList.add(expData) : null;
      (whatList.isEmpty && expData.what != null) ? whatList.add(expData) : null;
      (whereList.isEmpty && expData.where != null)
          ? whereList.add(expData)
          : null;
      (whenList.isEmpty && expData.when != null) ? whenList.add(expData) : null;
      (whoList.isEmpty && expData.who != null) ? whoList.add(expData) : null;
      (howList.isEmpty && expData.how != null) ? howList.add(expData) : null;
      (imageUrls.isEmpty && expData.imageUrl != null)
          ? imageUrls.add(expData)
          : null;
    }

    if (meanings.isEmpty) {
      return null;
    }

    final random = Random();
    final meaning = meanings[random.nextInt(meanings.length)];
    final why =
        whyList.isNotEmpty ? whyList[random.nextInt(whyList.length)] : null;
    final what =
        whatList.isNotEmpty ? whatList[random.nextInt(whatList.length)] : null;
    final where = whereList.isNotEmpty
        ? whereList[random.nextInt(whereList.length)]
        : null;
    final when =
        whenList.isNotEmpty ? whenList[random.nextInt(whenList.length)] : null;
    final who =
        whoList.isNotEmpty ? whoList[random.nextInt(whoList.length)] : null;
    final how =
        howList.isNotEmpty ? howList[random.nextInt(howList.length)] : null;
    final imageUrl = imageUrls.isNotEmpty
        ? imageUrls[random.nextInt(imageUrls.length)]
        : null;

    meaning.addViews();
    why?.addViews();
    what?.addViews();
    where?.addViews();
    when?.addViews();
    who?.addViews();
    how?.addViews();
    imageUrl?.addViews();

    final value = ExpData(
      word: meaning.word,
      meaning: meaning.meaning,
    );
    value.setData(
        why: why?.why,
        what: what?.what,
        when: when?.when,
        where: where?.where,
        who: who?.who,
        how: how?.how,
        imageUrl: imageUrl?.imageUrl);
    return value;
  }

  Future<void> addViews() async {
    var ref = _getRef(_dataId.toString());
    await ref.update({'views': FieldValue.increment(1)});
  }

  Future<void> resetViews() async {
    var ref = _getRef(_dataId.toString());
    await ref.update({'views': 0});
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

    await _getRef(dataId.toString()).delete();
    return;
  }

  /// 高評価ボタン押下時の処理
  /// uidを引数に入れてください
  ///
  /// Userのデータもこの関数で更新されます
  Future<void> good(String uid) async {
    if (_dataId < 0) {
      return;
    }
    final user = await AppUser.getUser(uid);
    if (user == null) {
      return;
    }
    final isGood = user.goodDatas.contains(_word);
    if (isGood == true) {
      await user.removeGoodData(_word);
    } else if (isGood == false) {
      await user.addGoodData(_word);
    }
  }

  /// 返り値は画像のダウンロードURLです
  ///
  /// 画像の保存に成功した場合は、[ExpData]の[imageUrl]にも保存されます
  ///
  /// [isExpDataSave]がtrueの場合、[ExpData]のsave関数も呼ばれます
  Future<String> saveImage(
      {required String imagePath, bool isExpDataSave = false}) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('images').child("$_dataId.jpg");
    File file = File(imagePath);
    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();
    _imageUrl = url;
    if (isExpDataSave) {
      await save();
    }
    return url;
  }

  ExpData copy() {
    final value = ExpData(
      word: _word,
      meaning: _meaning,
    );
    value.setData(
        why: _why,
        what: _what,
        when: _when,
        where: _where,
        who: _who,
        how: _how,
        imageUrl: _imageUrl);
    value._dataId = _dataId;
    return value;
  }
}

class RecommendData extends ExpData {
  RecommendData({
    required String word,
    required String meaning,
    required String userID,
  }) : super(
          word: word,
          meaning: meaning,
          userID: userID,
        );

  static RecommendData? recommendData;
  static String? currentUid = Auth().currentUser()?.uid;

  @override
  RecommendData copy() {
    final value = RecommendData(
      word: _word,
      meaning: _meaning,
      userID: _userId,
    );
    value.setData(
        why: _why,
        what: _what,
        when: _when,
        where: _where,
        who: _who,
        how: _how,
        imageUrl: _imageUrl);
    value._dataId = _dataId;
    return value;
  }

  @override
  Future<int> init() async {
    _dataId = 0;
    return 0;
  }

  RecommendData.fromJson(Map<String, Object?> json)
      : super(
            meaning: json['meaning'] as String,
            word: json['word'] as String,
            userID: json['userId'] as String) {
    _userId = json['userId'] as String;
    _word = json['word'] as String;
    _meaning = json['meaning'] as String;
    _why = json['why'] as String?;
    _what = json['what'] as String?;
    _where = json['where'] as String?;
    _when = json['when'] as String?;
    _who = json['who'] as String?;
    _how = json['how'] as String?;
    _imageUrl = (json['imageURL'] ?? json["imageUrl"]) as String?;
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'userId': _userId,
      'word': _word,
      'meaning': _meaning,
      'why': _why,
      'what': _what,
      'where': _where,
      'when': _when,
      'who': _who,
      'how': _how,
      'imageURL': _imageUrl,
    };
  }

  static DocumentReference<RecommendData> _getRef(String userid) {
    return FirebaseFirestore.instance
        .collection('recommendData')
        .doc(userid)
        .withConverter<RecommendData>(
            fromFirestore: ((snapshot, _) =>
                RecommendData.fromJson(snapshot.data()!)),
            toFirestore: ((data, _) => data.toJson()));
  }

  @override
  Future<void> addViews() async {
    var ref = _getRef(_userId);
    await ref.update({'views': FieldValue.increment(1)});
  }

  static Future<RecommendData?> getRecommendData(String userid) async {
    final doc = await _getRef(userid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  static Future<RecommendData?> _getByUserClass(AppUser user) async {
    final groups = user.groups;
    List<String> userIDs = [];
    for (var groupID in groups) {
      final group = await Group.getGroup(groupID);
      if (group == null) {
        continue;
      }
      userIDs.addAll(group.members);
    }
    final random = Random();
    final randomIndex = random.nextInt(userIDs.length);
    final randomUserID = userIDs[randomIndex];
    final recommendData = await getRecommendData(randomUserID);
    return recommendData;
  }

  static Future<RecommendData?> getRecommendDataByCurrentUid(
      String? currentUser) async {
    currentUid = currentUser;
    if (currentUid == null) {
      return null;
    }
    final user = await AppUser.getUser(currentUid!);
    if (user == null) {
      return null;
    }

    recommendData ??= await _getByUserClass(user);
    final returnObj = recommendData?.copy();
    _getByUserClass(user).then((value) async {
      recommendData = value;
    });
    return returnObj;
  }

  static Future<RecommendData?> getExpDataByWord({required String userId}) {
    return getRecommendData(userId);
  }

  @override
  Future<void> save() async {
    await _getRef(_userId).set(this);
  }

  @override
  Future<void> delete() async {
    await _getRef(_userId).delete();
  }

  @override
  Future<void> bad(String uid) async {
    return;
  }

  @override
  Future<void> good(String uid) async {
    return;
  }
}
