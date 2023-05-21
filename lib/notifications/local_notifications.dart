import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  LocalNotificationService();

  final _localNotificationService = FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> intialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/ic_stat_ac_unit');

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotificationService.initialize(
      settings,

      // onDidReceiveNotificationResponse: onSelectNotification,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('expiration', 'Сроки годности',
            channelDescription:
                'Уведомления об истекающем сроке годности продуктов',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true);

    return const NotificationDetails(
      android: androidNotificationDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails();
    // await _localNotificationService.show(id, title, body, details);
    await _localNotificationService.zonedSchedule(id, title, body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)), details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

/**
 *Запустить отложенное уведомление
 *
 *Если дата сегодня или раньше, уведомление придет через несколько секунд после запуска
 */
  Future<void> showScheduledNotification(
      {required int id,
      required String title,
      required String body,
      required DateTime date}) async {
    final details = await _notificationDetails();
    date.isAfter(DateTime.now())
        ? await _localNotificationService.zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(
              date,
              // date.subtract(const Duration(days: 1)),
              // DateTime.now().add(Duration(seconds: seconds)),
              tz.local,
            ),
            details,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          )
        : await _localNotificationService.zonedSchedule(id, title, body,
            tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)), details,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);

    ;
  }

  Future<void> showNotificationWithPayload(
      {required int id,
      required String title,
      required String body,
      required String payload}) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details,
        payload: payload);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  void onSelectNotification(String? payload) {
    print('payload $payload');
    if (payload != null && payload.isNotEmpty) {
      onNotificationClick.add(payload);
    }
  }
}
