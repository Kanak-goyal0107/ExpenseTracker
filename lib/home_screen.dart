import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<void> saveToFirebase(Map<String, dynamic> data) async {
    print("Saving to Firebase: $data");
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
    print("RESULT: $result");
    if (result != null) {
      await saveToFirebase(result as Map<String, dynamic>);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BizTrack"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToAddScreen,
        child: const Icon(Icons.add),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/img.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('expenses')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var docs = snapshot.data!.docs;

            return Column(
              children: [
                const SizedBox(height: 40),

                Text(
                  "Current Balance: ₹${getBalance(docs).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: docs.isEmpty
                      ? const Center(
                    child: Text(
                      "No expenses added yet",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {

                      var data =
                      docs[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: const Icon(Icons.money),
                          title: Text(data["name"]),
                          subtitle: Text(
                              "${data["category"]} : ${data["date"]}"),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹${data["type"] == "income" ? "+" : "-"} ${data["amount"]}",
                                style: TextStyle(
                                  color: data["type"] == "income"
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
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
      ),
    );
  }
}