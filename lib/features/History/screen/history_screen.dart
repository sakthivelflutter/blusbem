import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List history=[];
  @override
  void initState() {
history=GetStorage().read("history")??[];

    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: Column(children: [
        ListView.builder(
          itemCount: history.length,
          shrinkWrap: true,
          itemBuilder: (Context,intdex){
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: null,
                child: Row(
                 
                
                  children: [
                    Icon(Icons.history),
                    SizedBox(
                      width: 10,
                    ),
                  
                    Expanded(
                      child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(history[intdex]),
                       IconButton(onPressed:(){
 Clipboard.setData(ClipboardData(text:history[intdex]));
 Fluttertoast.showToast(msg: history[intdex]);
                       },icon: Icon(Icons.copy,)),],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        })
      ]),
    );
  }
}