import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:fl_chart/fl_chart.dart';

import 'edit_tugas.dart';
import 'tambah_tugas.dart';
import 'profil.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> pendingTasks = [];
  List<Map<String, dynamic>> completedTasks = [];
  List<Map<String, dynamic>> overdueTasks = [];
  String userDisplayName = 'User';
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchTasks();
  }

  Future<void> fetchUserName() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        userDisplayName =
            (response?['username'] ?? user.email ?? 'User').toString();
      });
    }
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('todos')
        .select()
        .eq('user_id', userId)
        .order('deadline', ascending: true);

    final List<Map<String, dynamic>> pending = [];
    final List<Map<String, dynamic>> completed = [];
    final List<Map<String, dynamic>> overdue = [];

    for (var task in response) {
      final status =
          (task['status'] ?? 'belum_dikerjakan').toString().toLowerCase();
      final title = (task['title'] ?? '').toString();
      final deadline = (task['deadline'] ?? '').toString();
      final id = task['id'];

      String formattedDate = '';
      DateTime? dateTime;
      try {
        dateTime = DateTime.parse(deadline).toLocal();
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      } catch (_) {
        formattedDate = deadline;
      }

      final map = {
        'id': id,
        'title': title,
        'date': formattedDate,
        'status': status,
        'deadline': deadline,
      };

      if (status == 'sudah_dikerjakan') {
        completed.add(map);
      } else if (dateTime != null && dateTime.isBefore(DateTime.now())) {
        overdue.add(map);
      } else {
        pending.add(map);
      }
    }

    setState(() {
      pendingTasks = pending;
      completedTasks = completed;
      overdueTasks = overdue;
      isLoading = false;
    });
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    final supabase = Supabase.instance.client;
    await supabase.from('todos').delete().eq('id', task['id']);
    showFlushbar("Tugas berhasil dihapus", color: Colors.red);
    fetchTasks();
  }

  Future<void> editTask(Map<String, dynamic> task) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTugasScreen(task: task)),
    );
    if (updated == true) {
      fetchTasks();
    }
  }

  void showFlushbar(String message, {Color color = Colors.green}) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        color == Colors.green ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
    ).show(context);
  }

  Widget buildTaskList(String title, List<Map<String, dynamic>> tasks) {
    final filtered = tasks
        .where((task) => task['title']
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          const Text(
            "Tidak ada tugas.",
            textAlign: TextAlign.left,
            style: TextStyle(fontStyle: FontStyle.italic),
          )
        else
          ...filtered.map(
            (task) {
              Color cardColor = Colors.white;
              Widget leadingIcon = const Icon(Icons.circle, color: Colors.grey);

              if (task['status'] == 'sudah_dikerjakan') {
                cardColor = Colors.green.shade100;
                leadingIcon =
                    const Icon(Icons.check_circle, color: Colors.green);
              } else {
                final deadline = DateTime.tryParse(task['deadline'] ?? '');
                if (deadline != null && deadline.isBefore(DateTime.now())) {
                  cardColor = Colors.red.shade100;
                  leadingIcon = const Icon(Icons.warning, color: Colors.red);
                } else {
                  cardColor = Colors.yellow.shade100;
                  leadingIcon =
                      const Icon(Icons.hourglass_empty, color: Colors.orange);
                }
              }

              return Card(
                color: cardColor,
                child: ListTile(
                  leading: leadingIcon,
                  title: Text(task['title']),
                  subtitle: Text("Deadline: ${task['date']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (task['status'] != 'sudah_dikerjakan') ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editTask(task),
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(task),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildStatsSummary() {
    final total =
        pendingTasks.length + completedTasks.length + overdueTasks.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '📊 Statistik Tugas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: completedTasks.length.toDouble(),
                      color: Colors.green,
                      title:
                          '${(total > 0 ? completedTasks.length / total * 100 : 0).toStringAsFixed(1)}%\nSelesai',
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: pendingTasks.length.toDouble(),
                      color: Colors.orange,
                      title:
                          '${(total > 0 ? pendingTasks.length / total * 100 : 0).toStringAsFixed(1)}%\nBelum',
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: overdueTasks.length.toDouble(),
                      color: Colors.red,
                      title:
                          '${(total > 0 ? overdueTasks.length / total * 100 : 0).toStringAsFixed(1)}%\nOverdue',
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Tugas: $total',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB2FEFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchUserName();
            await fetchTasks();
          },
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Halo, $userDisplayName 👋',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Siap menyelesaikan tugas hari ini? 🚀',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      buildStatsSummary(),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari tugas...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      buildTaskList('Tugas Belum Dikerjakan', pendingTasks),
                      buildTaskList('Tugas Sudah Dikerjakan', completedTasks),
                      buildTaskList('Tugas Overdue', overdueTasks),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahTugas()),
          );
          if (result == true) {
            fetchTasks();
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.teal[200],
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
            if (updated == true) {
              await fetchUserName();
            }
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
