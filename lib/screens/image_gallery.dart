import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixbay_gallery/consts/colors.dart';
import 'package:pixbay_gallery/consts/fonts.dart';

/// The main entry point of the application.

/// A screen widget that displays a gallery of images
/// fetched from the Pixabay API.
class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  static const String apiKey = '46154070-594cd3358b7c491ae2dec2328';

  // ScrollController to detect when the user scrolls to the bottom.
  final ScrollController _scrollController = ScrollController();

  // List to store fetched image data from Pixabay API.
  List<dynamic> _images = [];

  // Page number to load data from the API.
  int _page = 1;

  // Flag to determine if the application is currently loading data.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initial fetch of images when the screen is first loaded.
    _fetchImages();

    // Add a listener to the ScrollController to detect when
    // the user has scrolled to the bottom of the list.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchImages();
      }
    });
  }

  /// Fetches images from the Pixabay API using the current page number.
  /// The fetched images are added to the `_images` list, and the page number is incremented.
  Future<void> _fetchImages() async {
    // Avoid fetching new data if a request is already in progress.
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Pixabay API URL to fetch images.
    final url =
        'https://pixabay.com/api/?key=$apiKey&image_type=photo&per_page=20&page=$_page';

    try {
      // Fetching the images from the API.
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update the state with the newly fetched images.
        setState(() {
          _images.addAll(data['hits']);
          _page++; // Increment page for the next batch of images.
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      // Handle exceptions here (e.g., network issues).
      print('Error fetching images: $e');
    } finally {
      setState(() {
        _isLoading = false; // Reset the loading flag.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Image Gallery',
          style: TextStyle(
              color: AppColors.textColor, fontFamily: AppFonts.primaryFont),
        ),
      ),
      body: _buildImageGrid(),
    );
  }

  /// Builds the image grid with images fetched from the API.
  /// This method uses a `MasonryGridView` from `flutter_staggered_grid_view` to layout
  /// the images in a responsive grid.
  Widget _buildImageGrid() {
    // If no images have been loaded yet, show a progress indicator.
    if (_images.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MasonryGridView.builder(
        controller: _scrollController,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _calculateCrossAxisCount(
              context), // Number of columns based on screen size
        ),
        itemCount: _images.length +
            (_isLoading ? 1 : 0), // Account for loading indicator.
        itemBuilder: (context, index) {
          if (index == _images.length) {
            // Show a loading indicator when fetching more images.
            return const Center(child: CircularProgressIndicator());
          }
          // Create an image card for each item.
          final image = _images[index];
          return _buildImageCard(image);
        },
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
    );
  }

  /// Builds an individual image card showing the image, likes, and views.
  Widget _buildImageCard(dynamic image) {
    return Card(
      color: AppColors.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the image fetched from Pixabay.
          Image.network(
            image['webformatURL'],
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the number of likes the image has received.
                Text('Likes: ${image['likes']}',
                    style: TextStyle(
                        color: AppColors.textColor,
                        fontFamily: AppFonts.secondaryFont)),
                // Display the number of views the image has received.
                Text('Views: ${image['views']}',
                    style: TextStyle(
                        color: AppColors.textColor,
                        fontFamily: AppFonts.secondaryFont)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates the number of columns in the grid based on the screen width.
  /// Returns different values based on breakpoints for responsive design.
  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      return 4; // Large screens, 4 columns.
    } else if (screenWidth >= 800) {
      return 3; // Medium screens, 3 columns.
    } else {
      return 2; // Small screens, 2 columns.
    }
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose of the ScrollController when no longer needed.
    super.dispose();
  }
}
