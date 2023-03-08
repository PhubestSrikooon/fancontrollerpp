import 'package:flutter/material.dart';

class CSBtn1 extends StatefulWidget {
  final clicked;
  final isconnect;
  final name;
  const CSBtn1({super.key,required this.clicked,required this.isconnect,this.name});

  @override
  State<CSBtn1> createState() => _CSBtn1State();
}

class _CSBtn1State extends State<CSBtn1> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.all(16),
        fillColor: Theme.of(context).colorScheme.onInverseSurface,
        onPressed: widget.clicked,
        child: Row(
          children: [
            Expanded(
              child: Icon(Icons.bluetooth),
              flex: 1,
            ),
            Expanded(
              flex: 4,
              child: (Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: double.infinity,
                      child: Text(
                        widget.isconnect ? "Connected": "Not connected",
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.left,
                      )),
                  SizedBox(
                      width: double.infinity,
                      child: Text(
                        widget.isconnect ? "${widget.name}": "Click to connect to device",
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.left,
                      ))
                ],
              )),
            )
          ],
        ),
      ),
    );
  }
}
