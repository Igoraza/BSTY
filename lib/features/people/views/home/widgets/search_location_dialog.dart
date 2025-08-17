import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../services/locatoin_provider.dart';
import '../../../../../utils/constants/input_decorations.dart';

class SearchLocationDialog extends StatefulWidget {
  const SearchLocationDialog(this.location, {super.key});

  final ValueNotifier<String> location;

  @override
  State<SearchLocationDialog> createState() => _SearchLocationDialogState();
}

class _SearchLocationDialogState extends State<SearchLocationDialog> {
  Timer? _debouncer;

  List<String> locations = [];

  void textFieldOnChanged(String value) {
    if (_debouncer?.isActive ?? false) {
      _debouncer?.cancel();
    }

    _debouncer = Timer(
        const Duration(milliseconds: 600),
        () => context
            .read<LocationProvider>()
            .getAutocompletePlaces(value)
            .then((value) => setState(() => locations = value)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
     
    return SimpleDialog(
        insetPadding: EdgeInsets.all(size.width * 0.05),
        title: const Text('Select Location'),
        contentPadding: EdgeInsets.all(size.width * 0.05),
        children: [
          TextFormField(
              onChanged: textFieldOnChanged,
              autofocus: true,
              decoration: kInputDecoration.copyWith(
                hintText: 'Search location',
                prefixIcon: const Icon(Icons.location_on_outlined),
              )),
          SizedBox(height: size.height * 0.02),
          Container(
              height:
                  locations.isEmpty ? 0 : locations.length * size.width * 0.15,
              width: size.height * 0.4,
              constraints: BoxConstraints(maxHeight: size.height * 0.5),
              child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) => ListTile(
                      title: Text(locations[index]),
                      onTap: () {
                        widget.location.value = locations[index];
                        Navigator.of(context).pop();
                      })))
        ]);
  }
}
