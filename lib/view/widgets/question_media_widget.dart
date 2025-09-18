import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/question_model.dart';

/// Widget untuk menampilkan media (gambar atau video) pada question
class QuestionMediaWidget extends StatefulWidget {
  final QuestionModel question;
  final double? height;
  final double? width;

  const QuestionMediaWidget({
    Key? key,
    required this.question,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  State<QuestionMediaWidget> createState() => _QuestionMediaWidgetState();
}

class _QuestionMediaWidgetState extends State<QuestionMediaWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  void _initializeMedia() {
    if (widget.question.mediaType == MediaType.video &&
        widget.question.mediaUrl != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.question.mediaUrl!),
      );

      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        // Set video to loop and autoplay
        _videoController!.setLooping(true);
        _videoController!.play();
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasVideoError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(QuestionMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If question changed, reinitialize media
    if (oldWidget.question.id != widget.question.id) {
      _disposeVideo();
      _initializeMedia();
    }
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
    _hasVideoError = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 200,
      width: widget.width ?? double.infinity,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: _buildMediaContent(),
    );
  }

  Widget _buildMediaContent() {
    switch (widget.question.mediaType) {
      case MediaType.image:
        return _buildImageWidget();
      case MediaType.video:
        return _buildVideoWidget();
      case MediaType.none:
        return _buildNoMediaWidget();
    }
  }

  Widget _buildImageWidget() {
    if (widget.question.mediaUrl == null) {
      return _buildNoMediaWidget();
    }

    return Image.network(
      widget.question.mediaUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget('Gagal memuat gambar');
      },
    );
  }

  Widget _buildVideoWidget() {
    if (widget.question.mediaUrl == null) {
      return _buildNoMediaWidget();
    }

    if (_hasVideoError) {
      return _buildErrorWidget('Gagal memuat video');
    }

    if (!_isVideoInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Return video player tanpa controls overlay
    return VideoPlayer(_videoController!);
  }

  Widget _buildNoMediaWidget() {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
