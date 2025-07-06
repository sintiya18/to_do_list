import 'package:flutter/material.dart';
import 'notification_service.dart';

class EditTugasScreen extends StatefulWidget {
  final Map<String, String> task;

  const EditTugasScreen({super.key, required this.task});

  @override
  State<EditTugasScreen> createState() => _EditTugasScreenState();
}

class _EditTugasScreenState extends State<EditTugasScreen> {
  late TextEditingController judulController;
  late TextEditingController tanggalController;
  String status = 'Belum Dikerjakan';

  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    judulController = TextEditingController(text: widget.task['title']);
    tanggalController = TextEditingController(text: widget.task['date']);

  
    try {
      selectedDateTime = DateTime.parse(_toIsoFormat(widget.task['date']!));
    } catch (_) {
      selectedDateTime = DateTime.now();
    }

    status = widget.task['status']!;
  }

  String _toIsoFormat(String date) {
    final parts = date.split(' ');
    final d = parts[0].split('/');
    final t = parts.length > 1 ? parts[1] : '00:00';
    return '${d[2]}-${d[1]}-${d[0]}T$t';
  }

  Future<void> _selectDateTime() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? now),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          tanggalController.text =
              "${selectedDateTime!.day.toString().padLeft(2, '0')}/"
              "${selectedDateTime!.month.toString().padLeft(2, '0')}/"
              "${selectedDateTime!.year} "
              "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
        });
      }
    }
  }

  @override
  void dispose() {
    judulController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB2FEFA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Edit Tugas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: judulController,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tanggalController,
                      readOnly: true,
                      onTap: _selectDateTime,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal & Jam',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      items: const [
                        DropdownMenuItem(value: 'Belum Dikerjakan', child: Text('Belum Dikerjakan')),
                        DropdownMenuItem(value: 'Sudah Dikerjakan', child: Text('Sudah Dikerjakan')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            status = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedDateTime != null) {
                                await NotificationService().scheduleNotification(
                                  id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                                  title: 'Pengingat Tugas',
                                  body: 'Kerjakan: ${judulController.text}',
                                  scheduledDateTime: selectedDateTime!,
                                );
                              }

                              Navigator.pop(context, {
                                'title': judulController.text,
                                'date': tanggalController.text,
                                'status': status,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 25, 205, 255),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, null);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
