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
import 'package:bsty/utils/global_keys.dart';
import 'package:provider/provider.dart';

import '../services/in_app.dart/consumable_store.dart';
import '../services/in_app.dart/in_app_provider.dart';
import '../services/in_app.dart/in_app_sccreen.dart';
import '../utils/theme/colors.dart';
import 'stadium_button.dart';

String _kConsumableId = 'metfie_plus';
// const String _kUpgradeId = 'metfie_plus';
const String _kSilverSubscriptionId = 'metfie_plus';
const String _kGoldSubscriptionId = 'metfie_plus';
// const List<String> _kProductIds = <String>[
//   _kConsumableId,
//   _kUpgradeId,
//   _kSilverSubscriptionId,
//   _kGoldSubscriptionId,
// ];

class BuyPlanDialog extends StatefulWidget {
  final String? title;
  final String img;
  final String desc;
  final String btnText;
  final List paymentList;

  const BuyPlanDialog({
    Key? key,
    this.title,
    required this.img,
    required this.desc,
    required this.btnText,
    required this.paymentList,
  }) : super(key: key);

  @override
  State<BuyPlanDialog> createState() => BuyPlanDialogState();
}

class BuyPlanDialogState extends State<BuyPlanDialog> {
  // final _currentSlide = ValueNotifier<int>(0);
  final _selectedPlan = ValueNotifier<int>(1);

  final bool _kAutoConsume = Platform.isIOS || true;

  final carouselData = [
    {
      'title': 'See who liked you!',
      'image': 'assets/svg/upgrade_dialog/liked_you.svg',
    },
    {
      'title': 'Use super likes !',
      'image': 'assets/svg/upgrade_dialog/super_likes.svg',
    },
    {
      'title': 'Profile Boosts !',
      'image': 'assets/svg/upgrade_dialog/profile_boosts.svg',
    }
  ];

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
  int selectedIndex = -1;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      log('_subscription canceled');
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
    debugPrint(
        'purchaseDetailsList-length---------------${purchaseDetailsList.length}-------------------------');
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('-----------------------------------------');
      debugPrint(
          'localVerificationData  ${purchaseDetails.verificationData.localVerificationData}');
      debugPrint('-----------------------------------------');
      debugPrint(
          'serverVerificationData  ${purchaseDetails.verificationData.serverVerificationData}');
      debugPrint('-----------------------------------------');
      debugPrint(
          'purchase id ${purchaseDetails.purchaseID} productID ${purchaseDetails.productID}');
      debugPrint('-----------------------------------------');
      debugPrint(purchaseDetails.status.toString());
      debugPrint(
          "purchaseDetails.error ################${purchaseDetails.error.toString()}");
      debugPrint(
          purchaseDetails.verificationData.localVerificationData.toString());
      debugPrint('-----------------------------------------');
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isLoading = true;
        log('@@@@@@@@@@@@@@@@@@----purchased---pending @ @@@@@@@@@@@@@@@----------------------------------');
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          isLoading = false;
          debugPrint(
              "purchaseDetails.error ################ error ${purchaseDetails.error.toString()}");
          log(purchaseDetails.error.toString());
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          log('@@@@@@@@@@@@@@@@@@----purchased---restored @ @@@@@@@@@@@@@@@----------------------------------');

