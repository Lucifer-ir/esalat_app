import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'esalat_cars.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            manufacturer_group TEXT,
            car_name TEXT,
            car_model TEXT,
            engine_number_location TEXT,
            engine_number_format TEXT,
            chassis_number_location TEXT,
            chassis_number_format TEXT,
            specs_plate_location TEXT,
            chassis_plate_location TEXT,
            label_location TEXT,
            vin_location TEXT,
            other_notes TEXT,
            is_synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // ذخیره خودرو در دیتابیس محلی
  Future<int> insertVehicle(Map<String, dynamic> vehicle) async {
    Database db = await database;
    return await db.insert('vehicles', vehicle);
  }

  // گرفتن لیست تمام خودروهای ذخیره شده
  Future<List<Map<String, dynamic>>> getVehicles() async {
    Database db = await database;
    return await db.query('vehicles', orderBy: 'id DESC');
  }

  // گرفتن خودروهایی که هنوز به سرور ارسال نشده‌اند (برای همگام‌سازی)
  Future<List<Map<String, dynamic>>> getUnsyncedVehicles() async {
    Database db = await database;
    return await db.query('vehicles', where: 'is_synced = 0');
  }

  // آپدیت وضعیت خودرو به ارسال شده به سرور
  Future<void> markAsSynced(int id) async {
    Database db = await database;
    await db.update('vehicles', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}