import 'package:flutter/material.dart';

import '../../constants.dart';

class SkeletonLocationListItem extends StatelessWidget {
  const SkeletonLocationListItem({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: layoutMedium, vertical: 4.0),
      child: ListTile(
        leading: Container(
          margin: const EdgeInsets.only(top: 4.0),
          height: 32,
          width: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(.4),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward,
          color: Colors.black.withOpacity(.6),
          size: 16,
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Container(
                height: 15,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.withOpacity(.5),
                ),
              ),
            ],
          ),
        ),
        subtitle: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            children: [
              Container(
                height: 10,
                width: MediaQuery.of(context).size.width / 1.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.withOpacity(.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
