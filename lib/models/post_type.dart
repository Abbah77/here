enum PostType {
  text,
  image,
  multiImage,
  video,
  link,
}

/// Rule: Premium extension to handle UI metadata dynamically
extension PostTypeExtension on PostType {
  // Returns the icon associated with the post type (useful for headers or indicators)
  dynamic get icon {
    switch (this) {
      case PostType.text:
        return null; // Text posts usually don't need a specific icon
      case PostType.image:
        return 'assets/icons/image_filled.png';
      case PostType.multiImage:
        return 'assets/icons/gallery_filled.png';
      case PostType.video:
        return 'assets/icons/play_filled.png';
      case PostType.link:
        return 'assets/icons/link_filled.png';
    }
  }

  // Rule: Helper to determine if the post type requires a full-width media container
  bool get isMediaPost => this != PostType.text;

  // Rule: Helper to determine if the post is a video for autoplay logic
  bool get isVideo => this == PostType.video;
}
