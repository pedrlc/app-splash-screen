import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Canvas
  static const double canvasWidth = 1080;
  static const double canvasHeight = 1920;
  static const Color backgroundColor = Color(0xFF000000);
  static const Color glowColor = Color(0xFF1677FF);

  // Posições finais – AJUSTADAS
  static const double logoFinalY = 590.0;
  static const double titleFinalY = 980.0;
  static const double subtitleFinalY = 1140.0; // 30px abaixo do título

  // Tamanhos
  static const double logoWidth = 720.0;
  static const double logoHeight = 480.0;
  static const double titleBoxWidth = 1080;
  static const double titleBoxHeight = 220;
  static const double subtitleBoxWidth = 840.0;
  static const double subtitleBoxHeight = 48.0;

  // Animação de entrada
  static const double moveDistance = 420.0;
  static const double initialScale = 1.5;
  static const double finalScale = 1.0;

  // Timings
  static const int entryStart = 0;
  static const int entryEnd = 2000;
  static const int pulseStart = 1710;
  static const int pulseEnd = 3840;
  static const int glowEntryStart = 1710;
  static const int glowEntryEnd = 2630;
  static const int glowLogoStep1Start = 2630;
  static const int glowLogoStep1End = 3430;
  static const int glowLogoStep2Start = 3430;
  static const int glowLogoStep2End = 4330;
  static const int glowLogoStep3Start = 4330;
  static const int glowLogoStep3End = 5130;
  static const int totalDuration = 5200;

  // Glow – intensificado
  static const double logoGlowFinalBlur = 160.0;
  static const double logoGlowFinalOffsetY = 18.0;
  static const double logoGlowFinalOpacity = 1.0;
  static const double logoGlowCoreBlur = 50.0;
  static const double logoGlowCoreOpacity = 0.9;

  static const double titleGlowBlur = 180.0;
  static const double titleGlowOffsetY = 20.0;
  static const double titleGlowOpacity = 1.15;

  static const double subtitleGlowBlur = 180.0;
  static const double subtitleGlowOffsetY = 18.0;
  static const double subtitleGlowOpacity = 1.0;

  // Curva mais suave 
  static const Curve easingCurve = Curves.easeInOutQuint;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: totalDuration),
    );

    // Navega assim que a animação termina de verdade,
    // em vez de depender de um delay fixo arbitrário.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToHome();
      }
    });

    // Fallback de segurança: caso por algum motivo o status listener
    // não dispare (ex: app em background), garante a navegação mesmo assim.
    Future.delayed(const Duration(milliseconds: totalDuration + 1500), _goToHome);

    _controller.forward();
  }

  void _goToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Interpolação ---
  double _interpolateDouble(double start, double end, int startMs, int endMs) {
    final progress = _controller.value;
    final elapsed = progress * totalDuration;
    if (elapsed <= startMs) return start;
    if (elapsed >= endMs) return end;
    final t = (elapsed - startMs) / (endMs - startMs);
    final curvedT = easingCurve.transform(t);
    return start + (end - start) * curvedT;
  }
  /// Quantiza um valor contínuo para o degrau mais próximo dentro de [stageCoun
