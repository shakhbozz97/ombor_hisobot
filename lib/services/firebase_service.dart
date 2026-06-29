import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ombor_hisobot/models/models.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── AUTH ───────────────────────────────────────────────────────────────────
  /// Muvaffaqiyatli bo'lsa [UserCredential], xato bo'lsa [FirebaseAuthException] tashlaydi.
  static Future<UserCredential> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<void> logout() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;

  // ─── MIJOZLAR ───────────────────────────────────────────────────────────────
  static Stream<List<Mijoz>> getMijozlar() =>
      _db.collection('mijozlar').orderBy('nomi').snapshots().map((s) =>
          s.docs.map((d) => Mijoz.fromFirestore(d.data(), d.id)).toList());

  static Future<void> addMijoz(Mijoz m) =>
      _db.collection('mijozlar').add(m.toFirestore());

  static Future<void> updateMijoz(Mijoz m) =>
      _db.collection('mijozlar').doc(m.id).update(m.toFirestore());

  static Future<void> deleteMijoz(String id) =>
      _db.collection('mijozlar').doc(id).delete();

  // ─── KATEGORIYALAR ──────────────────────────────────────────────────────────
  static Stream<List<Kategoriya>> getKategoriyalar() =>
      _db.collection('kategoriyalar').orderBy('nomi').snapshots().map((s) =>
          s.docs.map((d) => Kategoriya.fromFirestore(d.data(), d.id)).toList());

  static Future<void> addKategoriya(Kategoriya k) =>
      _db.collection('kategoriyalar').add(k.toFirestore());

  static Future<void> updateKategoriya(Kategoriya k) =>
      _db.collection('kategoriyalar').doc(k.id).update(k.toFirestore());

  static Future<void> deleteKategoriya(String id) =>
      _db.collection('kategoriyalar').doc(id).delete();

  // ─── MAHSULOTLAR ────────────────────────────────────────────────────────────
  static Stream<List<Mahsulot>> getMahsulotlar() =>
      _db.collection('mahsulotlar').orderBy('nomi').snapshots().map((s) =>
          s.docs.map((d) => Mahsulot.fromFirestore(d.data(), d.id)).toList());

  static Future<void> addMahsulot(Mahsulot m) =>
      _db.collection('mahsulotlar').add(m.toFirestore());

  static Future<void> updateMahsulot(Mahsulot m) =>
      _db.collection('mahsulotlar').doc(m.id).update(m.toFirestore());

  static Future<void> deleteMahsulot(String id) =>
      _db.collection('mahsulotlar').doc(id).delete();

  // ─── YUK XATLARI ────────────────────────────────────────────────────────────
  static Stream<List<YukXati>> getYukXatlari() => _db
      .collection('yukxatlari')
      .orderBy('sana', descending: true)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => YukXati.fromFirestore(d.data(), d.id)).toList());

  /// Yuk xatini qo'shib, mahsulot miqdorlarini atomik batch bilan kamaytiradi.
  static Future<String> addYukXati(YukXati y) async {
    final batch = _db.batch();

    final yukRef = _db.collection('yukxatlari').doc();
    batch.set(yukRef, y.toFirestore());

    for (final item in y.mahsulotlar) {
      final ref = _db.collection('mahsulotlar').doc(item.mahsulotId);
      batch.update(ref, {'miqdor': FieldValue.increment(-item.miqdor)});
    }

    await batch.commit();
    return yukRef.id;
  }

  /// Yuk xatini o'chirib, mahsulot miqdorlarini atomik batch bilan tiklaydi.
  static Future<void> deleteYukXati(YukXati y) async {
    final batch = _db.batch();

    for (final item in y.mahsulotlar) {
      final ref = _db.collection('mahsulotlar').doc(item.mahsulotId);
      batch.update(ref, {'miqdor': FieldValue.increment(item.miqdor)});
    }

    batch.delete(_db.collection('yukxatlari').doc(y.id));
    await batch.commit();
  }

  // ─── FOYDALANUVCHILAR ───────────────────────────────────────────────────────
  static Stream<List<AppUser>> getFoydalanuvchilar() =>
      _db.collection('foydalanuvchilar').snapshots().map((s) =>
          s.docs.map((d) => AppUser.fromFirestore(d.data(), d.id)).toList());

  static Future<void> addFoydalanuvchi(AppUser u) =>
      _db.collection('foydalanuvchilar').add(u.toFirestore());

  static Future<void> updateFoydalanuvchi(AppUser u) =>
      _db.collection('foydalanuvchilar').doc(u.id).update(u.toFirestore());

  static Future<void> deleteFoydalanuvchi(String id) =>
      _db.collection('foydalanuvchilar').doc(id).delete();

  // ─── DASHBOARD STATS ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final results = await Future.wait([
      _db.collection('yukxatlari').get(),
      _db.collection('mahsulotlar').get(),
      _db.collection('mijozlar').get(),
    ]);

    final yukSnap = results[0];
    final mahsulotSnap = results[1];
    final mijozSnap = results[2];

    double totalSavdo = 0;
    double buOySavdo = 0;
    double totalFoyda = 0;
    double buOyFoyda = 0;

    for (final d in yukSnap.docs) {
      final data = d.data();
      final summa = (data['summa'] as num? ?? 0).toDouble();
      final foyda = (data['foyda'] as num? ?? 0).toDouble();
      totalSavdo += summa;
      totalFoyda += foyda;
      final sana = (data['sana'] as Timestamp?)?.toDate();
      if (sana != null && !sana.isBefore(startOfMonth)) {
        buOySavdo += summa;
        buOyFoyda += foyda;
      }
    }

    int kamQolgan = 0;
    int totalMiqdor = 0;
    for (final d in mahsulotSnap.docs) {
      final miqdor = (d.data()['miqdor'] as num? ?? 0).toInt();
      totalMiqdor += miqdor;
      if (miqdor <= 0) kamQolgan++;
    }

    final faolMijozlar =
        mijozSnap.docs.where((d) => d.data()['faol'] == true).length;

    return {
      'totalSavdo': totalSavdo,
      'buOySavdo': buOySavdo,
      'totalFoyda': totalFoyda,
      'buOyFoyda': buOyFoyda,
      'totalYuk': yukSnap.docs.length,
      'totalMijoz': mijozSnap.docs.length,
      'faolMijoz': faolMijozlar,
      'ombordagi': totalMiqdor,
      'kamQolgan': kamQolgan,
    };
  }
}
