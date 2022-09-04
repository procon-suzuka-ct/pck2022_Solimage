import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  final String _word;
  final String _root;

  String get word => _word;
  String get root => _root;

  Word({required String word, required String root})
      : _word = word,
        _root = root;

  //WordをFirestoreに保存する
  Future<void> save() async {
    await FirebaseFirestore.instance.collection('words').doc(_word).set({
      'word': _word,
      'root': _root,
    });
  }

  //WordをFirestoreから取得する
  static Future<Word?> getWord(String word) async {
    final doc =
        await FirebaseFirestore.instance.collection('words').doc(word).get();
    if (doc.exists) {
      final word = Word(word: doc['word'], root: doc['root']);
      return word;
    } else {
      return null;
    }
  }

  //WordsをFirestoreから取得する
  static Future<List<Word>> getWords() async {
    final docs = await FirebaseFirestore.instance.collection('words').get();
    List<Word> words = [];
    for (final doc in docs.docs) {
      final word = Word(word: doc['word'], root: doc['root']);
      words.add(word);
    }
    return words;
  }

  //WordsをFirestoreから取得する
  static Future<List<Word>> getWordsByRoot(String root) async {
    final docs = await FirebaseFirestore.instance
        .collection('words')
        .where('root', isEqualTo: root)
        .get();
    List<Word> words = [];
    for (final doc in docs.docs) {
      final word = Word(word: doc['word'], root: doc['root']);
      words.add(word);
    }
    return words;
  }

  //WordをFirestoreから削除する
  static Future<void> deleteWord(String word) async {
    await FirebaseFirestore.instance.collection('words').doc(word).delete();
  }
}
