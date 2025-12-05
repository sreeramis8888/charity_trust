import 'dart:math';
import 'package:flutter/material.dart';

class PaymentFailurePage extends StatefulWidget {
  const PaymentFailurePage({super.key});

  @override
  State<PaymentFailurePage> createState() => _PaymentFailurePageState();
}

class _PaymentFailurePageState extends State<PaymentFailurePage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Trigger a subtle shake effect
    Future.delayed(const Duration(milliseconds: 350), () {
      _shakeController.forward().then((_) => _shakeController.reverse());
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeController,
        child: Center(
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset = sin(_shakeController.value * pi * 6) * 8;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Failure Icon
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade50,
                      border: Border.all(
                        color: Colors.red.shade300,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 60,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Payment Failed',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'We were unable to process your payment. Please try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const SizedBox(height: 14),

                  OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red, width: 1.4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 34, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
