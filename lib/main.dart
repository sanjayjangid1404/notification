import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Notifications',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: NotificationSettingsPage(),
      debugShowCheckedModeBanner: false, // Remove the debug label
    );
  }
}

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  int _selectedGender = 0; // 0 for female, 1 for male
  TimeOfDay? _selectedTime1;
  TimeOfDay? _selectedTime2;
  bool _isTime1Enabled = false;
  bool _isTime2Enabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGender = prefs.getInt('selectedGender') ?? 0;
      _isTime1Enabled = prefs.getBool('isTime1Enabled') ?? false;
      _isTime2Enabled = prefs.getBool('isTime2Enabled') ?? false;
      // Load times (use default time if not found)
      _selectedTime1 = TimeOfDay(
        hour: prefs.getInt('selectedTime1Hour') ?? 12,
        minute: prefs.getInt('selectedTime1Minute') ?? 0,
      );
      _selectedTime2 = TimeOfDay(
        hour: prefs.getInt('selectedTime2Hour') ?? 12,
        minute: prefs.getInt('selectedTime2Minute') ?? 0,
      );
    });
  }

  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedGender', _selectedGender);
    prefs.setBool('isTime1Enabled', _isTime1Enabled);
    prefs.setBool('isTime2Enabled', _isTime2Enabled);
    if (_selectedTime1 != null) {
      prefs.setInt('selectedTime1Hour', _selectedTime1!.hour);
      prefs.setInt('selectedTime1Minute', _selectedTime1!.minute);
    }
    if (_selectedTime2 != null) {
      prefs.setInt('selectedTime2Hour', _selectedTime2!.hour);
      prefs.setInt('selectedTime2Minute', _selectedTime2!.minute);
    }
  }

  _pickTime(int timeIndex) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: timeIndex == 1
          ? _selectedTime1 ?? TimeOfDay.now()
          : _selectedTime2 ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (timeIndex == 1) {
          _selectedTime1 = pickedTime;
        } else {
          _selectedTime2 = pickedTime;
        }
        _savePreferences();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Gender', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    contentPadding:EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(Icons.female, color: Colors.pink),
                        SizedBox(width: 10),
                        Text('Female'),
                      ],
                    ),
                    value: 0,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value as int;
                        _savePreferences();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: Row(
                      children: [
                        Icon(Icons.male, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Male'),
                      ],
                    ),
                    value: 1,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value as int;
                        _savePreferences();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isTime1Enabled,
                  onChanged: (value) {
                    setState(() {
                      _isTime1Enabled = value!;
                      _savePreferences();
                    });
                  },
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Time 1'),
                    subtitle:
                    Text(_selectedTime1?.format(context) ?? 'Not set'),
                    onTap: () => _pickTime(1),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isTime2Enabled,
                  onChanged: (value) {
                    setState(() {
                      _isTime2Enabled = value!;
                      _savePreferences();
                    });
                  },
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Time 2'),
                    subtitle:
                    Text(_selectedTime2?.format(context) ?? 'Not set'),
                    onTap: () => _pickTime(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}