import 'package:shared_preferences/shared_preferences.dart';

/// Padrão Singleton - Encapsula e centraliza a persistência do Timestamp de forma agnóstica à UI
class TimeStorageService {
  static final TimeStorageService _instancia = TimeStorageService._internal();

  factory TimeStorageService() {
    return _instancia;
  }

  TimeStorageService._internal();

  static const String _keyTimestamp = 'hiperfoco_background_timestamp';

  /// Salva o exato momento em que o app foi para segundo plano (paused)
  Future<void> salvarTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTimestamp, timestamp.toIso8601String());
  }

  /// Recupera o momento em que o app foi pausado e converte de volta para DateTime
  Future<DateTime?> recuperarTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timestampStr = prefs.getString(_keyTimestamp);
    if (timestampStr == null || timestampStr.isEmpty) return null;
    return DateTime.tryParse(timestampStr);
  }

  /// Limpa o registro após ser utilizado para evitar cálculos residuais em reaberturas futuras
  Future<void> limparTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTimestamp);
  }
}