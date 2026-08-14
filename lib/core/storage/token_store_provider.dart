import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return SecureTokenStore();
});
