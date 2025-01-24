import 'dart:async'; // For Timer
import 'package:flutter/material.dart';

class RunningBannerWidget extends StatefulWidget {
  const RunningBannerWidget({super.key});

  @override
  _RunningBannerWidgetState createState() => _RunningBannerWidgetState();
}

class _RunningBannerWidgetState extends State<RunningBannerWidget> {
  final List<String> imageUrls = [
    'https://storage.googleapis.com/citizencare_ev/shared%20image.jpg',
    'https://waterdrop123.s3.ap-south-1.amazonaws.com/Slider+Images/Alkaline+card.jpg',

  ];

  late PageController _pageController; // To control PageView
  int _currentPage = 0; // Current page index
  Timer? _timer; // For auto-scroll

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    // Set up the timer for auto-scrolling
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < imageUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first image
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to avoid memory leaks
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Fixed height for the banner
      child: PageView.builder(
        controller: _pageController,
        itemCount: imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12), // Rounded corners
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 50, color: Colors.red),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}