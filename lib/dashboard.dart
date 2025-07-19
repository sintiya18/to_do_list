import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';

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
  TextEditingController searchController = TextEditingController();
  String query = '';
  String userDisplayName = 'User';
  bool isLoading = false;

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
      userDisplayName = (response?['username'] ?? user.email ?? 'User').toString();
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

    for (var task in response) {
      final status = (task['status'] ?? 'belum_dikerjakan').toString().toLowerCase();
      final title = (task['title'] ?? '').toString();
      final deadline = (task['deadline'] ?? '').toString();
      final id = task['id'];

      String formattedDate = '';
      try {
        final dateTime = DateTime.parse(deadline).toLocal();
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
      } else {
        pending.add(map);
      }
    }

    setState(() {
      pendingTasks = pending;
      completedTasks = completed;
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
    final filteredTasks = tasks
        .where((task) => task['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredTasks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tidak ada tugas."),
          const SizedBox(height: 16),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...filteredTasks.map(
          (task) => Card(
            child: ListTile(
              leading: Icon(
                task['status'] == 'sudah_dikerjakan'
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: task['status'] == 'sudah_dikerjakan' ? Colors.green : Colors.grey,
              ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $userDisplayName 👋',
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedItemColor: const Color.fromARGB(255, 50, 170, 144),
        unselectedItemColor: const Color.fromARGB(179, 98, 207, 184),
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
