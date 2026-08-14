import 'package:flutter/widgets.dart';

/// The design source's three `twinkle` star particles
/// (`cupid-app-design-system/project/Cupid Screens.dc.html:45-47`), which the
/// source itself labels the shared backdrop of every screen — "Nebula Sky —
/// nền chung mọi screen, có sao nhấp nháy" (`Cupid App.dc.html:100`).
///
/// They live in the source's root wrapper as `position:absolute` siblings of
/// the screen body, so CSS paints them *above* each screen's own opaque
/// `var(--bg)` layer rather than behind it. Place this as the last child of a
/// screen's background `Stack` for the same result. `pointer-events:none` in
/// the source maps to the [IgnorePointer]/[ExcludeSemantics] pair built in
/// here, so a caller cannot accidentally make the decoration interactive.
class CupidStarField extends StatelessWidget {
  const CupidStarField({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;

            return Stack(
              children: <Widget>[
                Positioned(
                  top: height * 0.14,
                  left: width * 0.08,
                  child: const _TwinkleStar(
                    diameter: 6,
                    color: Color.fromRGBO(255, 255, 255, 1),
                    period: Duration(milliseconds: 3400),
                  ),
                ),
                Positioned(
                  top: height * 0.09,
                  right: width * 0.16,
                  child: const _TwinkleStar(
                    diameter: 4,
                    color: Color.fromRGBO(255, 217, 234, 1),
                    period: Duration(milliseconds: 4600),
                    phase: 0.8 / 4.6,
                  ),
                ),
                Positioned(
                  top: height * 0.26,
                  right: width * 0.07,
                  child: const _TwinkleStar(
                    diameter: 5,
                    color: Color.fromRGBO(206, 180, 255, 1),
                    period: Duration(milliseconds: 5200),
                    phase: 1.6 / 5.2,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One `twinkle` keyframe run (`Cupid Screens.dc.html:35`): `opacity .25` and
/// `scale(.85)` at both cycle ends, `1` and `scale(1.15)` at the midpoint,
/// eased in and out.
class _TwinkleStar extends StatefulWidget {
  const _TwinkleStar({
    required this.diameter,
    required this.color,
    required this.period,
    this.phase = 0,
  });

  final double diameter;
  final Color color;
  final Duration period;

  /// The source's `animation-delay` as a fraction of [period]. The staggered
  /// stars only ever differ from the first in steady state, so the delay is
  /// carried as a phase offset instead of a startup timer.
  final double phase;

  @override
  State<_TwinkleStar> createState() => _TwinkleStarState();
}

class _TwinkleStarState extends State<_TwinkleStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
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
      builder: (BuildContext context, Widget? child) {
        final double t = (_controller.value + widget.phase) % 1.0;
        final double eased = Curves.easeInOut.transform(
          t < 0.5 ? t / 0.5 : (1 - t) / 0.5,
        );
        return Opacity(
          opacity: 0.25 + 0.75 * eased,
          child: Transform.scale(scale: 0.85 + 0.3 * eased, child: child),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        child: SizedBox(width: widget.diameter, height: widget.diameter),
      ),
    );
  }
}
