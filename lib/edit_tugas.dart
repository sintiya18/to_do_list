import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: EditTugas(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Task {
  final String title;
  final String description;
  final String date;

  Task({required this.title, required this.description, required this.date});
}

class EditTugas extends StatefulWidget {
  const EditTugas({super.key});
  @override
  State<EditTugas> createState() => _EditTugasState();
}

class _EditTugasState extends State<EditTugas> {
  final List<Task> tasks = [
    Task(title: "Belajar", description: "Belajar Ngoding", date: "Senin, 02/06/2025"),
    Task(title: "Laporan", description: "Projek Kelompok", date: "Selasa, 29/05/2025"),
  ];

  void _addTask() {
    // Tambah tugas nanti
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8EC5FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(task.description, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(task.date, style: const TextStyle(color: Colors.white)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text("Edit"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text("Hapus"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa0f1f1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Edit Tugas",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    ...tasks.map(_buildTaskCard),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _addTask,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7FFFD4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 40, color: Colors.blue),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlueAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
