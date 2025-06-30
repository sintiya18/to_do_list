import 'package:flutter/material.dart';

void main() {
  runApp(const EditTaskApp());
}

class EditTaskApp extends StatelessWidget {
  const EditTaskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Tugas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TambahTugas(), 
      debugShowCheckedModeBanner: false,
    );
  }
}

class TambahTugas extends StatefulWidget {
  const TambahTugas({Key? key}) : super(key: key);

  @override
  State<TambahTugas> createState() => _TambahTugas();
}

class _TambahTugas extends State<TambahTugas> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  DateTime? selectedDate;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _deadlineController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _deadlineController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9CECFB), Color(0xFF90F7EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Edit Tugas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Judul Tugas', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _judulController,
                          decoration: _inputDecoration(),
                        ),
                        const SizedBox(height: 16),
                        const Text('Deskripsi', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _deskripsiController,
                          decoration: _inputDecoration(),
                        ),
                        const SizedBox(height: 16),
                        const Text('Deadline', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _deadlineController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: _inputDecoration(
                            icon: const Icon(Icons.calendar_today_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Status', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _statusController,
                          maxLines: 3,
                          decoration: _inputDecoration(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Data disimpan')),
                                    );
                                  }
                                },
                                style: _buttonStyle(Colors.lightBlueAccent),
                                child: const Text('Simpan'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _formKey.currentState!.reset();
                                  _judulController.clear();
                                  _deskripsiController.clear();
                                  _deadlineController.clear();
                                  _statusController.clear();
                                  setState(() {
                                    selectedDate = null;
                                  });
                                },
                                style: _buttonStyle(Colors.red),
                                child: const Text('Batal'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlueAccent,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({Icon? icon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      suffixIcon: icon,
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}
