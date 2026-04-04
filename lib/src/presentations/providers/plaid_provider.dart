import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pennywise/src/core/provider/providers.dart';

final plaidLinkProvider = AsyncNotifierProvider<PlaidLinkNotifier, String?>(() {
  return PlaidLinkNotifier();
});

class PlaidLinkNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final tokenRepo = ref.read(tokenRepositoryProvider);

    return await tokenRepo.getAccessToken();
  }

  Future<void> prepareLinkToken() async {

    //Tell UI show a spinner (Will replace the previous state..)
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(financeRepositoryProvider);

      return await repository.getLinkToken();
    });
  }

  Future<void> exchangePublicToken(String publicToken) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(financeRepositoryProvider);
      final accessToken = await repo.exchangePublicToken(publicToken);

      return accessToken;
    });
  }

  Future<void> linkAccount(String publicToken) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(financeRepositoryProvider);
      final tokenRepo = ref.read(tokenRepositoryProvider);

      final accessToken = await repository.exchangePublicToken(publicToken);
      await tokenRepo.saveAccessToken(accessToken);
      return accessToken;
    });
  }
}
