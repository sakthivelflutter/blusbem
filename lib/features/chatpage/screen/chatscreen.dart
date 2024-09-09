import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:serialble/common/trucate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:serialble/features/History/screen/history_screen.dart';
import 'package:serialble/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;
  DateTime date;

  _Message(this.whom, this.text, this.date);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            // width: MediaQuery.sizeOf(context).width*0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(DateFormat("HH:mm:ss:SSS").format(_message.date)+"\n",style:GoogleFonts.courierPrime(color: Colors.grey.shade400,fontSize: 12),),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: Text(
                      (text) {
                        return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                      }(_message.text.trim()),
                      style: GoogleFonts.courierPrime(
                        color: _message.whom == clientID
                            ? Colors.yellow
                            : Colors.greenAccent,
                        fontSize: 13,
                      )),
                ),
              ],
            ),
            padding: EdgeInsets.all(1.0),
            // margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),

            decoration: BoxDecoration(
                // color:
                //     _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        // mainAxisAlignment: _message.whom == clientID
        //     ? MainAxisAlignment.end
        //     : MainAxisAlignment.start,
      );
    }).toList();

    final serverName = widget.server.name ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (dynamic result) async {
                if (result == 'Excel') {
                  List<List<dynamic>> data =
                      messages.map((message) => [message.text]).toList();
                  // var excelData =  parseCsv(data);
                  await exportToExcel(data.toString());
                }
                 if (result == 'clear') {
                messages.clear();
                setState(() {
                  
                });
                }
                if (result == 'history') {
               Navigator.push(context, MaterialPageRoute(builder: (context)=>HistoryScreen()));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Excel',
                  child: Text('Export Excel'),
                ),
                 const PopupMenuItem<String>(
                  value: 'history',
                  child: Text('History'),
                ),
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Clear'),
                ),
              ],
            ),
            
          ],
          title: (isConnecting
              ? Text(
                  'Connecting Chat to ' + serverName + '...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                )
              : isConnected
                  ? Text('Live Chat With ' + serverName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
                  : Text('Chat Log With ' + serverName,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)))),
      backgroundColor: Color(0xFF1D3646),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
              
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    padding: EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      style: TextStyle(
                          fontSize: 15.0, color: Colors.grey.shade300),
                      controller: textEditingController,
                      cursorColor: Color(0xFF95A4C2),
                      
                      decoration: InputDecoration(
                        suffixIcon: InkWell(onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (contest)=>HistoryScreen()));
                          
                        },
                        child: Icon(Icons.history,color: Colors.grey.shade300,),),
                        border: InputBorder.none,
                       
                        
                        hintText: isConnecting
                            ? 'Wait until connected...'
                            : isConnected
                                ? 'Type your message...'
                                : 'Chat got disconnected',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      
                      enabled: isConnected,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2D558D)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left:4.0),
                    child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.grey.shade200,size: 28,
                        ),
                        onPressed: isConnected
                            ? () => _sendMessage(textEditingController.text)
                            : null),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String cleanCsvData(String csvData) {
    return csvData.replaceAll(RegExp(r'[\[\]]'), '');
  }

  List<List<String>> parseCsv(String csvData) {
    List<List<String>> result = [];
    List<String> rows = csvData.split('\n');

    for (var row in rows) {
      if (row.isNotEmpty) {
        List<String> columns =
            row.split(',').map((field) => field.trim()).toList();
        result.add(columns);
      }
    }

    return result;
  }

  Future<void> exportToExcel(String data) async {
    try {
      String cleanedCsvData = cleanCsvData(data);
      List<List<String>> parsedData = parseCsv(cleanedCsvData);
      // Get the Downloads directory
     

      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];

      // Add rows to the sheet
      for (var row in parsedData) {
        sheet.appendRow(row);
      }
 final directory =
          Directory('/storage/emulated/0/Download'); // For Android
      String path = '${directory.path}/log_data.xlsx';
   int filecount =1;
      var file = File(path);
      while(await file.exists()){
        path= '${directory.path}/log_data_$filecount.xlsx';
        filecount++;
        file = File(path);
        print(filecount);
        

      }
      await file.writeAsBytes( excel.save()!);

      log('File saved at $path');
      Fluttertoast.showToast(
        msg: "Successfully ${path.split("/").last} Downloaded",
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "e");
      print('Error saving file: $e');
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
              1,
              backspacesCounter > 0
                  ? _messageBuffer.substring(
                      0, _messageBuffer.length - backspacesCounter)
                  : _messageBuffer + dataString.substring(0, index),
              DateTime.now()),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    List listtext=GetStorage().read("history")??[];
    listtext.add(text);
   listtext= listtext.toSet().toList();
    GetStorage().write("history", listtext);



    
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text, DateTime.now()));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
