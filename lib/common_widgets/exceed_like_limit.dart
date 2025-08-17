// ignore_for_file: unused_field, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:bsty/common_widgets/loading_animations.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/utils/functions.dart';
import 'package:provider/provider.dart';

import '../services/in_app.dart/consumable_store.dart';
import '../services/in_app.dart/in_app_provider.dart';
import '../services/in_app.dart/in_app_sccreen.dart';
import '../utils/constants/plan_price_details.dart';
import '../utils/global_keys.dart';
import '../utils/theme/colors.dart';
import 'stadium_button.dart';

String _kConsumableId = 'boost_1';
// ignore: unused_element
const String _kUpgradeId = 'metfie_plus';
const String _kSilverSubscriptionId = 'metfie_plus';
const String _kGoldSubscriptionId = 'metfie_plus';

class ExceedLikeDialog extends StatefulWidget {
  const ExceedLikeDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ExceedLikeDialog> createState() => ExceedLikeDialogState();
}

class ExceedLikeDialogState extends State<ExceedLikeDialog> {
  final _currentSlide = ValueNotifier<int>(0);
  final _selectedPlan = ValueNotifier<int>(1);

  // final Map<String, int> payOptionsPlus = {
  //   '1': 2999,
  //   '3': 6999,
  //   '6': 10999,
  //   '12': 19999,
  // };

  final bool _kAutoConsume = Platform.isIOS || true;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;

  bool isLoading = false;

  ProductDetails? selectedProduct;

