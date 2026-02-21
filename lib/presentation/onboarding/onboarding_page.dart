import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.add_shopping_cart_rounded,
      title: 'Cadastre seus produtos',
      subtitle: 'Adicione os produtos que voce costuma comprar',
    ),
    _SlideData(
      icon: Icons.kitchen_rounded,
      title: 'Controle sua despensa',
      subtitle: 'Saiba o que tem em casa e o que esta acabando',
    ),
    _SlideData(
      icon: Icons.analytics_rounded,
      title: 'Planeje suas compras',
      subtitle: 'Analise seus padroes de consumo e compre melhor',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref.read(setHasSeenOnboardingProvider)(true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSkipButton(),
            Expanded(child: _buildPageView()),
            _buildDotsIndicator(),
            const SizedBox(height: 32),
            _buildBottomButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _currentPage < 2
            ? GestureDetector(
                onTap: _complete,
                child: Text('Pular', style: AppTextStyles.bodySecondary),
              )
            : const SizedBox(height: 20),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _controller,
      itemCount: _slides.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (context, index) => _buildSlide(_slides[index]),
    );
  }

  Widget _buildSlide(_SlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 72, color: AppColors.primary),
          ),
          const SizedBox(height: 40),
          Text(slide.title, style: AppTextStyles.heading1, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(slide.subtitle, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    if (_currentPage < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _complete,
          child: Text('Comecar', style: AppTextStyles.button),
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
