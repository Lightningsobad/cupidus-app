import 'package:flutter/material.dart';

import 'onboarding_chain.dart';

/// Thrown when a chain edge resolves to a node that has no builder in the
/// registry. Loud by design (`architecture/solution.md` ADR-1): a missing
/// screen must fail exactly one node, never silently no-op into a dead edge.
class OnboardingRouteNotRegistered implements Exception {
  const OnboardingRouteNotRegistered(this.node);

  final OnboardingNode node;

  @override
  String toString() =>
      'OnboardingRouteNotRegistered: no builder registered for '
      'OnboardingNode.${node.name}.';
}

/// Thrown when [OnboardingRouter.goNext] is called from a branching or
/// terminal node. Those nodes have no single successor by design, so the
/// caller must pick a target with [OnboardingRouter.replaceWith] instead.
class OnboardingChainHasNoSuccessor implements Exception {
  const OnboardingChainHasNoSuccessor(this.from);

  final OnboardingNode from;

  @override
  String toString() =>
      'OnboardingChainHasNoSuccessor: OnboardingNode.${from.name} has no '
      'single successor; choose an explicit target.';
}

/// `architecture/solution.md` ADR-1's builder registry. Screens are injected
/// rather than imported so tests can register stubs, and so a not-yet-merged
/// screen (§5 dependency gate) fails one registry entry instead of the whole
/// chain.
class OnboardingRouter {
  OnboardingRouter({required Map<OnboardingNode, WidgetBuilder> builders})
    : _builders = Map<OnboardingNode, WidgetBuilder>.unmodifiable(builders);

  final Map<OnboardingNode, WidgetBuilder> _builders;

  /// Advances one step along [OnboardingChain.next].
  Future<void> goNext(BuildContext context, OnboardingNode from) {
    final OnboardingNode? target = OnboardingChain.next(from);
    if (target == null) {
      throw OnboardingChainHasNoSuccessor(from);
    }
    return Navigator.of(context).push<void>(_routeFor(target));
  }

  Future<void> replaceWith(BuildContext context, OnboardingNode node) =>
      Navigator.of(context).pushReplacement<void, void>(_routeFor(node));

  /// Clears the whole stack, used for sign-out/re-auth (ADR-6) and for
  /// landing on `home`.
  Future<void> resetTo(BuildContext context, OnboardingNode node) =>
      Navigator.of(context).pushAndRemoveUntil<void>(
        _routeFor(node),
        (Route<dynamic> route) => false,
      );

  Route<void> _routeFor(OnboardingNode node) {
    final WidgetBuilder? builder = _builders[node];
    if (builder == null) {
      throw OnboardingRouteNotRegistered(node);
    }
    return MaterialPageRoute<void>(
      builder: builder,
      settings: RouteSettings(name: node.name),
    );
  }
}
