import 'package:flutter/material.dart';
import 'package:flutter_app/global.dart';
import 'package:flutter_app/helpers/mnemonic_generator.dart';
import 'package:flutter_app/views/password_generation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MnemonicOnboarding extends StatefulWidget {
  @override
  _MnemonicOnboardingState createState() => _MnemonicOnboardingState();
}

class _MnemonicOnboardingState extends State<MnemonicOnboarding> {
  String mnemonic = '';

  @override
  void initState() {
    super.initState();
    _getSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: mnemonic.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        childAspectRatio: 5,
                        children: mnemonic
                            .split(' ')
                            .map(
                              (e) => buildChoiceChip(e, context),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Please write this down somewhere safe, if you lose this, you will not get your account back. Not even Demeris could help you with that.',
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PasswordGenerationPage(mnemonic: mnemonic),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Proceed'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      )
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      mnemonic = MnemonicGenerator.generateMnemonic();
                      setState(() {});
                    },
                    child: Text('Create a new wallet'),
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildChoiceChip(String e, BuildContext context) {
    return ChoiceChip(
      label: Text(e),
      selected: true,
      avatar: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColorLight,
        child: Text(
          (mnemonic.split(' ').indexOf(e) + 1).toString(),
          style: TextStyle(fontSize: 12),
        ),
      ),
      labelStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      selectedColor: Theme.of(context).primaryColorDark,
    );
  }

  void _getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isWalletCreated = prefs.getBool(SharedPreferencesKeys.isWalletCreated);
    if (isWalletCreated != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordGenerationPage(),
        ),
      );
    }
  }
}
