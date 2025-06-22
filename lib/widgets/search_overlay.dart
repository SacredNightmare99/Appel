import 'package:flutter/material.dart';

class CustomSearchOverlay extends StatelessWidget {
  final OverlayEntry overlayEntry;
  final LayerLink layerLink;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final void Function(String)? onChanged;
  final String hintText;

  const CustomSearchOverlay({
    super.key, 
    required this.overlayEntry, 
    required this.layerLink, 
    required this.searchController, 
    required this.searchFocus, 
    required this.onChanged,
    required this.hintText
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => overlayEntry.remove(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.transparent
              ),
            ),
            CompositedTransformFollower(
              link: layerLink,
              offset: Offset(5, -10),
              showWhenUnlinked: false,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.only(left: 5, top: 2, bottom: 2),
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocus,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                    ),
                    autofocus: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}