/// níveis fixos entre [min e [max. Isso faz o Skia enxergar o MESMO sigma
/// em vários frames consecutivos (em vez de um valor único a cada tick),
/// permitindo reaproveitar a camada de blur já calculada.
  double _quantize(double value, double min, double max, int stageCount) {
  if (max <= min || stageCount <= 1) return value;
  final double stepSize = (max - min) / (stageCount - 1);
  final double stepped = ((value - min) / stepSize).round() * stepSize + min;
  return stepped.clamp(min, max);
}
  double _entryScale() {
    return _interpolateDouble(initialScale, finalScale, entryStart, entryEnd);
  }

  double _entryY(double finalY) {
    return _interpolateDouble(finalY + moveDistance, finalY, entryStart, entryEnd);
  }

  double _entryOpacity() {
    return _interpolateDouble(0.0, 1.0, entryStart, entryEnd);
  }

  double _pulseScale() {
    final progress = _controller.value;
    final elapsed = progress * totalDuration;
    if (elapsed <= pulseStart) return 1.0;
    if (elapsed >= pulseEnd) return 1.0;
    final mid = (pulseStart + pulseEnd) ~/ 2;
    if (elapsed <= mid) {
      final t = (elapsed - pulseStart) / (mid - pulseStart);
      final curvedT = easingCurve.transform(t);
      return 1.0 + (1.5 - 1.0) * curvedT;
    } else {
      final t = (elapsed - mid) / (pulseEnd - mid);
      final curvedT = easingCurve.transform(t);
      return 1.5 - (1.5 - 1.0) * curvedT;
    }
  }

   double _logoGlowBlur() {
    final elapsed = _controller.value * totalDuration;
    double raw;
    if (elapsed < glowLogoStep1Start) {
      raw = _interpolateDouble(0.0, logoGlowFinalBlur, glowEntryStart, glowEntryEnd);
    } else if (elapsed < glowLogoStep1End) {
      raw = _interpolateDouble(logoGlowFinalBlur, 76.0, glowLogoStep1Start, glowLogoStep1End);
    } else if (elapsed < glowLogoStep2End) {
      raw = _interpolateDouble(76.0, 140.0, glowLogoStep2Start, glowLogoStep2End);
    } else if (elapsed < glowLogoStep3End) {
      raw = _interpolateDouble(140.0, logoGlowFinalBlur, glowLogoStep3Start, glowLogoStep3End);
    } else {
      raw = logoGlowFinalBlur;
    }
    return _quantize(raw, 0.0, logoGlowFinalBlur, 7);
  }

  double _logoGlowOpacity() {
    final elapsed = _controller.value * totalDuration;
    if (elapsed < glowLogoStep1Start) {
      return _interpolateDouble(0.0, 1.0, glowEntryStart, glowEntryEnd);
    }
    if (elapsed >= glowLogoStep1Start && elapsed < glowLogoStep1End) {
      return _interpolateDouble(1.0, 0.70, glowLogoStep1Start, glowLogoStep1End);
    }
    if (elapsed >= glowLogoStep2Start && elapsed < glowLogoStep2End) {
      return _interpolateDouble(0.70, 1.0, glowLogoStep2Start, glowLogoStep2End);
    }
    return 1.0;
  }

  double _logoGlowOffsetY() {
    final elapsed = _controller.value * totalDuration;
    if (elapsed < glowLogoStep1Start) {
      return _interpolateDouble(0.0, logoGlowFinalOffsetY, glowEntryStart, glowEntryEnd);
    }
    if (elapsed >= glowLogoStep1Start && elapsed < glowLogoStep1End) {
      return _interpolateDouble(18.0, 12.0, glowLogoStep1Start, glowLogoStep1End);
    }
    if (elapsed >= glowLogoStep2Start && elapsed < glowLogoStep2End) {
      return _interpolateDouble(12.0, 22.0, glowLogoStep2Start, glowLogoStep2End);
    }
    if (elapsed >= glowLogoStep3Start && elapsed < glowLogoStep3End) {
      return _interpolateDouble(22.0, 18.0, glowLogoStep3Start, glowLogoStep3End);
    }
    return 18.0;
  }

  double _titleGlowOpacity() {
    return _interpolateDouble(0.0, 1.0, glowEntryStart, glowEntryEnd);
  }
  double _titleGlowBlur() {
    final raw = _interpolateDouble(0.0, titleGlowBlur, glowEntryStart, glowEntryEnd);
    return _quantize(raw, 0.0, titleGlowBlur, 7);
  }
  double _titleGlowOffsetY() {
    return _interpolateDouble(0.0, titleGlowOffsetY, glowEntryStart, glowEntryEnd);
  }

  double _subtitleGlowOpacity() {
    return _interpolateDouble(0.0, 1.0, glowEntryStart, glowEntryEnd);
  }
  double _subtitleGlowBlur() {
    final raw = _interpolateDouble(0.0, subtitleGlowBlur, glowEntryStart, glowEntryEnd);
    return _quantize(raw, 0.0, subtitleGlowBlur, 7);
  }
  double _subtitleGlowOffsetY() {
    return _interpolateDouble(0.0, subtitleGlowOffsetY, glowEntryStart, glowEntryEnd);
  }

  // --- Glow com duas camadas ---
  Widget _buildGlow({
    required Widget child,
    required double blur,
    required double offsetY,
    required double opacity,
    required Color color,
    double coreBlur = 0.0,
    double coreOpacity = 0.0,
  }) {
    if (opacity <= 0 || blur <= 0) return child;

    final glowLayers = <Widget>[
      Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: blur / 2,
              sigmaY: blur / 2,
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              child: child,
            ),
          ),
        ),
      ),
    ];

    if (coreBlur > 0 && coreOpacity > 0) {
      glowLayers.add(
        Opacity(
          opacity: coreOpacity,
          child: Transform.translate(
            offset: Offset(0, offsetY * 0.6),
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: coreBlur / 2,
                sigmaY: coreBlur / 2,
              ),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    glowLayers.add(child);
    return Stack(alignment: Alignment.center, children: glowLayers);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scale = math.min(
      screenSize.width / canvasWidth,
      screenSize.height / canvasHeight,
    );
    final scaledWidth = canvasWidth * scale;
    final scaledHeight = canvasHeight * scale;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SizedBox(
          width: scaledWidth,
          height: scaledHeight,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final entryOpacity = _entryOpacity();
              final logoScale = _entryScale() * _pulseScale();
              final titleScale = _entryScale() * _pulseScale();
              final subtitleScale = _entryScale() * _pulseScale();

              final logoY = _entryY(logoFinalY);
              final titleY = _entryY(titleFinalY);
              final subtitleY = _entryY(subtitleFinalY);

              final logoGlowBlur = _logoGlowBlur();
              final logoGlowOpacity = _logoGlowOpacity();
              final logoGlowOffsetY = _logoGlowOffsetY();

              final titleGlowBlur = _titleGlowBlur();
              final titleGlowOpacity = _titleGlowOpacity();
              final titleGlowOffsetY = _titleGlowOffsetY();

              final subtitleGlowBlur = _subtitleGlowBlur();
              final subtitleGlowOpacity = _subtitleGlowOpacity();
              final subtitleGlowOffsetY = _subtitleGlowOffsetY();

              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Logo
                  Positioned(
                    top: logoY * scale,
                    left: (canvasWidth - logoWidth) / 2 * scale,
                    width: logoWidth * scale,
                    height: logoHeight * scale,
                    child: Opacity(
                      opacity: entryOpacity,
                      child: Transform.scale(
                        alignment: Alignment.center,
                        scale: logoScale,
                        child: _buildGlow(
                          blur: logoGlowBlur,
                          offsetY: logoGlowOffsetY,
                          opacity: logoGlowOpacity,
                          color: glowColor,
                          coreBlur: logoGlowCoreBlur,
                          coreOpacity: logoGlowCoreOpacity,
                          child: Image.asset(
                            'assets/images/logo_vrum.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Título
                  Positioned(
                    top: titleY * scale,
                    left: (canvasWidth - titleBoxWidth) / 2 * scale,
                    width: titleBoxWidth * scale,
                    height: titleBoxHeight * scale,
                    child: Opacity(
                      opacity: entryOpacity,
                      child: Transform.scale(
                        alignment: Alignment.center,
                        scale: titleScale,
                        child: _buildGlow(
                          blur: titleGlowBlur,
                          offsetY: titleGlowOffsetY,
                          opacity: titleGlowOpacity,
                          color: glowColor,
                          child: Image.asset(
                            'assets/images/vrum_letreiro.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Subtítulo
                  Positioned(
                    top: subtitleY * scale,
                    left: (canvasWidth - subtitleBoxWidth) / 2 * scale,
                    width: subtitleBoxWidth * scale,
                    height: subtitleBoxHeight * scale,
                    child: Opacity(
                      opacity: entryOpacity,
                      child: Transform.scale(
                        alignment: Alignment.center,
                        scale: subtitleScale,
                        child: _buildGlow(
                          blur: subtitleGlowBlur,
                          offsetY: subtitleGlowOffsetY,
                          opacity: subtitleGlowOpacity,
                          color: glowColor,
                          child: Text(
                            'VRUM SCANNER OBD2',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28 * scale,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                              letterSpacing: 7 * scale,
                              color: const Color(0xFFA8B7D5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}