import 'package:flutter/material.dart';

import '../core/constants/app_theme.dart';

class AboutBgnSection extends StatelessWidget {
  const AboutBgnSection({
    super.key,
    required this.onReadMore,
    required this.onEnquire,
  });

  final VoidCallback onReadMore;
  final VoidCallback onEnquire;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final image = AgentPortraitPanel(isWide: isWide);
        final copy = AboutBgnCopy(onReadMore: onReadMore, onEnquire: onEnquire);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 0,
            vertical: isWide ? 24 : 8,
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: image),
                    const SizedBox(width: 40),
                    Expanded(child: copy),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [image, const SizedBox(height: 20), copy],
                ),
        );
      },
    );
  }
}

class AgentPortraitPanel extends StatelessWidget {
  const AgentPortraitPanel({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: isWide ? 1.05 : 1.18,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.navy,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.25),
                  radius: 1.1,
                  colors: [
                    AppTheme.navy.withValues(alpha: 0.72),
                    const Color(0xFF06122F),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/bavu.png',
                fit: BoxFit.contain,
                height: isWide ? 340 : 260,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.navy.withValues(alpha: 0.54),
                    ],
                    stops: const [0.58, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              right: 18,
              child: Text(
                'BGN Real Estate',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutBgnCopy extends StatelessWidget {
  const AboutBgnCopy({
    super.key,
    required this.onReadMore,
    required this.onEnquire,
  });

  final VoidCallback onReadMore;
  final VoidCallback onEnquire;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BGN Real Estate',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppTheme.ink,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          width: 96,
          height: 2.5,
          margin: const EdgeInsets.only(top: 14, bottom: 24),
          color: AppTheme.navy,
        ),
        Text(
          'BGN Real Estate is a client-centred real estate agency specialising in premium residential property sales, luxury rentals, rental management, and forward-looking developments across South Africa.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.ink.withValues(alpha: 0.82),
            height: 1.55,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'We serve discerning homeowners, high-net-worth buyers, investors, developers, and tenants who value quality, discretion, and long-term asset integrity.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.ink.withValues(alpha: 0.82),
            height: 1.55,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 180,
              height: 52,
              child: OutlinedButton(
                onPressed: onReadMore,
                child: const Text('Read More'),
              ),
            ),
            SizedBox(
              width: 180,
              height: 52,
              child: FilledButton(
                onPressed: onEnquire,
                child: const Text('Enquire'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
