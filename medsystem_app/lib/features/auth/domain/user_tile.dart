import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[400], 
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 20), 
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            //Icon
            const Icon(Icons.person),

            const SizedBox(width: 20),
            //Text
            Text(text)
          ],
        ),
      ),
    );
  }
}
