import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chart_screen.dart';
import 'services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String aiResponse = "";
  bool isLoadingAI = false;

  void getAIAdvice(double balance) async {
    setState(() {
      isLoadingAI = true;
      aiResponse = "";
    });

    try {
      String response = await GeminiService.getAdvice(
        "User balance is ₹$balance. Give one smart financial tip in one line.",
      );

      setState(() {
        aiResponse = response;
      });
    } catch (e) {
      print("AI ERROR: $e");
      setState(() {
        aiResponse = "⚠️ Unable to fetch AI advice. Try again.";
      });
    }

    setState(() {
      isLoadingAI = false;
    });
  }

  Future<void> saveToFirebase(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection("expenses").add({
      "name": data["name"],
      "amount": data["amount"],
      "type": data["type"],
      "category": data["category"],
      "date": data["date"],
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteExpense(String id) async {
    await FirebaseFirestore.instance
        .collection("expenses")
        .doc(id)
        .delete();
  }

  double getBalance(List<QueryDocumentSnapshot> docs) {
    double balance = 0;
    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data["type"] == "income") {
        balance += (data["amount"] as num).toDouble();
      } else {
        balance -= (data["amount"] as num).toDouble();
      }
    }
    return balance;
  }

  Future<void> goToAddScreen() async {
    final result = await Navigator.pushNamed(context, "/add");
    if (result != null) {
      await saveToFirebase(result as Map<String, dynamic>);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BizTrack",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChartScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              themeNotifier.value == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeNotifier.value =
              themeNotifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: goToAddScreen,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;
          double balance = getBalance(docs);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5B86E5),
                      Color(0xFFB06AB3),
                      Color(0xFFFF7E5F),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Balance",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(
                      "₹${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => getAIAdvice(balance),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text("Get AI Insight"),
                ),
              ),

              const SizedBox(height: 10),

              if (isLoadingAI)
                const Center(child: CircularProgressIndicator())
              else if (aiResponse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(aiResponse),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Recent Transactions",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 10),


              Expanded(
                child: docs.isEmpty
                    ? const Center(child: Text("No expenses added yet"))
                    : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    var data =
                    docs[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.attach_money),
                        ),
                        title: Text(data["name"]),
                        subtitle: Text(
                            "${data["category"]} • ${data["date"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${data["type"] == "income" ? "+" : "-"}₹${data["amount"]}",
                              style: TextStyle(
                                color: data["type"] == "income"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () {
                                deleteExpense(docs[index].id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}