import 'package:cloud_firestore/cloud_firestore.dart';

class Mijoz {
  Mijoz({
    required this.id,
    required this.nomi,
    this.shahar = '',
    this.manzil = '',
    this.email = '',
    required this.telefon,
    this.faol = true,
    required this.yaratilganSana,
  });

  factory Mijoz.fromFirestore(Map<String, dynamic> data, String id) => Mijoz(
        id: id,
        nomi: data['nomi'] as String? ?? '',
        shahar: data['shahar'] as String? ?? '',
        manzil: data['manzil'] as String? ?? '',
        email: data['email'] as String? ?? '',
        telefon: data['telefon'] as String? ?? '',
        faol: data['faol'] as bool? ?? true,
        yaratilganSana:
            (data['yaratilganSana'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
  final String id;
  final String nomi;
  final String shahar;
  final String manzil;
  final String email;
  final String telefon;
  final bool faol;
  final DateTime yaratilganSana;

  Map<String, dynamic> toFirestore() => {
        'nomi': nomi,
        'shahar': shahar,
        'manzil': manzil,
        'email': email,
        'telefon': telefon,
        'faol': faol,
        'yaratilganSana': Timestamp.fromDate(yaratilganSana),
      };
}

class Kategoriya {
  Kategoriya({
    required this.id,
    required this.nomi,
    this.mahsulotlarSoni = 0,
    required this.yaratilganSana,
  });

  factory Kategoriya.fromFirestore(Map<String, dynamic> data, String id) =>
      Kategoriya(
        id: id,
        nomi: data['nomi'] as String? ?? '',
        mahsulotlarSoni: data['mahsulotlarSoni'] as int? ?? 0,
        yaratilganSana:
            (data['yaratilganSana'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
  final String id;
  final String nomi;
  int mahsulotlarSoni;
  final DateTime yaratilganSana;

  Map<String, dynamic> toFirestore() => {
        'nomi': nomi,
        'mahsulotlarSoni': mahsulotlarSoni,
        'yaratilganSana': Timestamp.fromDate(yaratilganSana),
      };
}

class Mahsulot {
  Mahsulot({
    required this.id,
    required this.nomi,
    required this.kategoriya,
    required this.kategoriyaId,
    required this.birlik,
    required this.tannarx,
    required this.narx,
    required this.miqdor,
  });

  factory Mahsulot.fromFirestore(Map<String, dynamic> data, String id) =>
      Mahsulot(
        id: id,
        nomi: data['nomi'] as String? ?? '',
        kategoriya: data['kategoriya'] as String? ?? '',
        kategoriyaId: data['kategoriyaId'] as String? ?? '',
        birlik: data['birlik'] as String? ?? '',
        tannarx: (data['tannarx'] as num? ?? 0).toDouble(),
        narx: (data['narx'] as num? ?? 0).toDouble(),
        miqdor: data['miqdor'] as int? ?? 0,
      );
  final String id;
  final String nomi;
  final String kategoriya;
  final String kategoriyaId;
  final String birlik;
  final double tannarx;
  final double narx;
  int miqdor;

  bool get kamQolgan => miqdor <= 0;

  Map<String, dynamic> toFirestore() => {
        'nomi': nomi,
        'kategoriya': kategoriya,
        'kategoriyaId': kategoriyaId,
        'birlik': birlik,
        'tannarx': tannarx,
        'narx': narx,
        'miqdor': miqdor,
      };
}

class YukXatiMahsulot {
  YukXatiMahsulot({
    required this.mahsulotId,
    required this.mahsulotNomi,
    required this.miqdor,
    required this.narx,
    required this.jami,
  });

  factory YukXatiMahsulot.fromMap(Map<String, dynamic> data) => YukXatiMahsulot(
        mahsulotId: data['mahsulotId'] as String? ?? '',
        mahsulotNomi: data['mahsulotNomi'] as String? ?? '',
        miqdor: data['miqdor'] as int? ?? 0,
        narx: (data['narx'] as num? ?? 0).toDouble(),
        jami: (data['jami'] as num? ?? 0).toDouble(),
      );
  final String mahsulotId;
  final String mahsulotNomi;
  final int miqdor;
  final double narx;
  final double jami;

  Map<String, dynamic> toMap() => {
        'mahsulotId': mahsulotId,
        'mahsulotNomi': mahsulotNomi,
        'miqdor': miqdor,
        'narx': narx,
        'jami': jami,
      };
}

class YukXati {
  YukXati({
    required this.id,
    required this.raqami,
    required this.mijozId,
    required this.mijozNomi,
    required this.sana,
    required this.summa,
    required this.foyda,
    required this.mahsulotlar,
  });

  factory YukXati.fromFirestore(Map<String, dynamic> data, String id) =>
      YukXati(
        id: id,
        raqami: data['raqami'] as String? ?? '',
        mijozId: data['mijozId'] as String? ?? '',
        mijozNomi: data['mijozNomi'] as String? ?? '',
        sana: (data['sana'] as Timestamp?)?.toDate() ?? DateTime.now(),
        summa: (data['summa'] as num? ?? 0).toDouble(),
        foyda: (data['foyda'] as num? ?? 0).toDouble(),
        mahsulotlar: (data['mahsulotlar'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(YukXatiMahsulot.fromMap)
            .toList(),
      );
  final String id;
  final String raqami;
  final String mijozId;
  final String mijozNomi;
  final DateTime sana;
  final double summa;
  final double foyda;
  final List<YukXatiMahsulot> mahsulotlar;

  Map<String, dynamic> toFirestore() => {
        'raqami': raqami,
        'mijozId': mijozId,
        'mijozNomi': mijozNomi,
        'sana': Timestamp.fromDate(sana),
        'summa': summa,
        'foyda': foyda,
        'mahsulotlar': mahsulotlar.map((m) => m.toMap()).toList(),
      };
}

class AppUser {
  AppUser({
    required this.id,
    required this.login,
    required this.ismFamilya,
    required this.rol,
    this.faol = true,
    required this.yaratilganSana,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) =>
      AppUser(
        id: id,
        login: data['login'] as String? ?? '',
        ismFamilya: data['ismFamilya'] as String? ?? '',
        rol: data['rol'] as String? ?? 'Xodim',
        faol: data['faol'] as bool? ?? true,
        yaratilganSana:
            (data['yaratilganSana'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
  final String id;
  final String login;
  final String ismFamilya;
  final String rol;
  final bool faol;
  final DateTime yaratilganSana;

  Map<String, dynamic> toFirestore() => {
        'login': login,
        'ismFamilya': ismFamilya,
        'rol': rol,
        'faol': faol,
        'yaratilganSana': Timestamp.fromDate(yaratilganSana),
      };
}
