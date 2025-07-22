// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoHomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const TodoHomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<StatefulWidget> createState() {
    return _TodoHomePageState();
  }
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<TodoItem> pendingTodos = [];
  List<TodoItem> completedTodos = [];
  int currentIndex = 0;
  
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  void loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pendingData = prefs.getString('pending_todos');
    String? completedData = prefs.getString('completed_todos');
    
    if (pendingData != null) {
      List<dynamic> pendingJson = json.decode(pendingData);
      pendingTodos = pendingJson.map((item) => TodoItem.fromMap(item)).toList();
    }
    
    if (completedData != null) {
      List<dynamic> completedJson = json.decode(completedData);
      completedTodos = completedJson.map((item) => TodoItem.fromMap(item)).toList();
    }
    
    setState(() {});
  }

  void saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String pendingJson = json.encode(pendingTodos.map((item) => item.toMap()).toList());
    String completedJson = json.encode(completedTodos.map((item) => item.toMap()).toList());
    
    await prefs.setString('pending_todos', pendingJson);
    await prefs.setString('completed_todos', completedJson);
  }

  void addTodo() {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        pendingTodos.add(TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: controller.text.trim(),
          createdAt: DateTime.now(),
        ));
        controller.clear();
      });
      saveTodos();
    }
  }

  void deleteTodo(String id, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        completedTodos.removeWhere((todo) => todo.id == id);
      } else {
        pendingTodos.removeWhere((todo) => todo.id == id);
      }
    });
    saveTodos();
  }

  void completeTodo(String id) {
    setState(() {
      TodoItem todo = pendingTodos.firstWhere((todo) => todo.id == id);
      todo.completedAt = DateTime.now();
      completedTodos.add(todo);
      pendingTodos.removeWhere((todo) => todo.id == id);
    });
    saveTodos();
  }

  void restoreTodo(String id) {
    setState(() {
      TodoItem todo = completedTodos.firstWhere((todo) => todo.id == id);
      todo.completedAt = null;
      pendingTodos.add(todo);
      completedTodos.removeWhere((todo) => todo.id == id);
    });
    saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0 ? "Todo List" : "Completed Tasks",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.check_circle,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Todo Manager",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Stay organized, stay productive",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.home_rounded,
                  color: currentIndex == 0 ? Colors.blue : Colors.grey[600],
                ),
                title: Text(
                  "Home",
                  style: TextStyle(
                    fontWeight: currentIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                    color: currentIndex == 0 ? Colors.blue : null,
                  ),
                ),
                selected: currentIndex == 0,
                onTap: () {
                  setState(() {
                    currentIndex = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.task_alt_rounded,
                  color: currentIndex == 1 ? Colors.blue : Colors.grey[600],
                ),
                title: Text(
                  "Completed (${completedTodos.length})",
                  style: TextStyle(
                    fontWeight: currentIndex == 1 ? FontWeight.w600 : FontWeight.normal,
                    color: currentIndex == 1 ? Colors.blue : null,
                  ),
                ),
                selected: currentIndex == 1,
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: currentIndex == 0 ? buildHomePage() : buildCompletedPage(),
    );
  }

  Widget buildHomePage() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "What needs to be done?",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => addTodo(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: addTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Add"),
              ),
            ],
          ),
        ),
        if (pendingTodos.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No tasks yet!",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add a task above to get started",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: pendingTodos.length,
              itemBuilder: (context, index) {
                final todo = pendingTodos[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        todo.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        "Created on ${_formatDateTime(todo.createdAt)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => completeTodo(todo.id),
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.green[600],
                            tooltip: "Mark as complete",
                          ),
                          IconButton(
                            onPressed: () => deleteTodo(todo.id, false),
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red[600],
                            tooltip: "Delete task",
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildCompletedPage() {
    return completedTodos.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "No completed tasks",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Completed tasks will appear here",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: completedTodos.length,
            itemBuilder: (context, index) {
              final todo = completedTodos[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                    ),
                    subtitle: Text(
                      "Completed on ${_formatDateTime(todo.completedAt!)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => restoreTodo(todo.id),
                          icon: const Icon(Icons.restore),
                          color: Colors.orange[600],
                          tooltip: "Restore task",
                        ),
                        IconButton(
                          onPressed: () => deleteTodo(todo.id, true),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red[600],
                          tooltip: "Delete task",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return "just now";
      }
      return "${difference.inHours}h ago";
    } else if (difference.inDays == 1) {
      return "yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    String timeString = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    
    if (difference.inDays == 0) {
      return "Today at $timeString";
    } else if (difference.inDays == 1) {
      return "Yesterday at $timeString";
    } else if (difference.inDays < 7) {
      List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return "${weekdays[date.weekday - 1]} at $timeString";
    } else {
      return "${date.day}/${date.month}/${date.year} at $timeString";
    }
  }
}

class TodoItem {
  final String id;
  final String title;
  final DateTime createdAt;
  DateTime? completedAt;

  TodoItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
    );
  }
}