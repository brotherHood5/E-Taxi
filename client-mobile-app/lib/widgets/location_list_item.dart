import 'package:flutter/material.dart';

import '../constants.dart';

class LocationListItem extends StatefulWidget {
  const LocationListItem(
      {super.key,
      required this.onTap,
      required this.title,
      required this.subtitle});
  final VoidCallback onTap;
  final String title;
  final String subtitle;

  @override
  State<LocationListItem> createState() => _LocationListItemState();
}

class _LocationListItemState extends State<LocationListItem> {
  bool isPressed = false;

  void onPressed() {
    setState(() {
      isPressed = true;
    });
  }

  void onReleased() {
    setState(() {
      isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      onTapCancel: () => onReleased(),
      child: Container(
        color: isPressed ? Colors.grey.withOpacity(.1) : Colors.transparent,
        padding:
            const EdgeInsets.symmetric(horizontal: layoutMedium, vertical: 4.0),
        child: ListTile(
          leading: Container(
              margin: const EdgeInsets.only(top: 4.0),
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
              )),
          trailing: Icon(
            Icons.arrow_forward,
            color: Colors.black.withOpacity(.6),
            size: 16,
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          subtitle: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                Text(widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
