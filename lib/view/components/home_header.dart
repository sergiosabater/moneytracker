// home_header.dart - Versión mejorada con animaciones y diseño moderno
import 'package:flutter/material.dart';
import 'package:moneytracker/controller/transactions_provider.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Delay para que se ejecute después de que la app esté lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<TransactionsProvider>(context);
    final balance = provider.getBalance();
    final incomes = provider.getTotalIncomes();
    final expenses = provider.getTotalExpenses();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade800,
                  Colors.teal.shade600,
                  Colors.teal.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.shade800.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  // App Title con efecto de brillo
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white70,
                          Colors.white,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Balance
                  Text(
                    AppLocalizations.of(context)!.balance.toUpperCase(),
                    style: textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBalanceText(balance: balance),
                  const SizedBox(height: 30),
                  
                  // Cards de ingresos y gastos
                  Row(
                    children: [
                      Expanded(
                        child: _ModernStatsCard(
                          title: AppLocalizations.of(context)!.incomes,
                          amount: incomes,
                          icon: Icons.trending_up,
                          color: Colors.green.shade400,
                          delay: const Duration(milliseconds: 200),
                          animationController: _animationController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModernStatsCard(
                          title: AppLocalizations.of(context)!.expenses,
                          amount: expenses,
                          icon: Icons.trending_down,
                          color: Colors.red.shade400,
                          delay: const Duration(milliseconds: 400),
                          animationController: _animationController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedBalanceText extends StatefulWidget {
  final double balance;

  const AnimatedBalanceText({super.key, required this.balance});

  @override
  State<AnimatedBalanceText> createState() => _AnimatedBalanceTextState();
}

class _AnimatedBalanceTextState extends State<AnimatedBalanceText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnim = ColorTween(
      begin: Colors.white,
      end: widget.balance >= 0 ? Colors.green.shade100 : Colors.red.shade100,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBalanceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.balance != oldWidget.balance) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnim,
          child: Text(
            '\$ ${widget.balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 42,
                  color: _colorAnim.value,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }
}

class _ModernStatsCard extends StatefulWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final Duration delay;
  final AnimationController animationController;

  const _ModernStatsCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.delay,
    required this.animationController,
  });

  @override
  State<_ModernStatsCard> createState() => __ModernStatsCardState();
}

class __ModernStatsCardState extends State<_ModernStatsCard> {
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _cardSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = widget.amount < 0
        ? '-\$ ${widget.amount.abs().toStringAsFixed(2)}'
        : '\$ ${widget.amount.toStringAsFixed(2)}';

    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value),
          child: Transform.scale(
            scale: _cardScaleAnimation.value,
            child: Opacity(
              opacity: _cardFadeAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(-3, -3),
                    ),
                  ],
                  border: Border.all(
                    color: widget.color.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono con fondo neumórfico
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.color.withOpacity(0.2),
                              widget.color.withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(2, 2),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 10,
                              offset: const Offset(-2, -2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Título
                      Text(
                        widget.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Monto
                      Text(
                        formattedAmount,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w900,
                              color: widget.color,
                              fontSize: 20,
                              letterSpacing: -0.5,
                            ),
                      ),
                      
                      // Barra de progreso decorativa
                      const SizedBox(height: 12),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withOpacity(0.8),
                              widget.color.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}