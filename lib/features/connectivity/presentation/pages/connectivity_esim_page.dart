import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../auth/presentation/providers/passport_auth_provider.dart';
import '../../data/models/connectivity_plan_model.dart';
import '../../data/models/connectivity_subscription_model.dart';
import '../providers/connectivity_provider.dart';

class ConnectivityEsimPage extends ConsumerStatefulWidget {
  const ConnectivityEsimPage({super.key});

  @override
  ConsumerState<ConnectivityEsimPage> createState() => _ConnectivityEsimPageState();
}

class _ConnectivityEsimPageState extends ConsumerState<ConnectivityEsimPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(connectivityNotifierProvider.notifier).loadPlans();

      final authState = ref.read(authNotifierProvider);
      final userId = authState.pilgrimProfile?.id;
      if (userId != null) {
        ref.read(connectivityNotifierProvider.notifier).loadUserSubscriptions(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet & eSIM'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Forfaits', icon: Icon(Icons.sim_card)),
            Tab(text: 'Mes Abonnements', icon: Icon(Icons.wifi)),
          ],
        ),
      ),
      body: connectivityState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : connectivityState.error != null
              ? _buildErrorWidget(connectivityState.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlansTab(connectivityState.plans),
                    _buildSubscriptionsTab(connectivityState.subscriptions),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(connectivityNotifierProvider.notifier).loadPlans();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab(List<ConnectivityPlanModel> plans) {
    if (plans.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun forfait disponible'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(),
        const SizedBox(height: 16),
        ...plans.where((plan) => plan.isActive).map((plan) => _PlanCard(
              plan: plan,
              onSubscribe: () => _showSubscribeDialog(plan),
            )),
      ],
    );
  }

  Widget _buildSubscriptionsTab(List<ConnectivitySubscriptionModel> subscriptions) {
    if (subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sim_card_alert, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Aucun abonnement actif'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.add),
              label: const Text('Souscrire à un forfait'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: subscriptions.map((subscription) => _SubscriptionCard(
            subscription: subscription,
            onTopup: () => _showTopupDialog(subscription),
          )).toList(),
    );
  }

  void _showSubscribeDialog(ConnectivityPlanModel plan) {
    final esimController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Souscrire au forfait'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forfait: ${plan.name}'),
            Text('Données: ${plan.dataGb} GB'),
            Text('Prix: ${plan.price.toStringAsFixed(2)} SAR'),
            const SizedBox(height: 16),
            TextField(
              controller: esimController,
              decoration: const InputDecoration(
                labelText: 'EID eSIM (optionnel)',
                hintText: 'Ex: 89033023425479790123456',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final authState = ref.read(authNotifierProvider);
              final userId = authState.pilgrimProfile?.id;
              if (userId == null) {
                _showSnackBar('Utilisateur non connecté', isError: true);
                return;
              }

              final success = await ref.read(connectivityNotifierProvider.notifier).subscribeToPlan(
                    userId: userId,
                    planId: plan.id,
                    esimEid: esimController.text.trim().isNotEmpty ? esimController.text.trim() : null,
                  );

              if (success) {
                _showSnackBar('Abonnement créé avec succès !');
                _tabController.animateTo(1);
              } else {
                final error = ref.read(connectivityNotifierProvider).error;
                _showSnackBar(error ?? 'Erreur lors de l\'abonnement', isError: true);
              }
            },
            child: const Text('Souscrire'),
          ),
        ],
      ),
    );
  }

  void _showTopupDialog(ConnectivitySubscriptionModel subscription) {
    final topupOptions = [
      {'gb': 1, 'price': 50.0},
      {'gb': 3, 'price': 120.0},
      {'gb': 5, 'price': 180.0},
      {'gb': 10, 'price': 300.0},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recharger le forfait'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: topupOptions
              .map((option) => ListTile(
                    leading: const Icon(Icons.data_usage, color: AppColors.primary),
                    title: Text('${option['gb']} GB'),
                    subtitle: Text('${option['price']} SAR'),
                    onTap: () async {
                      Navigator.of(context).pop();

                      final success = await ref.read(connectivityNotifierProvider.notifier).topupSubscription(
                            subscriptionId: subscription.id!,
                            amount: option['price'] as double,
                            dataMb: ((option['gb'] as int) * 1024),
                          );

                      if (success) {
                        _showSnackBar('Rechargement effectué avec succès !');
                      } else {
                        final error = ref.read(connectivityNotifierProvider).error;
                        _showSnackBar(error ?? 'Erreur lors du rechargement', isError: true);
                      }
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}

// Info Banner Widget
class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.secondary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Internet & eSIM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Restez connecté pendant votre pèlerinage avec nos forfaits internet et eSIM.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Plan Card Widget
class _PlanCard extends StatelessWidget {
  final ConnectivityPlanModel plan;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.plan,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.sim_card,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        plan.partner,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFeature(Icons.data_usage, '${plan.dataGb} GB'),
                _buildFeature(Icons.attach_money, '${plan.price.toStringAsFixed(0)} SAR'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSubscribe,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Souscrire'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// Subscription Card Widget
class _SubscriptionCard extends StatelessWidget {
  final ConnectivitySubscriptionModel subscription;
  final VoidCallback onTopup;

  const _SubscriptionCard({
    required this.subscription,
    required this.onTopup,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = subscription.isActive ? Colors.green : Colors.orange;
    final statusText = subscription.status.name.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.planName ?? 'Forfait eSIM',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subscription.esimEid != null)
                        Text(
                          'EID: ${subscription.esimEid}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solde restant',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subscription.balanceGb.toStringAsFixed(2)} GB',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: subscription.isActive ? onTopup : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Recharger'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


