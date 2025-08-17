import 'dart:io';

class PlanPriceDetails {
  final List<Map<String, dynamic>> payVideo = [
    {
      'id': 'video_call_60',
      'plan': '60',
      'price': 1.19,
    },
    {
      'id': 'video_call_120',
      'plan': '120',
      'price': 2.19,
    },
    {
      'id': 'video_call_240',
      'plan': '240',
      'price': 3.79,
    },
  ];

  final payAudio = [
    {
      'id': Platform.isIOS ? '60_audio_call' : 'audio_call_60',
      'plan': '60',
      'price': Platform.isIOS ? 0.39 : 0.35,
    },
    {
      'id': 'audio_call_120',
      'plan': '120',
      'price': Platform.isIOS ? 0.59 : 0.55,
    },
    {
      'id': 'audio_call_240',
      'plan': '240',
      'price': 0.89,
    },
  ];

  final payLikes = [
    {
      'id': 'like_1',
      'plan': '1',
      'price': 0.99,
    },
    {
      'id': 'like_3',
      'plan': '3',
      'price': 1.69,
    },
    {
      'id': 'like_6',
      'plan': '6',
      'price': 2.29,
    },
  ];

  final payBoosts = [
    {
      'id': 'boost_1',
      'plan': '1',
      'price': 0.89,
    },
    {
      'id': 'boost_3',
      'plan': '3',
      'price': 1.59,
    },
    {
      'id': 'boost_6',
      'plan': '6',
      'price': 2.19,
    },
  ];

  final List payOptionsPlus = [
    {
      'id': 'metfie_plus_1',
      'plan': '1',
      'price': 2.99,
    },
    {
      'id': 'metfie_plus_3',
      'plan': '3',
      'price': 6.99,
    },
    {
      'id': 'metfie_plus_6',
      'plan': '6',
      'price': 10.99,
    },
    {
      'id': 'metfie_plus_12',
      'plan': '12',
      'price': 19.99,
    },
  ];

  final List payOptionsPre = [
    {
      'id': 'metfie_premium_1',
      'plan': '1',
      'price': 6.99,
    },
    {
      'id': 'metfie_premium_3',
      'plan': '3',
      'price': 13.99,
    },
    {
      'id': 'metfie_premium_6',
      'plan': '6',
      'price': 22.99,
    },
    {
      'id': 'metfie_premium_12',
      'plan': '12',
      'price': 39.99,
    },
  ];
}
