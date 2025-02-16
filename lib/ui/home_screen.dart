import 'package:flutter/material.dart';
import 'package:schedule_generator_app/services/openai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  String? priority;
  bool isLoading = false;
  String scheduleResult = "";
  final OpenAIService openAIService = OpenAIService(apiKey: "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");

  void _addTask() {
    if (taskController.text.isNotEmpty &&
        priority != null &&
        durationController.text.isNotEmpty &&
        deadlineController.text.isNotEmpty) {
      setState(() {
        tasks.add({
          "name": taskController.text,
          "priority": priority!,
          "duration": int.tryParse(durationController.text) ?? 30,
          "deadline": deadlineController.text,
        });
      });
      taskController.clear();
      durationController.clear();
      deadlineController.clear();
      priority = null;
    }
  }

  Future<void> _generateSchedule() async {
    setState(() => isLoading = true);
    try {
      String schedule = await openAIService.generateSchedule(tasks);
      setState(() => scheduleResult = schedule);
    } catch (e) {
      setState(() => scheduleResult = "Error: ${e.toString()}");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Generator")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(labelText: "Nama Tugas"),
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: "Durasi (menit)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(labelText: "Deadline"),
            ),
            DropdownButton<String>(
              value: priority,
              hint: const Text("Pilih Prioritas"),
              onChanged: (value) => setState(() => priority = value),
              items: const [
                "Tinggi",
                "Sedang",
                "Rendah"
              ].map((priorityMember) => DropdownMenuItem(
                value: priorityMember,
                child: Text(priorityMember),
              )).toList(),
            ),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text("Tambahkan Tugas"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text("${task['name']}"),
                    subtitle: Text(
                        "Prioritas: ${task['priority']} | Durasi: ${task['duration']} menit | Deadline: ${task['deadline']}"),
                  );
                },
              ),
            ),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _generateSchedule,
                    child: const Text("Generate Schedule"),
                  ),
            const SizedBox(height: 20),
            scheduleResult.isNotEmpty
                ? Text(
                    scheduleResult,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}