          debugPrint('----purchased-------------------------------------');
          debugPrint(
              'localVerificationData purchased  ${purchaseDetails.verificationData.localVerificationData}');
          debugPrint('-----purchased------------------------------------');
          debugPrint(
              'serverVerificationData  purchased ${purchaseDetails.verificationData.serverVerificationData}');
          debugPrint('-----------------------------------------');
          debugPrint(
              'purchase id purchased ${purchaseDetails.purchaseID} productID ${purchaseDetails.productID}');
          debugPrint(
              'purchaseDetails.verificationData.serverVerificationData purchased ${purchaseDetails.verificationData.serverVerificationData} productID ${purchaseDetails.productID}');
          debugPrint('----purchased-------------------------------------');
          debugPrint(purchaseDetails.status.toString());
          debugPrint(purchaseDetails.verificationData.localVerificationData
              .toString());
          debugPrint('-----purchased ------------------------------------');
          setState(() {
            isLoading = false;
          });
          // if (purchaseDetails is AppStorePurchaseDetails) {
          //   SKPaymentTransactionWrapper skProduct =
          //       (purchaseDetails as AppStorePurchaseDetails)
          //           .skPaymentTransaction;
          //   debugPrint(
          //       'skProduct.transactionState ${skProduct.transactionState}');
          // }
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
            debugPrint(
                '----purchased---quantity------${quantity['quantity']}----------------------------');
            data = FormData.fromMap({
              'product_id': purchaseDetails.productID,
              'purchase_time': purchaseDetails.purchaseID,
              'purchase_token':
                  purchaseDetails.verificationData.serverVerificationData,
              'quantity': quantity['quantity'],
            });
          }

          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            debugPrint("&&&&&&&&&&&&&&&&&&&&&& ${purchaseDetails.status}");
            deliverProduct(purchaseDetails);

            await inAppProvider.purchaseAndroid(data);
            // break;
            return;
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

  PurchaseDetails _hasUserPurchased(String productID) {
    return _purchases.firstWhere((purchase) => purchase.productID == productID);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // PurchaseDetails purchase = _hasUserPurchased(_kConsumableId);
    // if (purchase.status == PurchaseStatus.purchased) {
    //   return Future<bool>.value(true);
    // }
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
      showSnackBar('Sorry, in-app purchases are currently not available');
      log('initStoreInfo isAvailable ${_products.toString()}');
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
    debugPrint(
        'in app product details ${productDetailResponse.productDetails}');
    debugPrint(
        'initStoreInfo notFoundIDs ${productDetailResponse.notFoundIDs.toString()}');
    debugPrint('initStoreInfo isAvailable ${isAvailable.toString()}');

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

      log('initStoreInfo productDetailResponse error ${productDetailResponse.toString()}');

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
      insetPadding: EdgeInsets.symmetric(horizontal: authPro.isTab ? 80 : 20),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: mq.width * 0.05),
        decoration: const BoxDecoration(gradient: AppColors.grayBlackH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.title != null)
              Text(
                widget.title!,
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
                  widget.img,
                  height: mq.height * 0.1,
                ),
                SizedBox(height: mq.height * 0.01),
                Text(
                  widget.desc,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
            // const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: carouselData.map((e) {
            //     final index = carouselData.indexOf(e);
            //     return ValueListenableBuilder(
            //       valueListenable: _currentSlide,
            //       builder: (context, value, child) => Container(
            //         width: 6,
            //         height: 6,
            //         margin: const EdgeInsets.all(4),
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           color: _currentSlide.value == index
            //               ? AppColors.white
            //               : AppColors.disabled,
            //         ),
            //       ),
            //     );
            //   }).toList(),
            // ),
            SizedBox(height: mq.height * 0.03),
            ValueListenableBuilder(
                valueListenable: _selectedPlan,
                builder: (context, value, child) {
                  return SizedBox(
                    height: authPro.isTab ? 300 : 180,
                    width: mq.width * 1,
                    child:
                        // _loading
                        //     ? const Center(child: mainLoadingAnimationLight)
                        //     :
                        ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.paymentList.length,
                      itemBuilder: (context, index) {
                        final value = widget.paymentList;
                        // String price = _products[index].rawPrice.toString();
                        // //  value[index]['price'];
                        // log('in app ${_products[index].rawPrice}');

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  // if (_products.isNotEmpty) {
                                  // _products.sort(
                                  //   (a, b) => a.rawPrice.compareTo(b.rawPrice),
                                  // );

                                  // selectedProduct = _products[index];
                                  _selectedPlan.value = index;
                                  // _kConsumableId = _products[index].id;
                                  _kConsumableId = widget
                                      .paymentList[_selectedPlan.value]['id'];
                                  // } else {
                                  //   navigatorKey.currentState!.pop();
                                  //   showSnackBar('Something went wrong!');
                                  // }
                                },
                                child: Container(
                                  height: mq.height * 0.24,
                                  width: authPro.isTab
                                      ? mq.width * .25
                                      : mq.width * .35,
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(14)),
                                    border: Border.all(
                                      color: _selectedPlan.value == index
                                          ? AppColors.deepOrange
                                          : AppColors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        value[index]['plan'],
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(
                                              color: AppColors.white,
                                            ),
                                      ),
                                      Text(
                                        widget.title != null
                                            ? widget.title!
                                            : 'Minutes',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'USD ${value[index]['price']} !',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.deepOrange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Text(
                                      //   'MK${value[index]['price']}/Month',
                                      //   textAlign: TextAlign.center,
                                      //   style: const TextStyle(
                                      //     color: AppColors.deepOrange,
                                      //     fontSize: 10,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                    ],
                                    // ),
                                  ),
                                ),
                              ),
                            ),
                            if (index == 1)
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: mq.height * 0.02,
                                  width: mq.width * 0.16,
                                  decoration: const BoxDecoration(
                                      color: AppColors.deepOrange,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Center(
                                    child: Text(
                                      'Popular',
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
                          ],
                        );
                      },
                    ),
                  );
                }),
            // );
            // }),
            SizedBox(height: mq.height * 0.05),
            StadiumButton(
              visualDensity: VisualDensity.adaptivePlatformDensity,
              // margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              gradient: AppColors.orangeYelloH,
              onPressed: () async {
                debugPrint(
                    '-----------------------------------------====== $_kConsumableId');
                if (isLoading) {
                  debugPrint('-----------------------------');
                  return;
                }
                setState(() {
                  isLoading = true;
                });
                if (_selectedPlan.value == -1) {
                  navigatorKey.currentState!.pop();
                  showSnackBar('Please select a plan');
                  isLoading = false;
                  return;
                }
                // restore purchases for ios test case
                // await _inAppPurchase.restorePurchases();
                await initStoreInfo(
                    {widget.paymentList[_selectedPlan.value]['id']});
                if (_notFoundIds.isNotEmpty &&
                    _notFoundIds[0] ==
                        widget.paymentList[_selectedPlan.value]['id']) {
                  navigatorKey.currentState!.pop();
                  showSnackBar(
                      'We\'re sorry, but the requested in-app purchase is not available.');
                  isLoading = false;
                  return;
                }
                if (_products.isEmpty) {
                  navigatorKey.currentState!.pop();
                  showSnackBar('The product is not available right now !');
                  isLoading = false;
                  return;
                }
                // showPaymentNotAvailableDialog();
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

                _inAppPurchase.buyConsumable(
                    purchaseParam: purchaseParam, autoConsume: _kAutoConsume);
                log('consumable');

                isLoading = false;
              },
              child: isLoading
                  ? const SizedBox(width: 60, child: BtnLoadingAnimation())
                  // ? SizedBox(
                  //     height: mq.height * 0.01,
                  //     width: authPro.isTab ? mq.height * 0.03 : mq.width * 0.06,
                  //     child:
                  //  const CircularProgressIndicator(
                  //   color: AppColors.white,
                  //   strokeWidth: 2,
                  // ),
                  // )
                  : Text(widget.btnText),
            )
          ],
        ),
      ),
    );
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
}
