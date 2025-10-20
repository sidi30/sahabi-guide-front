import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/connectivity_plan_model.dart';
import '../../data/models/connectivity_subscription_model.dart';
import '../../data/models/connectivity_topup_model.dart';
import '../../domain/usecases/get_connectivity_plans_usecase.dart';
import '../../domain/usecases/get_user_subscriptions_usecase.dart';
import '../../domain/usecases/subscribe_to_plan_usecase.dart';
import '../../domain/usecases/topup_subscription_usecase.dart';

// Use cases providers
final getConnectivityPlansUseCaseProvider = Provider((ref) => sl<GetConnectivityPlansUseCase>());
final getUserSubscriptionsUseCaseProvider = Provider((ref) => sl<GetUserSubscriptionsUseCase>());
final subscribeToPlanUseCaseProvider = Provider((ref) => sl<SubscribeToPlanUseCase>());
final topupSubscriptionUseCaseProvider = Provider((ref) => sl<TopupSubscriptionUseCase>());

// State class
class ConnectivityState {
  final List<ConnectivityPlanModel> plans;
  final List<ConnectivitySubscriptionModel> subscriptions;
  final bool isLoading;
  final String? error;

  const ConnectivityState({
    this.plans = const [],
    this.subscriptions = const [],
    this.isLoading = false,
    this.error,
  });

  ConnectivityState copyWith({
    List<ConnectivityPlanModel>? plans,
    List<ConnectivitySubscriptionModel>? subscriptions,
    bool? isLoading,
    String? error,
  }) {
    return ConnectivityState(
      plans: plans ?? this.plans,
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// State notifier
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final GetConnectivityPlansUseCase getPlansUseCase;
  final GetUserSubscriptionsUseCase getSubscriptionsUseCase;
  final SubscribeToPlanUseCase subscribeToPlanUseCase;
  final TopupSubscriptionUseCase topupSubscriptionUseCase;

  ConnectivityNotifier({
    required this.getPlansUseCase,
    required this.getSubscriptionsUseCase,
    required this.subscribeToPlanUseCase,
    required this.topupSubscriptionUseCase,
  }) : super(const ConnectivityState());

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plans = await getPlansUseCase();
      state = state.copyWith(plans: plans, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des forfaits: ${e.toString()}',
      );
    }
  }

  Future<void> loadUserSubscriptions(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subscriptions = await getSubscriptionsUseCase(userId);
      state = state.copyWith(subscriptions: subscriptions, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des abonnements: ${e.toString()}',
      );
    }
  }

  Future<bool> subscribeToPlan({
    required String userId,
    required String planId,
    String? esimEid,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subscription = await subscribeToPlanUseCase(
        userId: userId,
        planId: planId,
        esimEid: esimEid,
      );

      // Add to subscriptions list
      final updatedSubscriptions = [...state.subscriptions, subscription];
      state = state.copyWith(
        subscriptions: updatedSubscriptions,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'abonnement: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> topupSubscription({
    required String subscriptionId,
    required double amount,
    required int dataMb,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await topupSubscriptionUseCase(
        subscriptionId: subscriptionId,
        amount: amount,
        dataMb: dataMb,
      );

      // Update subscription balance
      final updatedSubscriptions = state.subscriptions.map((sub) {
        if (sub.id == subscriptionId) {
          return sub.copyWith(balanceMb: sub.balanceMb + dataMb);
        }
        return sub;
      }).toList();

      state = state.copyWith(
        subscriptions: updatedSubscriptions,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du rechargement: ${e.toString()}',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final connectivityNotifierProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier(
    getPlansUseCase: ref.watch(getConnectivityPlansUseCaseProvider),
    getSubscriptionsUseCase: ref.watch(getUserSubscriptionsUseCaseProvider),
    subscribeToPlanUseCase: ref.watch(subscribeToPlanUseCaseProvider),
    topupSubscriptionUseCase: ref.watch(topupSubscriptionUseCaseProvider),
  );
});





