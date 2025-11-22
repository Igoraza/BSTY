import 'dart:io';

class PlanPriceDetails {
  final List<Map<String, dynamic>> payVideo = [
    {
      'id': Platform.isIOS ? '60_video_call' : 'video_call_60',
      'plan': '60',
      'price': 99,
    },
    {'id': 'video_call_120', 'plan': '120', 'price': 182}, // 185
    {'id': 'video_call_240', 'plan': '240', 'price': 315},//315
  ];

  final payAudio = [
    {
      'id': Platform.isIOS ? '60_audio_call' : 'audio_call_60',
      'plan': '60',
      'price': Platform.isIOS ? 33 : 30,  
    }, // 35
    {'id': 'audio_call_120', 'plan': '120', 'price': Platform.isIOS ? 49 : 46}, // 49
    {'id': 'audio_call_240', 'plan': '240', 'price': 74}, // 75
  ];

  final payLikes = [
    {'id': 'like_1', 'plan': '1', 'price': 83}, // 85
    {'id': 'like_3', 'plan': '3', 'price': 140}, // 140
    {'id': 'like_6', 'plan': '6', 'price': 190}, // 190
  ];

  final payBoosts = [
    {'id': 'boost_1', 'plan': '1', 'price': 74}, // 75
    {'id': 'boost_3', 'plan': '3', 'price': 132}, // 135
    {'id': 'boost_6', 'plan': '6', 'price': 182}, // 185
  ];

  final List payOptionsPlus = [
    {'id': 'bsty_plus_1', 'plan': '1', 'price': 199},
    {'id': 'bsty_plus_3', 'plan': '3', 'price': 599},
    {'id': 'bsty_plus_6', 'plan': '6', 'price': 799},
    {'id': 'bsty_plus_12', 'plan': '12', 'price': 999},
  ];

  final List payOptionsPre = [
    {'id': 'bsty_premium_1', 'plan': '1', 'price': 599},
    {'id': 'bsty_premium_3', 'plan': '3', 'price': 799},
    {'id': 'bsty_premium_6', 'plan': '6', 'price': 999},
    {'id': 'bsty_premium_12', 'plan': '12', 'price': 1299},
  ];
}
