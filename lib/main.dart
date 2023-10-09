import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comments App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CommentsPage(),
    );
  }
}

class Comment {
  final int id;
  final String name;
  final String email;
  final String body;

  Comment({required this.id, required this.name, required this.email, required this.body});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}

class CommentsPage extends StatefulWidget {
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  Future<List<Comment>> fetchComments() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: FutureBuilder<List<Comment>>(
        future: fetchComments(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                
                return Card (child: ListTile(
                  leading: CircleAvatar( child: Text(snapshot.data![index].id.toString()),
                    backgroundColor: Colors.blue,
                  ),
                  title: Text(snapshot.data![index].name),
                  onTap: () {
                    showModalBottomSheet(
                      
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      context: context,
                      builder: (context) => Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${snapshot.data![index].name}'),
                            Text('Email: ${snapshot.data![index].email}'),
                            Text('Body: ${snapshot.data![index].body}'),
                          ],
                        ),
                      ),
                    );
                  },
                ));
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load comments'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
