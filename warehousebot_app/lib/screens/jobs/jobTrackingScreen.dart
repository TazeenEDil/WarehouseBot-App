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
  List allJobs = [];
  bool showPendingExpanded = true;

  fetchJobs() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.getJobs(token: token);

      if (mounted) {
        setState(() {
          allJobs = res["data"] ?? [];
          loading = false;
        });

        print("📦 Jobs fetched: ${allJobs.length}");
      }
    } catch (e) {
      print("❌ Jobs fetch error: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  // Filter jobs by status
  List get pendingJobs => allJobs
      .where((j) =>
          j["status"]?.toString().toLowerCase() == "pending" ||
          j["status"]?.toString().toLowerCase() == "queued")
      .toList();

  List get inProgressJobs => allJobs
      .where((j) => j["status"]?.toString().toLowerCase() == "in_progress")
      .toList();

  List get completedJobs => allJobs
      .where((j) => j["status"]?.toString().toLowerCase() == "completed")
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Job Tracking & Dispatch",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await fetchJobs();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pending Jobs Dropdown
                      _pendingJobsDropdown(),
                      const SizedBox(height: 24),

                      // Job Progress Section
                      const Text(
                        "Job Progress",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // In Progress Jobs
                      if (inProgressJobs.isEmpty)
                        _emptyState("No jobs in progress")
                      else
                        ..._buildProgressJobs(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ------------------ PENDING JOBS DROPDOWN ------------------
  Widget _pendingJobsDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                showPendingExpanded = !showPendingExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pending Jobs",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    showPendingExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          if (showPendingExpanded) ...[
            const Divider(color: Colors.white10, height: 1),
            if (pendingJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "No pending jobs",
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ...pendingJobs.map((job) => _pendingJobItem(job)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _pendingJobItem(Map job) {
    String jobId = job["_id"]?.toString().substring(
              job["_id"].toString().length - 6,
            ) ??
        "N/A";
    String robot = job["assignedRobot"]?.toString() ?? "Unassigned";
    String status = job["status"]?.toString() ?? "Unknown";
    List items = job["items"] ?? [];
    String itemsDesc = items.isNotEmpty
        ? items.map((i) => "${i['name']} x${i['quantity']}").join(", ")
        : "No items";

    // Extract step info if available
    String stepInfo = "";
    if (items.isNotEmpty && items[0]['name'] != null) {
      stepInfo = "Pick n Place - Step 1/3";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Job #$jobId",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "- $stepInfo - ${_formatStatus(status)}",
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Robot: $robot | Items: $itemsDesc",
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ IN PROGRESS JOBS ------------------
  List<Widget> _buildProgressJobs() {
    return inProgressJobs.map((job) => _progressJobCard(job)).toList();
  }

  Widget _progressJobCard(Map job) {
    String jobId = job["_id"]?.toString().substring(
              job["_id"].toString().length - 6,
            ) ??
        "N/A";
    int progress = job["completionPercentage"] ?? 0;
    String robot = job["assignedRobot"]?.toString() ?? "Unassigned";
    List items = job["items"] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Job #$jobId",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$progress% Complete",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // Job Details
          _jobDetailRow(Icons.precision_manufacturing, "Robot", robot),
          const SizedBox(height: 8),
          _jobDetailRow(
            Icons.inventory_2,
            "Items",
            items.isNotEmpty
                ? items.map((i) => "${i['name']} x${i['quantity']}").join(", ")
                : "No items",
          ),
        ],
      ),
    );
  }

  Widget _jobDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ------------------ EMPTY STATE ------------------
  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ HELPERS ------------------
  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return "Queued";
      case "in_progress":
        return "In Progress";
      case "completed":
        return "Completed";
      default:
        return status;
    }
  }
}