import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  const CircularImage({
    super.key,
    this.url,
    this.size,
  });

  final String? url;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double defaultSize = 70;
    final resolvedSize = size ?? defaultSize;
    return CircleAvatar(
      maxRadius: resolvedSize, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CachedNetworkImage(
          imageUrl: url ?? "",
          errorWidget:(context, url, error) => Icon(Icons.person, size: resolvedSize,),
        ),
      ),
    );
  }
}
