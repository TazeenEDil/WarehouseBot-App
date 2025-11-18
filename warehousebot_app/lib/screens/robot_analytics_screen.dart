import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicator.dart';

class RobotAnalyticsScreen extends StatefulWidget {
  static const String routeName = '/analytics';
  @override
  State<RobotAnalyticsScreen> createState() => _RobotAnalyticsScreenState();
}

class _RobotAnalyticsScreenState extends State<RobotAnalyticsScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get('/robot/analytics');
      // expected: { success: true, data: { battery: 87, cpuTemp: 44, speed: 1.2, lastSeen: '...' } }
      if (res is Map && res['data'] != null) {
        setState(() { _data = Map<String, dynamic>.from(res['data']); });
      } else {
        setState(() { _error = 'Unexpected response from server'; });
      }
    } on Exception catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Robot Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _loading
            ? LoadingIndicator(message: 'Loading analytics...')
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: ListTile(
                          title: Text('Battery'),
                          trailing: Text('${_data?['battery'] ?? '—'}%'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text('CPU Temp'),
                          trailing: Text('${_data?['cpuTemp'] ?? '—'} °C'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text('Speed'),
                          trailing: Text('${_data?['speed'] ?? '—'} m/s'),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text('Raw telemetry', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Expanded(child: SingleChildScrollView(child: Text(_data.toString()))),
                    ],
                  ),
      ),
    );
  }
}
