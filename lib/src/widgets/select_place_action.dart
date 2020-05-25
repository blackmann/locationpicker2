import 'package:flutter/material.dart';

class SelectPlaceAction extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;

  SelectPlaceAction(
      {@required this.title, @required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: !isLoading ? onTap : () {},
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: TextStyle(fontSize: 16)),
                    Text("Tap to select this location",
                        style: TextStyle(color: Colors.grey, fontSize: 15)),
                  ],
                ),
              ),
              isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  : Icon(Icons.arrow_forward)
            ],
          ),
        ),
      ),
    );
  }
}
