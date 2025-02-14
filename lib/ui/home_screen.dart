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
  String? priority;  
  bool isLoading = false;
  String scheduleResult = "";
  void _addTask() {
    if(taskController.text.isNotEmpty && priority != null && durationController.text.isNotEmpty) {
      setState(() {
        tasks.add({
          "name" : taskController.text,
          "priority" : priority!,
          "duration" : int.tryParse(durationController.text) ?? 30,
          "dateline" : "Tidak ada"
        });
      });
      taskController.clear();
      durationController.clear();
      priority = null;
    } 
  }

  Future<void> _generateSchedule() async {
    setState(() => isLoading = true);
    try {
      String schedule = await OpenAIService.generateSchedule(tasks);
      setState(() => scheduleResult = schedule );
    } catch (e) {
      setState(() => scheduleResult = "Failed to generate schedule");
    }
    setState(() => isLoading = false);
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}