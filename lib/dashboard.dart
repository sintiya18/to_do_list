import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'edit_tugas.dart';
import 'tambah_tugas.dart';
import 'profil.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

Future<void> scheduleNotification({
  required String title,
  required String body,
  required DateTime scheduledTime,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'task_channel',
    'Tugas',
    channelDescription: 'Pengingat tugas',
    importance: Importance.max,
    priority: Priority.high,
  );
  const platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    scheduledTime.millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    tz.TZDateTime.from(scheduledTime, tz.local),
    platformDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, String>> pendingTasks = [
    {
      'title': 'Belajar Flutter',
      'date': '07/07/2025 14:00',
      'status': 'Belum Dikerjakan'
    },
    {
      'title': 'Mengerjakan Proyek Kelompok',
      'date': '29/07/2025 16:30',
      'status': 'Belum Dikerjakan'
    },
  ];

  List<Map<String, String>> completedTasks = [
    {
      'title': 'Membuat laporan mingguan',
      'date': '25/06/2025 10:00',
      'status': 'Sudah Dikerjakan'
    },
    {
      'title': 'Membaca materi desain',
      'date': '20/06/2025 08:30',
      'status': 'Sudah Dikerjakan'
    },
  ];

  TextEditingController searchController = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    tz.initializeTimeZones();
  }

  void editTask(Map<String, String> task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTugasScreen(task: task)),
    );

    if (updatedTask != null) {
      setState(() {
        pendingTasks.remove(task);
        completedTasks.remove(task);

        if (updatedTask['status'] == 'Sudah Dikerjakan') {
          completedTasks.add(updatedTask);
        } else {
          pendingTasks.add(updatedTask);
        }
      });
    }
  }

  void deleteTask(Map<String, String> task) {
    setState(() {
      pendingTasks.remove(task);
      completedTasks.remove(task);
    });
  }

  Future<void> pickReminderTime(Map<String, String> task) async {
    DateTime? taskDateTime;
    try {
      taskDateTime =
          DateFormat('dd/MM/yyyy HH:mm').parse(task['date']!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format tanggal & jam tidak valid")),
      );
      return;
    }

    if (taskDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Waktu sudah lewat, pilih yang lain")),
      );
      return;
    }

    await scheduleNotification(
      title: "Pengingat Tugas",
      body: task['title']!,
      scheduledTime: taskDateTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pengingat untuk '${task['title']}' dijadwalkan!")),
    );
  }

  Widget buildTaskList(String title, List<Map<String, String>> tasks) {
    final filteredTasks = tasks.where((task) {
      return task['title']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredTasks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Tidak ada tugas."),
          const SizedBox(height: 16),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...filteredTasks.map(
          (task) => Card(
            child: ListTile(
              leading: Icon(
                task['status'] == 'Sudah Dikerjakan'
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: task['status'] == 'Sudah Dikerjakan'
                    ? Colors.green
                    : Colors.grey,
              ),
              title: Text(task['title']!),
              subtitle: Text("Deadline: ${task['date']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task['status'] == 'Belum Dikerjakan') ...[
                    IconButton(
                      icon: const Icon(Icons.alarm, color: Colors.orange),
                      onPressed: () => pickReminderTime(task),
                      tooltip: "Setel pengingat",
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => editTask(task),
                      tooltip: "Edit tugas",
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteTask(task),
                    tooltip: "Hapus tugas",
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB2FEFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, User! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selamat datang di aplikasi To-Do List',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari tugas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                buildTaskList('Tugas Belum Dikerjakan', pendingTasks),
                buildTaskList('Tugas Sudah Dikerjakan', completedTasks),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTugas()),
          );

          if (newTask != null) {
            setState(() {
              if (newTask['status'] == 'Sudah Dikerjakan') {
                completedTasks.add(newTask);
              } else {
                pendingTasks.add(newTask);
              }
            });
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: "Tambah tugas",
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlueAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
