import 'package:bsty/services/in_app.dart/in_app_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../features/auth/services/auth_provider.dart';
import '../features/auth/services/initial_profile_provider.dart';
import '../features/chat_and_call/services/call_provider.dart';
import '../features/chat_and_call/services/chat_provider.dart';
import '../features/people/services/people_provider.dart';
import '../features/people/views/detailed/model/report_dialogue_model.dart';
import '../features/people/views/detailed/provider/report_dialogue_provider.dart';
import '../features/profile/services/edit_profile_provider.dart';
import '../features/settings/pages/manage_earnings/provider/mep_provider.dart';
import '../features/settings/pages/manage_earnings/provider/payment_option_provider.dart';
import '../features/settings/pages/manage_earnings/provider/payout_request_provider.dart';
import '../features/settings/pages/manage_earnings/provider/redeem_transaction_provider.dart';
import '../features/settings/pages/manage_earnings/provider/referred_peeps_provider.dart';
import '../features/settings/pages/refer_and_earn/provider/contact_list_provider.dart';
import '../services/locatoin_provider.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => ContactListProvider()),
  ChangeNotifierProvider(create: (_) => MEPProvider()),
  ChangeNotifierProvider(create: (_) => RedeemTransactionProvider()),
  ChangeNotifierProvider(create: (_) => PayoutRequestProvider()),
  ChangeNotifierProvider(create: (_) => ReferredPeepsProvider()),
  ChangeNotifierProvider(create: (_) => PaymentOptionProvider()),
  ChangeNotifierProvider(create: (_) => InitialProfileProvider()),
  ChangeNotifierProvider(create: (_) => PeopleProvider()),
  ChangeNotifierProvider(create: (_) => CallsProvider()),
  ChangeNotifierProvider(create: (_) => ChatProvider()),
  ChangeNotifierProvider(create: (_) => ReportDialogueProvider()),
  ChangeNotifierProvider(create: (_) => EditProfileProvider()),
  ChangeNotifierProvider(create: (_) => InAppProvider()),
  Provider(create: (_) => LocationProvider()),
  Provider(create: (_) => ReportDialogueModel),
];