  final PlanPriceDetails planPriceDet = PlanPriceDetails();

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    // initStoreInfo();
    super.initState();
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    final inAppProvider = context.read<InAppProvider>();
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      log('-----------------------------------------');
      log('localVerificationData  ${purchaseDetails.verificationData.localVerificationData}');
      log('-----------------------------------------');
      log('serverVerificationData  ${purchaseDetails.verificationData.serverVerificationData}');
      log('-----------------------------------------');
      log('purchase id ${purchaseDetails.purchaseID} productID ${purchaseDetails.productID}');
      log('-----------------------------------------');
      log(purchaseDetails.status.toString());
      log(purchaseDetails.verificationData.toString());
      log('-----------------------------------------');
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isLoading = true;
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          isLoading = false;
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            isLoading = false;
          });
          FormData? data;
          if (purchaseDetails is AppStorePurchaseDetails) {
            // SKPaymentTransactionWrapper skProduct =
            //     (purchaseDetails as AppStorePurchaseDetails)
            //         .skPaymentTransaction;
            final AppStorePurchaseDetails appStorePurchaseDetails =
                purchaseDetails as AppStorePurchaseDetails;

            // Access properties of AppStorePurchaseDetails
            final String? transactionId = appStorePurchaseDetails.purchaseID;
            final String originalTransactionId = appStorePurchaseDetails
                .skPaymentTransaction.transactionIdentifier
                .toString();
            final String productIdentifier = appStorePurchaseDetails.productID;
            final String verificationData = appStorePurchaseDetails
                .verificationData.serverVerificationData
                .toString();
            final String quantity = appStorePurchaseDetails
                .skPaymentTransaction.payment.quantity
                .toString();
            final String transactionDate =
                appStorePurchaseDetails.transactionDate.toString();
            debugPrint(
                '-----transactionId $transactionId \n ----originalTransactionId $originalTransactionId \n---productIdentifier $productIdentifier \n-----verificationData $verificationData  \n--------quantity$quantity\n ---transactionDate$transactionDate');
            // ...

            // Handle the app store purchase details and perform necessary actions
            // Remember to consume or acknowledge the purchase to avoid repurchasing

            // log(skProduct.payment.toString());
            data = FormData.fromMap({
              'product_id': productIdentifier,
              'purchase_time': originalTransactionId,
              'purchase_token': verificationData,
              'quantity': quantity,
            });
          } else {
            dynamic quantity = jsonDecode(
                purchaseDetails.verificationData.localVerificationData);
            data = FormData.fromMap({
              'product_id': purchaseDetails.productID,
              'purchase_time': purchaseDetails.purchaseID,
              'purchase_token':
                  purchaseDetails.verificationData.serverVerificationData,
              'quantity': quantity['quantity'],
            });
          }

          // final inappProvider = context.read<InAppProvider>();
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
            await inAppProvider.purchaseAndroid(data);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          log(purchaseDetails.status.toString());
          setState(() {
            isLoading = false;
          });
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      final List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  Future<void> initStoreInfo(Set<String> identifiers) async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(identifiers);
    log('in app product details ${productDetailResponse.productDetails}');
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final authPro = context.read<AuthProvider>();

    // if (Platform.isIOS) {
    //   return Dialog(
    //     child: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Text(
    //             "This feature is not available in your profile !",
    //             textAlign: TextAlign.center,
    //             style: Theme.of(context).textTheme.titleMedium,
    //           ),
    //           const SizedBox(height: 20),
    //           StadiumButton(
    //             text: 'Ok',
    //             bgColor: AppColors.black,
    //             onPressed: () => Navigator.of(context).pop(),
    //           )
    //         ],
    //       ),
    //     ),
    //   );
    // }
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: mq.width * 0.05),
        decoration: const BoxDecoration(gradient: AppColors.grayBlackH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Exceeded the liking limit!',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: AppColors.white, fontSize: 20),
            ),
            SizedBox(height: mq.height * 0.01),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/upgrade_dialog/like_limit.svg',
                  height: mq.height * 0.1,
                ),
                SizedBox(height: mq.height * 0.02),
                Text(
                  "You've hit the liking limit.\nWait 12 hrs\nor upgrade for unlimited access.",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // const SizedBox(height: 20),
            SizedBox(height: mq.height * 0.05),
            SizedBox(
              height: authPro.isTab ? 200 : 140,
              width: authPro.isTab ? mq.width * .8 : mq.width * 2,
              child: ValueListenableBuilder(
                  valueListenable: _selectedPlan,
                  builder: (context, value, child) {
                    return ListView.builder(
                      itemCount: planPriceDet.payOptionsPlus.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        // String price = _products[index].rawPrice.toString();
                        // log(_products[index].id.toString());
                        return GestureDetector(
                          onTap: () {
                            // if (_products.isNotEmpty) {
                            //   _products.sort(
                            //     (a, b) => a.rawPrice.compareTo(b.rawPrice),
                            //   );
                            _selectedPlan.value = index;
                            //   selectedProduct = _products[index];
                            // } else {
                            //   navigatorKey.currentState!.pop();
                            //   showSnackBar('Something went wrong!');
                            // }
                          },
                          child: Container(
                            height: mq.height * 0.23,
                            width:
                                authPro.isTab ? mq.width * .2 : mq.width * .24,
                            padding: EdgeInsets.symmetric(
                                vertical: index == 1 ? 0 : 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedPlan.value == index
                                    ? AppColors.deepOrange
                                    : AppColors.black,
                                width: _selectedPlan.value == index ? 3 : 1,
                              ),
                              color: AppColors.white,
                            ),
                            child: Column(
                              children: [
                                if (index == 1)
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      height: mq.height * 0.02,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: AppColors.deepOrange,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Most popular',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.white,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (authPro.isTab)
                                  SizedBox(
                                    height: mq.height * 0.02,
                                  ),
                                Text(
                                  planPriceDet.payOptionsPlus[index]['plan']
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(
                                        color: AppColors.black,
                                      ),
                                ),
                                Text(
                                  'Months',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'USD ${planPriceDet.payOptionsPlus[index]['price']}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
            SizedBox(height: mq.height * 0.05),
            StadiumButton(
              visualDensity: VisualDensity.adaptivePlatformDensity,
              gradient: AppColors.orangeYelloH,
              onPressed: () async {
                if (isLoading) {
                  return;
                }
                // if (Platform.isIOS) {
                //   showPaymentNotAvailableDialog();
                //   return;
                // }
                setState(() {
                  isLoading = true;
                });
                // showPaymentNotAvailableDialog();
                if (_selectedPlan.value == -1) {
                  navigatorKey.currentState!.pop();
                  showSnackBar('Please select a plan');
                  return;
                }

                await initStoreInfo(
                    {planPriceDet.payOptionsPlus[_selectedPlan.value]['id']});
                if (_notFoundIds.isNotEmpty &&
                    _notFoundIds[0] ==
                        planPriceDet.payOptionsPlus[_selectedPlan.value]
                            ['id']) {
                  navigatorKey.currentState!.pop();
                  showSnackBar(
                      'We\'re sorry, but the requested in-app purchase is not available.');
                  isLoading = false;
                  return;
                }
                if (_products.isEmpty) {
                  navigatorKey.currentState!.pop();
                  showSnackBar('Something went wrong!,Please try again');
                  isLoading = false;
                  return;
                }
                late PurchaseParam purchaseParam;
                log(' in app purchase ---------');

                final Map<String, PurchaseDetails> purchases =
                    Map<String, PurchaseDetails>.fromEntries(
                        _purchases.map((PurchaseDetails purchase) {
                  if (purchase.pendingCompletePurchase) {
                    _inAppPurchase.completePurchase(purchase);
                  }

                  return MapEntry<String, PurchaseDetails>(
                      purchase.productID, purchase);
                }));

                log('purchases ${purchases.toString()}');

                if (Platform.isAndroid) {
                  // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
                  // verify the latest status of you your subscription by using server side receipt validation
                  // and update the UI accordingly. The subscription purchase status shown
                  // inside the app may not be accurate.

                  log(' in app purchase');
                  final GooglePlayPurchaseDetails? oldSubscription =
                      _getOldSubscription(_products.first, purchases);
                  log(purchases.toString());
                  purchaseParam = GooglePlayPurchaseParam(
                      productDetails: _products.first,
                      changeSubscriptionParam: (oldSubscription != null)
                          ? ChangeSubscriptionParam(
                              oldPurchaseDetails: oldSubscription,
                              // prorationMode:
                              //     ProrationMode.immediateWithTimeProration,
                            )
                          : null);
                  log(purchaseParam.applicationUserName.toString());
                } else {
                  purchaseParam = PurchaseParam(
                    productDetails: _products.first,
                  );
                }

                // if (selectedProduct!.id == _kConsumableId) {
                //   _inAppPurchase.buyConsumable(
                //       purchaseParam: purchaseParam, autoConsume: _kAutoConsume);
                //   log('consumable');
                // } else {
                _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                log('non consumable');
                // }
                isLoading = false;
              },
              child: isLoading
                  ? const SizedBox(width: 60, child: BtnLoadingAnimation())
                  // ? SizedBox(
                  //     height: mq.height * 0.03,
                  //     width: authPro.isTab ? mq.height * 0.03 : mq.width * 0.06,
                  //     child: const CircularProgressIndicator(
                  //       color: AppColors.white,
                  //       strokeWidth: 2,
                  //     ),
                  //   )
                  : const Text('Subscribe Now'),
            )
          ],
        ),
      ),
    );
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == _kSilverSubscriptionId &&
        purchases[_kGoldSubscriptionId] != null) {
      oldSubscription =
          purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == _kGoldSubscriptionId &&
        purchases[_kSilverSubscriptionId] != null) {
      oldSubscription =
          purchases[_kSilverSubscriptionId]! as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }

  void showPaymentNotAvailableDialog() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Payment option is not currently available. We'll be adding it soon",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    StadiumButton(
                      text: 'Ok',
                      bgColor: AppColors.black,
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
            ));
  }
}
