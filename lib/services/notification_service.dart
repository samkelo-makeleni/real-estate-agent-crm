import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/appointment_model.dart';

class NotificationService {
  NotificationService();

  static const int viewingReminderMinutesBefore = 60;
  static const _enabledKey = 'push_notifications_enabled';
  static const _channelId = 'viewing_reminders';
  static const _channelName = 'Viewing reminders';
  static const _channelDescription = 'Reminders for upcoming property viewings';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _enabled = false;
  bool _pluginAvailable = true;

  bool get enabled => _enabled;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
      );
    } catch (error) {
      debugPrint('Notifications unavailable in this runtime: $error');
      _pluginAvailable = false;
    }
    _initialized = true;
    if (!_pluginAvailable) {
      _enabled = false;
      return;
    }
    _enabled = await _loadEnabledPreference();
  }

  Future<bool> setEnabled(
    bool enabled, {
    required List<AppointmentModel> appointments,
  }) async {
    await initialize();

    if (enabled) {
      if (!_pluginAvailable) return false;
      final granted = await _requestPermissions();
      if (!granted) {
        _enabled = false;
        await _saveEnabledPreference(false);
        await cancelViewingReminders();
        return false;
      }
    }

    _enabled = enabled;
    await _saveEnabledPreference(enabled);

    if (enabled) {
      await scheduleViewingReminders(appointments);
    } else {
      await cancelViewingReminders();
    }

    return _enabled;
  }

  Future<void> scheduleViewingReminders(
    List<AppointmentModel> appointments,
  ) async {
    await initialize();
    if (!_enabled || !_pluginAvailable || kIsWeb) return;

    for (final appointment in appointments) {
      await _plugin.cancel(id: _notificationIdFor(appointment.id));
      await scheduleViewingReminder(appointment);
    }
  }

  Future<void> scheduleViewingReminder(AppointmentModel appointment) async {
    await initialize();
    if (!_enabled ||
        !_pluginAvailable ||
        kIsWeb ||
        appointment.status == AppointmentStatus.cancelled) {
      return;
    }

    final reminderAt = appointment.dateTime.subtract(
      const Duration(minutes: viewingReminderMinutesBefore),
    );
    if (!reminderAt.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: _notificationIdFor(appointment.id),
      title: 'Viewing reminder',
      body:
          '${appointment.clientName} viewing starts in '
          '$viewingReminderMinutesBefore minutes.',
      scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'appointment:${appointment.id}',
    );
  }

  Future<void> cancelViewingReminders() async {
    await initialize();
    if (!_pluginAvailable) return;
    await _plugin.cancelAll();
  }

  Future<bool> _requestPermissions() async {
    if (kIsWeb) return false;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted != null) return androidGranted;

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosGranted != null) return iosGranted;

    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final macosGranted = await macos?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return macosGranted ?? true;
  }

  Future<bool> _loadEnabledPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<void> _saveEnabledPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  int _notificationIdFor(String appointmentId) {
    return appointmentId.codeUnits.fold<int>(
      0,
      (value, codeUnit) => (value * 31 + codeUnit) & 0x7fffffff,
    );
  }
}
