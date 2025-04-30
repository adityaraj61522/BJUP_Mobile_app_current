import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageCompressor {
  /// Compresses an image file to target size in kilobytes
  /// Returns the path to the compressed image file
  static Future<String?> compressImageFile(
    String imagePath, {
    int targetSizeKB = 1024, // Default target: 1MB (1024KB)
    int minQuality = 50, // Minimum quality to prevent extreme degradation
    int maxAttempts = 3, // Maximum compression attempts
  }) async {
    if (imagePath.isEmpty) return null;

    File originalFile = File(imagePath);
    if (!await originalFile.exists()) {
      print('Original file does not exist at: $imagePath');
      return null;
    }

    // Get file extension
    String extension = path.extension(imagePath).toLowerCase();
    if (extension != '.jpg' && extension != '.jpeg' && extension != '.png') {
      print('File is not a compressible image: $extension');
      return imagePath; // Return original path if not a compressible format
    }

    // Create output directory if it doesn't exist
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String compressedDirPath = '${appDir.path}/compressed_images';
    final compressedDir = Directory(compressedDirPath);
    if (!await compressedDir.exists()) {
      await compressedDir.create(recursive: true);
    }

    // Create output file path with unique name
    final String outputFileName = 'compressed_${Uuid().v4()}$extension';
    final String outputPath = '${compressedDir.path}/$outputFileName';

    // Check if input file is already smaller than target size
    int originalSizeKB = await originalFile.length() ~/ 1024;
    if (originalSizeKB <= targetSizeKB) {
      print(
          'Original file is already smaller than target size: $originalSizeKB KB');
      return imagePath; // Return original path if already small enough
    }

    print('Original file size: $originalSizeKB KB');

    // Calculate initial quality based on how much we need to compress
    int quality = _calculateInitialQuality(originalSizeKB, targetSizeKB);

    // Perform compression attempts
    File? compressedFile;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        print('Compression attempt ${attempt + 1} with quality: $quality');

        // Compress image
        final compressedData = await FlutterImageCompress.compressWithFile(
          imagePath,
          quality: quality,
          // Optional parameters for more control
          minWidth: 1080, // Limit max resolution
          minHeight: 1080,
          rotate: 0,
        );

        if (compressedData == null || compressedData.isEmpty) {
          print('Compression failed: No data returned');
          continue;
        }

        // Write compressed data to file
        compressedFile = File(outputPath);
        await compressedFile.writeAsBytes(compressedData);

        // Check result size
        int compressedSizeKB = await compressedFile.length() ~/ 1024;
        print('Compressed file size: $compressedSizeKB KB');

        // If we're close enough to target size or at minimum quality, return result
        if (compressedSizeKB <= targetSizeKB || quality <= minQuality) {
          print('Compression successful. Final size: $compressedSizeKB KB');
          return outputPath;
        }

        // Adjust quality for next attempt
        quality = _adjustQuality(quality, compressedSizeKB, targetSizeKB);
      } catch (e) {
        print('Error during compression: $e');
        // If we have a partially compressed file that's smaller than original, use it
        if (compressedFile != null && await compressedFile.exists()) {
          int compressedSizeKB = await compressedFile.length() ~/ 1024;
          if (compressedSizeKB < originalSizeKB) {
            print('Using partially compressed file: $compressedSizeKB KB');
            return outputPath;
          }
        }
      }
    }

    // If all compression attempts failed, return original file path
    print('All compression attempts failed, using original file');
    return imagePath;
  }

  /// Calculate initial quality for compression based on file size ratio
  static int _calculateInitialQuality(int originalSizeKB, int targetSizeKB) {
    // Start with high quality for small size differences, lower for large differences
    double ratio = targetSizeKB / originalSizeKB;
    int initialQuality = (ratio * 95).round(); // Scale to max quality of 95
    return initialQuality.clamp(60, 95); // Ensure reasonable range
  }

  /// Adjust quality for next compression attempt based on previous result
  static int _adjustQuality(
      int currentQuality, int currentSizeKB, int targetSizeKB) {
    // How far we are from target size
    double ratio = targetSizeKB / currentSizeKB;

    // Adjust quality proportionally but not too aggressively
    int adjustment = (currentQuality * (ratio - 1) * 0.7).round();

    // Limit the adjustment to avoid too drastic changes
    adjustment = adjustment.clamp(-15, -5);

    return (currentQuality + adjustment).clamp(40, 90);
  }
}
