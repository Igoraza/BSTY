// ignore_for_file: unused_field, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:bsty/common_widgets/loading_animations.dart';
import 'package:bsty/services/in_app.dart/in_app_provider.dart';
import 'package:bsty/utils/constants/plan_price_details.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../features/auth/services/auth_provider.dart';
import '../services/in_app.dart/consumable_store.dart';
import '../services/in_app.dart/in_app_sccreen.dart';
import '../utils/functions.dart';
import '../utils/theme/colors.dart';
import 'stadium_button.dart';

String _kConsumableId = 'boost_1';
// const String _kUpgradeId = 'bsty_plus';
const String _kSilverSubscriptionId = 'bsty_plus_1';
const String _kGoldSubscriptionId = 'bsty_premium_1';

class UpgradePlanScreen extends StatefulWidget {
  final String? title;
  static const String routeName = "/upgrade_plan_screen";
  const UpgradePlanScreen({Key? key, this.title}) : super(key: key);

  @override
  State<UpgradePlanScreen> createState() => UpgradePlanScreenState();
}

class UpgradePlanScreenState extends State<UpgradePlanScreen> {
  final _currentSlide = ValueNotifier<int>(0);
  final _selectedPlan = ValueNotifier<int>(1);

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
  int selectedIndex = 1; // Default to 3-month plan (most popular)

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (Object error) {
        // handle error here.
      },
    );
    super.initState();
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    final inAppProvider = context.read<InAppProvider>();
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      log('-----------------------------------------');
      log(
        'localVerificationData  ${purchaseDetails.verificationData.localVerificationData}',
      );
      log('-----------------------------------------');
      log(
        'serverVerificationData  ${purchaseDetails.verificationData.serverVerificationData}',
      );
      log('-----------------------------------------');
      log(
        'purchase id ${purchaseDetails.purchaseID} productID ${purchaseDetails.productID}',
      );
      log('-----------------------------------------');
      log(purchaseDetails.status.toString());
      log(purchaseDetails.verificationData.toString());
      log('-----------------------------------------');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          isLoading = true;
        });
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() {
            isLoading = false;
          });
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            isLoading = false;
          });

          FormData? data;
          if (purchaseDetails is AppStorePurchaseDetails) {
            final AppStorePurchaseDetails appStorePurchaseDetails =
                purchaseDetails as AppStorePurchaseDetails;

            final String? transactionId = appStorePurchaseDetails.purchaseID;
            final String originalTransactionId = appStorePurchaseDetails
                .skPaymentTransaction
                .transactionIdentifier
                .toString();
            final String productIdentifier = appStorePurchaseDetails.productID;
            final String verificationData = appStorePurchaseDetails
                .verificationData
                .serverVerificationData
                .toString();
            final String quantity = appStorePurchaseDetails
                .skPaymentTransaction
                .payment
                .quantity
                .toString();
            final String transactionDate = appStorePurchaseDetails
                .transactionDate
                .toString();

            debugPrint(
              '-----transactionId $transactionId \n ----originalTransactionId $originalTransactionId \n---productIdentifier $productIdentifier \n-----verificationData $verificationData  \n--------quantity$quantity\n ---transactionDate$transactionDate',
            );

            data = FormData.fromMap({
              'product_id': productIdentifier,
              'purchase_time': originalTransactionId,
              'purchase_token': verificationData,
              'quantity': quantity,
            });
          } else {
            dynamic quantity = jsonDecode(
              purchaseDetails.verificationData.localVerificationData,
            );
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
            await deliverProduct(purchaseDetails);
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
            final InAppPurchaseAndroidPlatformAddition
            androidAddition = _inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
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
    showSnackBar('Purchase failed: ${error.message}');
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if _verifyPurchase` failed.
    showSnackBar('Invalid purchase');
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

    // Navigate back and show success message
    if (mounted) {
      Navigator.pop(context);
      showSnackBar('Purchase successful!');
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

    final ProductDetailsResponse productDetailResponse = await _inAppPurchase
        .queryProductDetails(identifiers);
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

  GooglePlayPurchaseDetails? _getOldSubscription(
    ProductDetails productDetails,
    Map<String, PurchaseDetails> purchases,
  ) {
    // Look through all current subscriptions to find an active one
    for (final purchase in purchases.values) {
      if (purchase is GooglePlayPurchaseDetails &&
          purchase.productID != productDetails.id &&
          purchase.status == PurchaseStatus.purchased) {
        return purchase; // Found an old subscription to replace
      }
    }
    return null; // No active subscription found
  }

  // GooglePlayPurchaseDetails? _getOldSubscription(
  //   ProductDetails productDetails,
  //   Map<String, PurchaseDetails> purchases,
  // ) {
  //   GooglePlayPurchaseDetails? oldSubscription;
  //   if (productDetails.id == _kSilverSubscriptionId &&
  //       purchases[_kGoldSubscriptionId] != null) {
  //     oldSubscription =
  //         purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
  //   } else if (productDetails.id == _kGoldSubscriptionId &&
  //       purchases[_kSilverSubscriptionId] != null) {
  //     oldSubscription =
  //         purchases[_kSilverSubscriptionId]! as GooglePlayPurchaseDetails;
  //   }
  //   return oldSubscription;
  // }

  List<dynamic> get _currentPlans {
    log("Plan --: ${widget.title}");
    if (widget.title == "Premium") {
      return planPriceDet.payOptionsPre;
    } else if (widget.title == "Plus") {
      return planPriceDet.payOptionsPlus;
    } else if (widget.title == "Boost") {
      return planPriceDet.payBoosts;
    } else if (widget.title == "Like") {
      return planPriceDet.payLikes;
    } else if (widget.title == "Minutes") {
      return planPriceDet.payAudio;
    }
    return planPriceDet.payOptionsPre;
    // return widget.title != null
    //     ? planPriceDet.payOptionsPre
    //     : planPriceDet.payOptionsPlus;
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
    final screenSize = MediaQuery.of(context).size;
    final authPro = context.read<AuthProvider>();
    log("Current selected plan : ${widget.title}");
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(height: screenSize.height),
          Image(
            image: AssetImage("assets/images/upgrade_membership_bg.png"),
            fit: BoxFit.cover,
            height: screenSize.height * 0.74,
          ),
          Positioned(
            top: 40,
            right: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Icon(Icons.close_rounded, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: screenSize.width,
              height: screenSize.height * 0.38,
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedIndex = 0;
                          }),
                          child: PlanCard(
                            isSelected: selectedIndex == 0,
                            selectedIndex: 0,
                            planData: _currentPlans[0],
                            planTitle: widget.title,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedIndex = 1;
                          }),
                          child: PlanCard(
                            isSelected: selectedIndex == 1,
                            selectedIndex: 1,
                            planData: _currentPlans[1],
                            showPopularBadge: true,
                            planTitle: widget.title,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (_currentPlans.length == 4)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              selectedIndex = 2;
                            }),
                            child: PlanCard(
                              isSelected: selectedIndex == 2,
                              selectedIndex: 2,
                              planData: _currentPlans[2],
                              planTitle: widget.title,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              selectedIndex = 3;
                            }),
                            child: PlanCard(
                              isSelected: selectedIndex == 3,
                              selectedIndex: 3,
                              planData: _currentPlans[3],
                              planTitle: widget.title,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          selectedIndex = 2;
                        }),
                        child: PlanCard(
                          isSelected: selectedIndex == 2,
                          selectedIndex: 2,
                          planData: _currentPlans[2],
                          planTitle: widget.title,
                          alignCenter: true,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  // Add this diagnostic method to your class

                  // Enhanced button with diagnostics
                  StadiumButton(
                    height: 55,
                    width: double.infinity,
                    // textColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () async {
                      _startPurchase();
                    },
                    // gradient: AppColors.pinkPurpleHw,
                    gradient: AppColors.pinkPurpleH,
                    // gradient: LinearGradient(
                    //   colors: [
                    //     Color.fromARGB(192, 233, 64, 145),

                    //     Color.fromARGB(160, 123, 80, 160),
                    //   ],
                    // ),
                    child: (isLoading || _purchasePending)
                        ? SizedBox(width: 60, child: BtnLoadingAnimation())
                        : Text('Subscribe Now'),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startPurchase() async {
    log(">>>>>>>>>>>Starting purchase");
    // Run diagnostics first if store is not available
    if (!await _inAppPurchase.isAvailable()) {
      log('Store not available - running diagnostics...');
      await _runIAPDiagnostics();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Store Connection Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Common solutions:'),
              SizedBox(height: 8),
              Text('• Upload app to Play Console/App Store Connect'),
              Text('• Use real device (not simulator)'),
              Text('• Check internet connection'),
              Text('• Update Google Play Store/App Store'),
              Text('• Sign in with correct Google account'),
              Text('• Verify product IDs match store console'),
              SizedBox(height: 8),
              Text('Check console logs for detailed diagnostics.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Original purchase logic (your existing code)
    if (isLoading || _purchasePending) {
      log(
        'DEBUG: Purchase blocked - isLoading: $isLoading, _purchasePending: $_purchasePending',
      );
      return;
    }

    if (selectedIndex == -1) {
      log('DEBUG: No plan selected');
      showSnackBar('Please select a plan');
      return;
    }

    setState(() => isLoading = true);
    log('>>>>>>>>> DEBUG: Starting purchase process...');

    try {
      // Step 1: Get plan details
      final planList = widget.title == "Plus"
          ? planPriceDet.payOptionsPlus
          : planPriceDet.payOptionsPre;

      if (planList.isEmpty) {
        throw Exception('Plan list is empty');
      }

      if (selectedIndex >= planList.length) {
        throw Exception(
          'Selected index ($selectedIndex) is out of bounds for plan list (length: ${planList.length})',
        );
      }

      final String planId = planList[selectedIndex]['id'];
      log('DEBUG: Selected plan ID: $planId');

      // Step 2: Check store availability FIRST
      print('DEBUG: Checking store availability...');
      bool isStoreAvailable = await _inAppPurchase.isAvailable();
      log('DEBUG: Store available: $isStoreAvailable');

      if (!isStoreAvailable) {
        // Try to reconnect/retry
        print('DEBUG: Store not available, attempting to reconnect...');
        await Future.delayed(Duration(milliseconds: 500));
        isStoreAvailable = await _inAppPurchase.isAvailable();
        print('DEBUG: Store available after retry: $isStoreAvailable');

        if (!isStoreAvailable) {
          throw Exception(
            'Store is not available. Please check your internet connection and ensure Google Play Store/App Store is properly installed and updated.',
          );
        }
      }

      // Step 3: Initialize store info
      log('>>>>>>>>>>>> DEBUG: Initializing store info for plan: $planId');
      await initStoreInfo({planId});
      print('DEBUG: Store info initialized');

      // Step 4: Check if plan was not found
      if (_notFoundIds.isNotEmpty) {
        log('>>>>>>>>>>>>>>>>DEBUG: Plan not found in store. Not found IDs: $_notFoundIds');
        if (_notFoundIds.contains(planId)) {
          Navigator.pop(context);
          showSnackBar(
            'The subscription plan "$planId" is not available in your region or has been removed from the store.',
          );
          return;
        }
      }

      // Step 5: Check if products are available
      if (_products.isEmpty) {
        log('DEBUG: No products available after store initialization');
        log('DEBUG: _notFoundIds: $_notFoundIds');
        log(
          'DEBUG: Current store connection: ${await _inAppPurchase.isAvailable()}',
        );
        print('DEBUG: Requested plan ID: $planId');

        // Check if the plan ID exists in your store console
        Navigator.pop(context);
        showSnackBar(
          'Subscription not available. Please ensure the plan ID "$planId" exists in your store console and is published.',
        );
        return;
      }

      log('>>>>>>>>>> //////////// DEBUG: Products available: ${_products.length}');
      for (int i = 0; i < _products.length; i++) {
        final product = _products[i];
        print(
          'DEBUG: Product $i - ID: ${product.id}, Title: ${product.title}, Price: ${product.price}',
        );
      }

      // Step 6: Check existing purchases
      print(
        'DEBUG: Checking existing purchases. Total purchases: ${_purchases.length}',
      );
      final Map<String, PurchaseDetails>
      purchases = Map<String, PurchaseDetails>.fromEntries(
        _purchases.map((purchase) {
          print(
            'DEBUG: Existing purchase - ID: ${purchase.productID}, Status: ${purchase.status}, Pending: ${purchase.pendingCompletePurchase}',
          );

          if (purchase.pendingCompletePurchase) {
            print('DEBUG: Completing pending purchase: ${purchase.productID}');
            _inAppPurchase.completePurchase(purchase);
          }
          return MapEntry(purchase.productID, purchase);
        }),
      );

      // Step 7: Check if user already owns this product
      if (purchases.containsKey(planId)) {
        final existingPurchase = purchases[planId]!;
        log(
          '|||||||||||||||||||||||| DEBUG: User already owns this product. Status: ${existingPurchase.status}',
        );

        if (existingPurchase.status == PurchaseStatus.purchased) {
          showSnackBar('You already own this subscription');
          return;
        }
      }

      // Step 7: Prepare purchase parameters
      late PurchaseParam purchaseParam;
      final selectedProduct = _products.first;
      print('DEBUG: Preparing purchase for product: ${selectedProduct.id}');

      if (Platform.isAndroid) {
        print('DEBUG: Android platform detected');
        final GooglePlayPurchaseDetails? oldSubscription = _getOldSubscription(
          selectedProduct,
          purchases,
        );

        if (oldSubscription != null) {
          log(
            'DEBUG: Found old subscription to replace: ${oldSubscription.productID}',
          );
        } else {
          log('DEBUG: No old subscription found');
        }

        purchaseParam = GooglePlayPurchaseParam(
          productDetails: selectedProduct,
          changeSubscriptionParam: oldSubscription != null
              ? ChangeSubscriptionParam(oldPurchaseDetails: oldSubscription)
              : null,
        );
      } else {
        log('DEBUG: iOS platform detected');
        purchaseParam = PurchaseParam(productDetails: selectedProduct);
      }

      // Step 8: Start purchase (store availability already checked)
      log('DEBUG: Initiating purchase...');
      final bool purchaseResult = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      log('DEBUG: Purchase initiated. Result: ${purchaseResult.toString()}');
      debugPrint('DEBUG: Purchase initiated. Result: $purchaseResult');

      if (!purchaseResult) {
        throw Exception(
          'Failed to initiate purchase - buyNonConsumable returned false',
        );
      }
    } catch (e, stackTrace) {
      log('ERROR: Purchase failed with exception: $e');
      print('ERROR: Stack trace: $stackTrace');

      String errorMessage = 'Purchase failed';

      // Provide specific error messages based on error type
      if (e.toString().contains('BillingResponse.userCanceled')) {
        errorMessage = 'Purchase was cancelled by user';
      } else if (e.toString().contains('BillingResponse.serviceUnavailable')) {
        errorMessage = 'Billing service is unavailable. Please try again later';
      } else if (e.toString().contains('BillingResponse.billingUnavailable')) {
        errorMessage = 'Billing is not available on this device';
      } else if (e.toString().contains('BillingResponse.itemUnavailable')) {
        errorMessage = 'The requested item is not available for purchase';
      } else if (e.toString().contains('BillingResponse.developerError')) {
        errorMessage = 'Purchase configuration error. Please contact support';
      } else if (e.toString().contains('BillingResponse.error')) {
        errorMessage = 'An error occurred during purchase. Please try again';
      } else if (e.toString().contains('BillingResponse.itemAlreadyOwned')) {
        errorMessage = 'You already own this item';
      } else if (e.toString().contains('BillingResponse.itemNotOwned')) {
        errorMessage = 'You don\'t own this item';
      } else if (e.toString().contains('not available')) {
        errorMessage = 'Store is not available. Please check your connection';
      } else if (e.toString().contains('Plan list is empty')) {
        errorMessage = 'No subscription plans available';
      } else if (e.toString().contains('out of bounds')) {
        errorMessage = 'Invalid plan selection. Please try again';
      } else {
        errorMessage = 'Purchase failed: ${e.toString()}';
      }

      showSnackBar(errorMessage);
    } finally {
      print('DEBUG: Purchase process completed, cleaning up...');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runIAPDiagnostics() async {
    print('=== IN-APP PURCHASE DIAGNOSTICS ===');

    // 1. Basic Platform Info
    print('1. PLATFORM INFO:');
    print('   Platform: ${Platform.operatingSystem}');
    print('   Platform version: ${Platform.operatingSystemVersion}');

    // 2. Package Info
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      print('   App package: ${packageInfo.packageName}');
      print('   App version: ${packageInfo.version}');
      print('   Build number: ${packageInfo.buildNumber}');
    } catch (e) {
      print('   Package info error: $e');
    }

    // 3. Network Connectivity
    print('\n2. NETWORK CONNECTIVITY:');
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('   Internet: Connected ✓');
      }
    } catch (e) {
      print('   Internet: Not connected ✗');
      print('   Network error: $e');
    }

    // 4. In-App Purchase Plugin Info
    print('\n3. IAP PLUGIN STATUS:');
    try {
      print('   Plugin initialized: ${_inAppPurchase != null ? "✓" : "✗"}');

      // Test store availability multiple times
      for (int i = 1; i <= 3; i++) {
        print('   Store availability test $i...');
        final isAvailable = await _inAppPurchase.isAvailable();
        print('   Attempt $i: $isAvailable');

        if (i < 3) await Future.delayed(Duration(seconds: 1));
      }
    } catch (e) {
      print('   IAP plugin error: $e');
    }

    // 5. Platform-specific checks
    if (Platform.isAndroid) {
      print('\n4. ANDROID SPECIFIC CHECKS:');
      await _runAndroidDiagnostics();
    } else if (Platform.isIOS) {
      print('\n4. IOS SPECIFIC CHECKS:');
      await _runIOSDiagnostics();
    }

    // 6. Product ID validation
    print('\n5. PRODUCT CONFIGURATION:');
    final planList = widget.title == null
        ? planPriceDet.payOptionsPlus
        : planPriceDet.payOptionsPre;

    log('   Available plans: ${planList.length}');
    for (int i = 0; i < planList.length; i++) {
      print('   Plan $i: ${planList[i]['id']}');
    }

    // 7. Store connection detailed test
    print('\n6. DETAILED STORE CONNECTION TEST:');
    await _testStoreConnection();

    print('=== DIAGNOSTICS COMPLETE ===\n');
  }

  Future<void> _runAndroidDiagnostics() async {
    print('   Checking Google Play Store...');

    // Check if Google Play Store is installed
    try {
      // This is a basic check - you might need to add package_info_plus
      print('   Google Play Store: Checking installation...');

      // Check billing permission (this should be in your AndroidManifest.xml)
      print(
        '   Billing permission: Check AndroidManifest.xml for com.android.vending.BILLING',
      );

      // App signing check
      print(
        '   App signing: Ensure app is signed with upload key from Play Console',
      );
      print(
        '   Play Console: App must be uploaded to Play Console (even as internal test)',
      );
      print(
        '   Test account: Ensure you\'re signed in with a test account added in Play Console',
      );
    } catch (e) {
      print('   Android check error: $e');
    }
  }

  Future<void> _runIOSDiagnostics() async {
    print('   Checking App Store...');

    try {
      print('   App Store Connect: Ensure products are created and approved');
      print('   Bundle ID: Must match exactly with App Store Connect');
      print(
        '   Agreements: Check that paid agreements are active in App Store Connect',
      );
      print(
        '   Simulator: In-app purchases don\'t work on simulator, use real device',
      );
    } catch (e) {
      print('   iOS check error: $e');
    }
  }

  Future<void> _testStoreConnection() async {
    try {
      print('   Testing raw store connection...');

      // Test with a simple product query
      final Set<String> testIds = {'test_product_id'};

      print('   Attempting to query store with test ID...');
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(testIds);

      print('   Query successful: ${response.error == null ? "✓" : "✗"}');
      if (response.error != null) {
        print('   Error details: ${response.error}');
        print('   Error code: ${response.error?.code}');
        print('   Error message: ${response.error?.message}');
        print('   Error source: ${response.error?.source}');
      }

      print('   Products found: ${response.productDetails.length}');
      print('   Not found IDs: ${response.notFoundIDs}');
    } catch (e) {
      print('   Store connection test failed: $e');
    }
  }
}

class PlanCard extends StatelessWidget {
  final bool isSelected;
  final int selectedIndex;
  final Map<String, dynamic> planData;
  final bool showPopularBadge;
  final String? planTitle;
  final bool alignCenter;

  const PlanCard({
    super.key,
    required this.isSelected,
    required this.selectedIndex,
    required this.planData,
    this.showPopularBadge = false,
    this.planTitle,
    this.alignCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final String unit;
    if (planTitle == "Boost") {
      unit = "BOOST";
    } else if (planTitle == "Like") {
      unit = "LIKE";
    } else if (planTitle == "Minute") {
      unit = "MINUTE";
    } else {
      unit = "MONTH";
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: isSelected ? AppColors.pink : Colors.black,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: alignCenter
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                "${planData['plan']} $unit${planData['plan'] == '1' ? '' : 'S'}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.pink : Colors.black,
                ),
              ),
              Text(
                "INR ${planData['price']}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppColors.pink : Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "No free trial",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (showPopularBadge)
          Positioned(
            // left: 0,
            right: 0,
            top: -10,
            child: Center(
              child: Container(
                width: 110,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.deepOrange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    "Most popular",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
