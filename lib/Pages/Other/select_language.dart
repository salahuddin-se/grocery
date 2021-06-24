import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/language_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseLanguage extends StatefulWidget {
  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  LanguageCubit _languageCubit;
  bool islogin = false;
  List<int> radioButtons = [0, -1, -1, -1, -1];
  String selectedLanguage;
  int selectedIndex = -1;
  bool enteredFirst = false;
  var userName;
  List<String> languages = [];

  @override
  void initState() {
    super.initState();
    getSharedValue();
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name');
      islogin = prefs.getBool('islogin');
    });
  }

  getAsyncValue(List<String> languagesd, AppLocalizations locale) async {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.containsKey('language') &&
          prefs.getString('language').length > 0) {
        String langCode = prefs.getString('language');
        if (langCode == 'en') {
          selectedLanguage = locale.englishh;
        } else if (langCode == 'ar') {
          selectedLanguage = locale.arabicc;
        } else if (langCode == 'pt') {
          selectedLanguage = locale.portuguesee;
        } else if (langCode == 'fr') {
          selectedLanguage = locale.frenchh;
        } else if (langCode == 'id') {
          selectedLanguage = locale.indonesiann;
        } else if (langCode == 'es') {
          selectedLanguage = locale.spanishh;
        }
        // else if(langCode == 'bg'){
        //   selectedLanguage = locale.bulgarian;
        // }
        setState(() {
          selectedIndex = languages.indexOf(selectedLanguage);
        });
      } else {
        selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (!enteredFirst) {
      setState(() {
        enteredFirst = true;
      });
      languages = [
        locale.englishh,
        locale.spanishh,
        locale.portuguesee,
        locale.frenchh,
        locale.arabicc,
        locale.indonesiann,
      ];
      getAsyncValue(languages, locale);
    }
    return Scaffold(
      drawer: buildDrawer(context, userName, islogin, onHit: () {
        SharedPreferences.getInstance().then((pref) {
          pref.clear().then((value) {
            // Navigator.pushAndRemoveUntil(context,
            //     MaterialPageRoute(builder: (context) {
            //       return GroceryLogin();
            //     }), (Route<dynamic> route) => false);
            Navigator.of(context).pushNamedAndRemoveUntil(
                PageRoutes.signInRoot, (Route<dynamic> route) => false);
          });
        });
      }),
      appBar: AppBar(
        title: Text(
          locale.languages,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 20.0, left: 16, right: 16, bottom: 16),
            child: Text(
              locale.selectPreferredLanguage,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                primary: true,
                child: ListView.builder(
                  itemCount: languages.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    return Container(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            print(selectedIndex);
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Radio(
                              activeColor: kMainColor,
                              value: index,
                              groupValue: selectedIndex,
                              toggleable: false,
                              onChanged: (valse) {
                                setState(() {
                                  selectedIndex = index;
                                  print(selectedIndex);
                                });
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text('${languages[index]}',style: TextStyle(
                                fontSize: 16
                            ),)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )),
          // RadioButtonGroup(
          //   activeColor: Theme.of(context).primaryColor,
          //   labelStyle: Theme.of(context).textTheme.caption,
          //   onSelected: (selectedLocale) {
          //     setState(() {
          //       selectedLanguage = selectedLocale;
          //     });
          //   },
          //   labels: languages,
          //   itemBuilder: (Radio radioButton, Text title, int i) {
          //     return Column(
          //       children: <Widget>[
          //         Container(
          //           height: 56.7,
          //           color: Theme.of(context).scaffoldBackgroundColor,
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //             child: ListTile(
          //               leading: radioButton,
          //               title: Text(
          //                 languages[i],
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .subtitle1
          //                     .copyWith(fontSize: 19),
          //               ),
          //             ),
          //           ),
          //         ),
          //         SizedBox(height: 5.0)
          //       ],
          //     );
          //   },
          // ),
          // Spacer(),
          CustomButton(
            label: locale.save,
            onTap: () {
              if (selectedIndex >= 0) {
                setState(() {
                  selectedLanguage = languages[selectedIndex];
                });
                if (selectedLanguage == locale.englishh) {
                  _languageCubit.selectEngLanguage();
                } else if (selectedLanguage == locale.arabicc) {
                  _languageCubit.selectArabicLanguage();
                } else if (selectedLanguage == locale.portuguesee) {
                  _languageCubit.selectPortugueseLanguage();
                } else if (selectedLanguage == locale.frenchh) {
                  _languageCubit.selectFrenchLanguage();
                } else if (selectedLanguage == locale.spanishh) {
                  _languageCubit.selectSpanishLanguage();
                } else if (selectedLanguage == locale.indonesiann) {
                  _languageCubit.selectIndonesianLanguage();
                }
                // else if (selectedLanguage == locale.bulgarian) {
                //   _languageCubit.selectBulgarianLanguage();
                // }
              }

//              else if (selectedLanguage == 'Indonesian') {
//                _languageCubit.selectIndonesianLanguage();
//              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
