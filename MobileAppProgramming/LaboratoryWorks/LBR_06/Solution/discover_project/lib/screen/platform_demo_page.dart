import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformDemoPage extends StatefulWidget {
  const PlatformDemoPage({Key? key}) : super(key: key);

  @override
  State<PlatformDemoPage> createState() => _PlatformDemoPageState();
}

class _PlatformDemoPageState extends State<PlatformDemoPage> {
  static const batteryChannel = MethodChannel('samples.flutter.dev/battery');
  static const alarmChannel = MethodChannel('samples.flutter.dev/alarm');

  String _batteryLevel = 'Неизвестно';
  String _isCharging = 'Неизвестно';
  String _platformAlarmStatus = '';
  final _alarmController = TextEditingController();

  Future<void> _getBatteryLevel() async {
    try {
      final level = await batteryChannel.invokeMethod('getBatteryLevel');
      final charging = await batteryChannel.invokeMethod('isCharging');
      setState(() {
        _batteryLevel = 'Уровень заряда: $level%';
        _isCharging = charging == true ? 'Зарядка: Подключено' : 'Зарядка: НЕ подключено';
      });
    } catch (e) {
      setState(() {
        _batteryLevel = 'Ошибка: $e';
        _isCharging = 'Ошибка: $e';
      });
    }
  }

  Future<void> _setAlarm() async {
    try {
      final time = _alarmController.text;
      final result = await alarmChannel.invokeMethod('setAlarm', {'time': time});
      setState(() {
        _platformAlarmStatus = result;
      });
    } catch (e) {
      setState(() {
        _platformAlarmStatus = 'Ошибка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Channel Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                  color: Color(0xFFF1EAFE),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: Offset(0, 2))]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.battery_charging_full_outlined, color: Colors.deepPurple),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          backgroundColor: Color(0xFFF7F1FF),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 13),
                          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        onPressed: _getBatteryLevel,
                        label: Text('Получить заряд батареи'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF7F1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_batteryLevel, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(_isCharging, style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
            const Divider(),
            TextField(
              controller: _alarmController,
              decoration: InputDecoration(
                labelText: 'Время будильника (например, 07:30)',
                filled: true,
                fillColor: Color(0xFFF1EAFE),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.alarm, color: Colors.deepPurple),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                backgroundColor: Color(0xFFF7F1FF),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(vertical: 13),
                textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              onPressed: _setAlarm,
              label: const Text('Установить будильник'),
            ),
            Text(_platformAlarmStatus, style: TextStyle(fontSize: 15, color: Colors.deepPurple)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF7F1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(12),
              child: const Text(
                  'Сравнение Android vs iOS (логика реализуется в платформенных каналах)',
                  style: TextStyle(color: Colors.black87, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
