import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';

import '../../../coach/models/coach.dart';

class FeaturedCarousel extends StatefulWidget {
  final List<Coach> coaches;
  const FeaturedCarousel({super.key, required this.coaches});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= widget.coaches.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.coaches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "À la une",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.coaches.length,
            itemBuilder: (context, index) {
              return _buildFeaturedCard(widget.coaches[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(Coach coach, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return child!;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Gradient or Image Pattern
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            coach.avatarIcon.isNotEmpty ? coach.avatarIcon : coach.name[0],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.star, size: 12, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                "Top Coach",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      coach.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coach.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}
