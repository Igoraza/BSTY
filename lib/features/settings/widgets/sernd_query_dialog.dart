import 'package:flutter/material.dart';
import 'package:bsty/features/auth/services/initial_profile_provider.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/stadium_button.dart';
import '../../../utils/constants/input_decorations.dart';
import '../../../utils/theme/colors.dart';

class SendQueryDialog extends StatelessWidget {
  SendQueryDialog({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);

    return Dialog(
      backgroundColor: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(mq.size.width * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Send your query',
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                decoration: kInputDecoration.copyWith(
                  hintText: 'Enter subject here',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Subject is required !";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Write a note for us', style: textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _content,
                maxLines: 5,
                maxLength: 300,
                decoration: kInputDecoration.copyWith(
                    hintText: 'Type your message in less than 300 letters.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    )),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Message is required !";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<InitialProfileProvider>(builder: (context, ref, _) {
                return StadiumButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      InitialProfileProvider()
                          .sendQuery(_title.text, _content.text);
                      Navigator.of(context).pop();
                    }
                  },
                  gradient: AppColors.orangeYelloH,
                  child: ref.isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.white,
                        )
                      : const Text('Send'),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
