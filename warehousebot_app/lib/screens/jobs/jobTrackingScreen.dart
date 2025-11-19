import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';

class JobTrackingScreen extends StatefulWidget {
  const JobTrackingScreen({super.key});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  bool loading = true;
  List pendingJobs = [];
  List inProgressJobs = [];
  List completedJobs = [];

  fetchJobs() async {
    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.get("/get-jobs", token);

      List all = res["jobs"] ?? [];

      if (mounted) {
        setState(() {
          pendingJobs = all.where((j) => j["Status"] == "Pending").toList();
          inProgressJobs = all.where((j) => j["Status"] == "In Progress").toList();
          completedJobs = all.where((j) => j["Status"] == "Completed").toList();
          loading = false;
        });
      }
    } catch (e) {
      print("Jobs fetch error: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  /*dispatchJob(Map<String, dynamic> jobData) async {
  
  try {
    final token = await TokenStorage.getToken() ?? "";
  await ApiClient.post("/warehouse/create-job", Map<String, dynamic>.from(jobData), token: token);


      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job created successfully!")),
      );
      
      fetchJobs();
    } catch (e) {
      print("Dispatch job error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create job")),
      );
    }
  
  }*/
  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    _sectionTitle("Pending Jobs"),
                    _jobList(pendingJobs, Colors.orangeAccent),
                    const SizedBox(height: 20),
                    _sectionTitle("In Progress"),
                    _jobList(inProgressJobs, Colors.blueAccent, showProgress: true),
                    const SizedBox(height: 20),
                    _sectionTitle("Completed"),
                    _jobList(completedJobs, Colors.greenAccent),
                    const SizedBox(height: 30),
                    _dispatchButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF3A76F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Job Tracking",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Dispatch and monitor task flow",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String name) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _jobList(List list, Color color, {bool showProgress = false}) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "No jobs in this category.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _jobCard(list[index], color, showProgress);
      },
    );
  }

  Widget _jobCard(job, Color color, bool showProgress) {
    int currentStep = job["CompletionPercentage"] ?? 0;
    double progress = currentStep / 100;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Job #${job["JobID"] ?? "----"}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              _statusChip(job["Status"] ?? "Unknown", color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Type: ${job["JobType"] ?? "N/A"}",
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            "Robot: ${job["RobotID"] ?? "Unassigned"}",
            style: const TextStyle(color: Colors.white38),
          ),
          Text(
            "Order: ${job["OrderID"] ?? "N/A"}",
            style: const TextStyle(color: Colors.white38),
          ),
          const SizedBox(height: 12),
          if (showProgress)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Progress: $currentStep%",
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
        color: color.withOpacity(0.12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _dispatchButton() {
    return ElevatedButton(
      onPressed: () {
        _showDispatchDialog();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Text(
        "Dispatch New Job",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  void _showDispatchDialog() {
    final jobTypeController = TextEditingController();
    final orderIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Create New Job", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jobTypeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Job Type (e.g., Pick, Place, Transport)",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: orderIdController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Order ID",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          /*ElevatedButton(
            onPressed: () {
              dispatchJob({
                "JobType": jobTypeController.text,
                "OrderID": orderIdController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),*/
        ],
      ),
    );
  }
}