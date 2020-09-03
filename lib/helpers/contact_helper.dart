import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idC = "idC";
final String nameC = "nameC";
final String emailC = "emailC";
final String phoneC = "phoneC";
final String imgC = "imgC";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null)
      return _db;
    else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newrVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idC INTEGER PRIMARY KEY, $nameC TEXT, $emailC TEXT, $phoneC TEXT, $imgC TEXT)");
    });
  }

  Future<Contact> saveContact(Contact c) async {
    Database dbContact = await db;
    c.id = await dbContact.insert(contactTable, c.toMap());
    return c;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idC, nameC, emailC, phoneC, imgC],
        where: "$idC = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else
      return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idC = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact c) async {
    Database dbContact = await db;
    return await dbContact
        .update(contactTable, c.toMap(), where: "$idC = ?", whereArgs: [c.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listC = List();
    for (Map m in listMap) {
      listC.add(Contact.fromMap(m)); //para cada mapa, transforma em um mapa
    }

    return listC;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact(); //construtor vazio

  Contact.fromMap(Map map) {
    id = map[idC];
    name = map[nameC];
    email = map[emailC];
    phone = map[phoneC];
    img = map[imgC];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameC: name,
      emailC: email,
      phoneC: phone,
      imgC: img,
    };

    if (id != null) map[idC] = id;

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id,\nnome: $name,\nemail:$email,\nphone:$phone,\nimg:$img)";
  }
}
