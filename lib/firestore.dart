import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreWidget extends StatefulWidget {
  @override
  _FirestoreWidgetState createState() => _FirestoreWidgetState();
}

class _FirestoreWidgetState extends State<FirestoreWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Firestore'),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _buildBody(context),
      // ),
      // body: Container(
      //   child: RaisedButton(
      //     onPressed: () => _buildBody(context),
      //   ),
      // ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
   return StreamBuilder<QuerySnapshot>(
    //  stream: Firestore.instance.collection('Medicine').where("id", isEqualTo: "4710836340046").snapshots(),
     stream: Firestore.instance.collection('Medicine').snapshots(),
     builder: (context, snapshot) {
       if (!snapshot.hasData) return LinearProgressIndicator();

       return _buildList(context, snapshot.data.documents);
     },
   );
 }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
   return ListView(
     padding: const EdgeInsets.only(top: 20.0),
     children: snapshot.map((data) => _buildListItem(context, data)).toList(),
   );
 }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
   final record = Record.fromSnapshot(data);

   return Padding(
     key: ValueKey(record.name),
     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
     child: Container(
       decoration: BoxDecoration(
         border: Border.all(color: Colors.grey),
         borderRadius: BorderRadius.circular(5.0),
       ),
       child: ListTile(
         title: Text(record.name),
        //  trailing: Text(record.votes.toString()),
         trailing: Text(record.id),
       ),
     ),
   );
 }

}

class Record {
 final String name;
 final String id;
 final DocumentReference reference;

 Record.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['name'] != null),
       assert(map['id'] != null),
       name = map['name'],
       id = map['id'];

 Record.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

//  @override
//  String toString() => "Record<$name:$votes>";
}