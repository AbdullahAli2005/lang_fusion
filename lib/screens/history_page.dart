import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, String>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedHistory = prefs.getStringList('translation_history');
      setState(() {
        history = savedHistory != null
            ? savedHistory
                .map((e) => Map<String, String>.from(Uri.splitQueryString(e)))
                .toList()
            : [];
      });
    } catch (e) {
      print("Error loading history: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> removeFromHistory(int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        history.removeAt(index); // Remove the item from the list
      });

      List<String> updatedHistory =
          history.map((e) => Uri(queryParameters: e).query).toList();
      await prefs.setStringList('translation_history', updatedHistory);
    } catch (e) {
      print("Error removing history: $e");
    }
  }

  Future<void> clearHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('translation_history');
      setState(() {
        history.clear();
      });
    } catch (e) {
      print("Error clearing history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Translation History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white,),
            onPressed: () async {
              bool shouldClear = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Clear All'),
                    content: const Text(
                        'Are you sure you want to clear the entire history?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  );
                },
              );

              if (shouldClear == true) {
                await clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All history cleared successfully.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : history.isEmpty
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple,Colors.purple , Colors.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'No history found!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple,Colors.purple , Colors.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return Slidable(
                        key: ValueKey(entry['input']),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                await removeFromHistory(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Deleted "${entry['input']}" from history.',
                                    ),
                                    backgroundColor:  Colors.redAccent,
                                  ),
                                );
                              },
                              backgroundColor: const Color.fromARGB(255, 78, 27, 166),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          color: const Color.fromARGB(255, 238, 244, 255),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(
                              'Input: ${entry['input']}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Output: ${entry['output']} \nFrom: ${entry['from']} To: ${entry['to']}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
