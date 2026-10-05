import 'package:flutter/foundation.dart';

/// A preset camera angle for the product viewer. Each thumbnail maps to one.
enum ProductAngle {
  side(label: 'Side', theta: 0, phi: 75, fallbackYaw: 0, fallbackPitch: 0),
  frontAngle(
    label: 'Front angle',
    theta: 50,
    phi: 72,
    fallbackYaw: 0.55,
    fallbackPitch: 0,
  ),
  back(label: 'Back', theta: 270, phi: 78, fallbackYaw: -0.6, fallbackPitch: 0),
  top(label: 'Top', theta: 0, phi: 12, fallbackYaw: 0, fallbackPitch: 0.5),
  sole(label: 'Sole', theta: 0, phi: 168, fallbackYaw: 0, fallbackPitch: -0.5);

  const ProductAngle({
    required this.label,
    required this.theta,
    required this.phi,
    required this.fallbackYaw,
    required this.fallbackPitch,
  });

  final String label;

  /// Horizontal camera angle in degrees (model-viewer `camera-orbit` theta).
  final double theta;

  /// Vertical camera angle in degrees (model-viewer `camera-orbit` phi).
  final double phi;

  /// Rotations (radians) used by the 2D fallback to suggest this angle.
  final double fallbackYaw;
  final double fallbackPitch;

  /// The phi used while the user drags: horizontal rotation only.
  static const double defaultPhi = 75;
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.pairsLeft,
    required this.sold,
    required this.rating,
    required this.reviewCount,
    required this.sizes,
    required this.modelUrl,
    required this.fallbackImage,
    this.angles = ProductAngle.values,
  });

  final String id;
  final String name;

  /// Price in whole dollars.
  final int price;
  final int pairsLeft;
  final int sold;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final String modelUrl;
  final String fallbackImage;
  final List<ProductAngle> angles;

  /// "$14,200"
  String get formattedPrice {
    final digits = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '\$$buffer';
  }
}

/// Size chart rows: US, UK, EU, foot length in cm.
const List<List<String>> kSizeChart = [
  ['US', 'UK', 'EU', 'CM'],
  ['4', '3.5', '36', '22.5'],
  ['4.5', '4', '36.5', '23'],
  ['5', '4.5', '37.5', '23.5'],
  ['5.5', '5', '38', '24'],
  ['6', '5.5', '38.5', '24'],
  ['6.5', '6', '39', '24.5'],
  ['7', '6', '40', '25'],
];

/// 3D model: "Materials Variants Shoe" from the Khronos glTF-Sample-Assets
/// repository (https://github.com/KhronosGroup/glTF-Sample-Assets).
/// © 2021 Shopify. Licensed under Creative Commons Attribution 4.0
/// International (CC BY 4.0): https://creativecommons.org/licenses/by/4.0/
/// Used unmodified; loaded at runtime from GitHub's raw content host.
const String kSneakerModelUrl =
    'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/'
    'Models/MaterialsVariantsShoe/glTF-Binary/MaterialsVariantsShoe.glb';

const String kSneakerFallbackImage = 'assets/images/sneaker_placeholder.png';

const Product kDummyProduct = Product(
  id: 'jordan-1-low-grey-toe',
  name: 'Jordan 1 Low Grey Toe',
  price: 14200,
  pairsLeft: 5,
  sold: 50,
  rating: 4.7,
  reviewCount: 69,
  sizes: ['US 4', 'US 4.5', 'US 5', 'US 5.5', 'US 6', 'US 6.5', 'US 7'],
  modelUrl: kSneakerModelUrl,
  fallbackImage: kSneakerFallbackImage,
);
