import 'package:flutter/material.dart';

class DoubleActionButton extends StatefulWidget {
  final Function leftclicked;
  final Function rightclicked;
  const DoubleActionButton({super.key,required this.leftclicked,required this.rightclicked});

  @override
  State<DoubleActionButton> createState() => _DoubleActionButtonState();
}

class _DoubleActionButtonState extends State<DoubleActionButton> {
  Color? background;
  @override
  Widget build(BuildContext context) {
    background = Theme.of(context).colorScheme.onInverseSurface;
    return Row(
      children: [
        SizedBox(
            width: 48,
            child: RawMaterialButton(
              fillColor: background,
              onPressed: () {
                widget.leftclicked();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24))),
              child: Icon(Icons.power_settings_new),
            )),
        SizedBox(
            width: 48,
            child: RawMaterialButton(
              fillColor: background,
              onPressed: () {
                widget.rightclicked();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24))),
              child: Icon(Icons.menu),
            ))
      ],
    );
  }
}

class BigDoubleActionButton extends StatefulWidget {
  final Function leftclicked;
  final Function rightclicked;
  const BigDoubleActionButton({super.key,required this.leftclicked,required this.rightclicked});

  @override
  State<BigDoubleActionButton> createState() => _BigDoubleActionButtonState();
}

class _BigDoubleActionButtonState extends State<BigDoubleActionButton> {
  Color? background;
  double cheight = 100;
  double cwidgth = 100;
  @override
  Widget build(BuildContext context) {
    background = Theme.of(context).colorScheme.onInverseSurface;
    return Row(
      children: [
        SizedBox(
            width: cwidgth,
            height: cwidgth,
            child: RawMaterialButton(
              fillColor: background,
              onPressed: (){widget.leftclicked();},
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24))),
              child: Icon(Icons.arrow_left),
            )),
        SizedBox(
            width: cwidgth,
            height: cwidgth,
            child: RawMaterialButton(
              fillColor: background,
              onPressed: (){widget.rightclicked();},
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24))),
              child: Icon(Icons.arrow_right),
            ))
      ],
    );
  }
}
