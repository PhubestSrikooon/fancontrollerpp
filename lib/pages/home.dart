import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:fanctrlapp/component/doublebutton.dart';
import 'package:fanctrlapp/component/bigbutton.dart';

import 'package:fanctrlapp/pages/connect_devices.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textEditingController = TextEditingController();
  BluetoothConnection? currentConnectionMac = null;
  Timer? clickTimeout;

  String? devicesname = null;
  bool isDeviceOn = false;
  bool direction = false; // false = left , true = right
  int turingDeg = 0; // < 0 right , > 0 left
  List<_Message> messages = [];
  String _messageBuffer = '';

  bool isConnected() {
    return currentConnectionMac != null && currentConnectionMac!.isConnected;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    currentConnectionMac?.dispose();
    super.dispose();
  }

  void disconnectToDevice() async {
    if (currentConnectionMac != null) {
      if (currentConnectionMac!.isConnected) {
        setState(() {
          currentConnectionMac?.close();
          devicesname = null;
        });
      }
    }
  }

  void resetTimer(Function doAfterTimerout) {
    clickTimeout?.cancel();
    clickTimeout = Timer(Duration(seconds: 1), () {
      doAfterTimerout();
      setState(() {
        turingDeg = 0;
      });
    });
  }

  void degIncreese(Function doAfterTimerout, int adddeg) {
    resetTimer(doAfterTimerout);
    setState(() {
      turingDeg = turingDeg + adddeg;
      direction = turingDeg > 0 ? false : true;
    });
  }

  Future<void> connectToDevice(
      BuildContext context, String macAddress, String devicesName) async {
    if (macAddress == null) return;
    BluetoothConnection.toAddress(macAddress).then((_connection) {
      debugPrint("Connected to ${macAddress}");
      setState(() {
        currentConnectionMac = _connection;
        devicesname = devicesName;
      });
      currentConnectionMac!.input?.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((err) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(
                "An error occure. Please try again, If not success please report this bug to the developer"),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Stack trace'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(title: const Text('Stack Trace')),
                        body: Center(
                          child: Text(err.toString()),
                        ),
                      );
                    },
                  ));
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
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
        // backspacesCounter > 0
        //         ? _messageBuffer.substring(
        //             0, _messageBuffer.length - backspacesCounter)
        //         : _messageBuffer + dataString.substring(0, index);
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
    if (!isConnected()) {
          ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('No devices connected. Please try again later.')));
      return;
    }
    text = text.trim();
    debugPrint(text);
    if (text.length > 0) {
      try {
        // Convert the text to a List of UTF-8 encoded bytes
        List<int> bytes = utf8.encode(text + "\r\n");
        // Convert the List to a Uint8List
        Uint8List data = Uint8List.fromList(bytes);
        // Write the data to the output stream
        currentConnectionMac!.output.add(data);
        // Wait for all data to be sent
        debugPrint(data.toString());
        await currentConnectionMac!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fan Controller")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          CSBtn1(
            clicked: () {
              if (currentConnectionMac != null) {
                if (!currentConnectionMac!.isConnected) {
                  setState(() {
                    _openSelectDevices(context);
                  });
                } else {
                  disconnectToDevice();
                }
              } else {
                _openSelectDevices(context);
              }
            },
            isconnect: currentConnectionMac != null
                ? currentConnectionMac!.isConnected
                : false,
            name: devicesname,
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(turingDeg != 0
                  ? direction
                      ? "Turning right ${turingDeg.abs()} deg"
                      : "Turning left ${turingDeg.abs()} deg"
                  : ""),
              Padding(padding: EdgeInsets.all(8)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                BigDoubleActionButton(
                  leftclicked: () {
                    degIncreese(() {
                      _sendMessage("ROTATE,${turingDeg.abs()},0");
                    }, 5);
                  },
                  rightclicked: () {
                    degIncreese(() {
                      _sendMessage("ROTATE,${turingDeg.abs()},1");
                    }, -5);
                  },
                )
              ]),
              Padding(padding: EdgeInsets.all(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Enter Value")),
                  ),
                  RawMaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(24),
                              bottomRight: Radius.circular(24))),
                      fillColor: Theme.of(context).colorScheme.onInverseSurface,
                      onPressed: () {
                        int degtorotate = int.parse(textEditingController.text);
                        String text2send =
                            "ROTATE,${degtorotate.abs()},${degtorotate > 0 ? 1 : 0}";
                        _sendMessage(text2send);
                        debugPrint(text2send);
                      },
                      child: Text("OK"))
                ],
              )
            ],
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DoubleActionButton(
                leftclicked: () {
                  setState(() {
                    isDeviceOn = !isDeviceOn;
                  });
                  if (isDeviceOn) {
                    _sendMessage("CLOSE");
                  } else {
                    _sendMessage("OPEN");
                  }
                },
                rightclicked: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          children: [
                            ListTile(
                                title: Text("Setting"),
                                onTap: () {
                                  TimePickerDialog(initialTime: TimeOfDay.now(),);
                                },
                                leading: Icon(Icons.settings),
                                subtitle: Text("Change configuration of the app ")),
                                
                            ListTile(
                                title: Text("About"),
                                onTap: () {},
                                leading: Icon(Icons.info),
                                subtitle: Text("About developer and all changelog")),
                          ],
                        );
                      });
                },
              )
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> _openSelectDevices(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SelectDevicesPage(),
      ),
    );
    if (!mounted) return;
    if (result == null) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Connecting to ${result[0]}')));
    connectToDevice(context, result[0], result[1]);
  }
}
