import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data; // Corrigido: prefixo único para os dados
import 'package:timezone/timezone.dart' as tz;

/// Serviço Singleton para gerenciar Notificações Locais
class NotificationService {
  static final NotificationService _instancia = NotificationService._internal();

  factory NotificationService() {
    return _instancia;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Inicializa o plugin e os fusos horários (Chame no main.dart)
  Future<void> inicializar() async {
    tz_data.initializeTimeZones();
    
    // Ícone padrão do Android (deve existir na pasta res/mipmap)
    // NOTA: Removidos os "const" para evitar erros dependendo da versão do seu pacote
    final AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuração essencial para iOS/macOS evitar erros de compilação/execução
    final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    
    await _plugin.initialize(initSettings);
  }

  /// Pede permissão para enviar notificações e alarmes exatos (Necessário no Android 13+ e iOS)
  Future<void> solicitarPermissoes() async {
    // Permissões no Android
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
      await androidImpl.requestExactAlarmsPermission();
    }

    // Permissões no iOS
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Agenda uma notificação para daqui a 'X' segundos
  Future<void> agendarNotificacaoFimTimer({
    required int id,
    required String titulo,
    required String corpo,
    required int segundosRestantes,
  }) async {
    // Usa tz.UTC no lugar de tz.local para garantir que não haja crash de Localização (LocationNotFound)
    final tz.TZDateTime dataAgendada = tz.TZDateTime.now(tz.UTC).add(Duration(seconds: segundosRestantes));

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hiperfoco_timer', 
      'Cronômetro Hiperfoco', 
      importance: Importance.max, 
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      id,
      titulo,
      corpo,
      dataAgendada,
      NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Funciona mesmo em Doze Mode (economia de bateria)
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela uma notificação agendada pelo ID
  Future<void> cancelarNotificacao(int id) async {
    await _plugin.cancel(id);
  }
}