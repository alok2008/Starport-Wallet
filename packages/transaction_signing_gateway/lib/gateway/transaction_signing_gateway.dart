import 'package:dartz/dartz.dart';
import 'package:transaction_signing_gateway/key_info_storage.dart';
import 'package:transaction_signing_gateway/model/credentials_storage_failure.dart';
import 'package:transaction_signing_gateway/model/signed_transaction.dart';
import 'package:transaction_signing_gateway/model/transaction_signing_failure.dart';
import 'package:transaction_signing_gateway/model/unsigned_transaction.dart';
import 'package:transaction_signing_gateway/model/wallet_lookup_key.dart';
import 'package:transaction_signing_gateway/model/wallet_public_info.dart';
import 'package:transaction_signing_gateway/transaction_signer.dart';
import 'package:transaction_signing_gateway/transaction_signing_gateway.dart';
import 'package:transaction_signing_gateway/transaction_summary_ui.dart';
import 'package:transaction_signing_gateway/utils/future_either.dart';

class TransactionSigningGateway {
  final List<TransactionSigner> _signers;
  final KeyInfoStorage _infoStorage;
  final TransactionSummaryUI _transactionSummaryUI;

  TransactionSigningGateway({
    required List<TransactionSigner> signers,
    required KeyInfoStorage infoStorage,
    required TransactionSummaryUI transactionSummaryUI,
  })  : _signers = List.unmodifiable(signers),
        _infoStorage = infoStorage,
        _transactionSummaryUI = transactionSummaryUI;

  Future<Either<CredentialsStorageFailure, Unit>> storeWalletCredentials({
    required PrivateWalletCredentials credentials,
    required String password,
  }) =>
      _infoStorage.savePrivateCredentials(
        walletCredentials: credentials,
        password: password,
      );

  Future<Either<TransactionSigningFailure, SignedTransaction>> signTransaction({
    required UnsignedTransaction transaction,
    required WalletLookupKey walletLookupKey,
  }) async =>
      _transactionSummaryUI
          .showTransactionSummaryUI(transaction: transaction)
          .flatMap(
            (userAccepted) => _infoStorage
                .getPrivateCredentials(walletLookupKey)
                .leftMap((err) => left(StorageProblemSigningFailure(err))),
          )
          .flatMap((privateCreds) async => _findCapableSigner(transaction).sign(
                privateCredentials: privateCreds,
                transaction: transaction,
              ));

  Future<Either<CredentialsStorageFailure, List<WalletPublicInfo>>> getWalletsList() => _infoStorage.getWalletsList();

  Future<Either<TransactionSigningFailure, bool>> verifyLookupKey(WalletLookupKey walletLookupKey) =>
      _infoStorage.verifyLookupKey(walletLookupKey);

  TransactionSigner _findCapableSigner(UnsignedTransaction transaction) => _signers.firstWhere(
        (element) => element.canSign(transaction),
        orElse: () => NotFoundTransactionSigner(),
      );
}
