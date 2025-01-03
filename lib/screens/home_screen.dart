import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> languages = [
  'Auto Detect',
  'Afrikaans',
  'Albanian',
  'Amharic',
  'Arabic',
  'Armenian',
  'Azerbaijani',
  'Basque',
  'Belarusian',
  'Bengali',
  'Bosnian',
  'Bulgarian',
  'Catalan',
  'Cebuano',
  'Chinese (Simplified)',
  'Chinese (Traditional)',
  'Corsican',
  'Croatian',
  'Czech',
  'Danish',
  'Dutch',
  'English',
  'Esperanto',
  'Estonian',
  'Finnish',
  'French',
  'Frisian',
  'Galician',
  'Georgian',
  'German',
  'Greek',
  'Gujarati',
  'Haitian Creole',
  'Hausa',
  'Hawaiian',
  'Hebrew',
  'Hindi',
  'Hmong',
  'Hungarian',
  'Icelandic',
  'Igbo',
  'Indonesian',
  'Irish',
  'Italian',
  'Japanese',
  'Javanese',
  'Kannada',
  'Kazakh',
  'Khmer',
  'Kinyarwanda',
  'Korean',
  'Kurdish',
  'Kyrgyz',
  'Lao',
  'Latin',
  'Latvian',
  'Lithuanian',
  'Luxembourgish',
  'Macedonian',
  'Malagasy',
  'Malay',
  'Malayalam',
  'Maltese',
  'Maori',
  'Marathi',
  'Mongolian',
  'Myanmar (Burmese)',
  'Nepali',
  'Norwegian',
  'Nyanja (Chichewa)',
  'Odia (Oriya)',
  'Pashto',
  'Persian',
  'Polish',
  'Portuguese',
  'Punjabi',
  'Romanian',
  'Russian',
  'Samoan',
  'Scots Gaelic',
  'Serbian',
  'Sesotho',
  'Shona',
  'Sindhi',
  'Sinhala (Sinhalese)',
  'Slovak',
  'Slovenian',
  'Somali',
  'Spanish',
  'Sundanese',
  'Swahili',
  'Swedish',
  'Tagalog (Filipino)',
  'Tajik',
  'Tamil',
  'Tatar',
  'Telugu',
  'Thai',
  'Turkish',
  'Turkmen',
  'Ukrainian',
  'Urdu',
  'Uyghur',
  'Uzbek',
  'Vietnamese',
  'Welsh',
  'Xhosa',
  'Yiddish',
  'Yoruba',
  'Zulu'
];

List<String> languageCodes = [
  'auto',
  'af',
  'sq',
  'am',
  'ar',
  'hy',
  'az',
  'eu',
  'be',
  'bn',
  'bs',
  'bg',
  'ca',
  'ceb',
  'zh-CN',
  'zh-TW',
  'co',
  'hr',
  'cs',
  'da',
  'nl',
  'en',
  'eo',
  'et',
  'fi',
  'fr',
  'fy',
  'gl',
  'ka',
  'de',
  'el',
  'gu',
  'ht',
  'ha',
  'haw',
  'he',
  'hi',
  'hmn',
  'hu',
  'is',
  'ig',
  'id',
  'ga',
  'it',
  'ja',
  'jw',
  'kn',
  'kk',
  'km',
  'rw',
  'ko',
  'ku',
  'ky',
  'lo',
  'la',
  'lv',
  'lt',
  'lb',
  'mk',
  'mg',
  'ms',
  'ml',
  'mt',
  'mi',
  'mr',
  'mn',
  'my',
  'ne',
  'no',
  'ny',
  'or',
  'ps',
  'fa',
  'pl',
  'pt',
  'pa',
  'ro',
  'ru',
  'sm',
  'gd',
  'sr',
  'st',
  'sn',
  'sd',
  'si',
  'sk',
  'sl',
  'so',
  'es',
  'su',
  'sw',
  'sv',
  'tl',
  'tg',
  'ta',
  'tt',
  'te',
  'th',
  'tr',
  'tk',
  'uk',
  'ur',
  'ug',
  'uz',
  'vi',
  'cy',
  'xh',
  'yi',
  'yo',
  'zu'
];

  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  String from = 'en';
  String to = 'ur';
  String data = '';
  String selectedvalue = 'English';
  String selectedvalue2 = 'Urdu';
  TextEditingController controller =
      TextEditingController(text: 'Hello, Welcome to LangFusion!');

  final formkey = GlobalKey<FormState>();
  bool isLoading = false;

  List<Map<String, String>> history = [];
  File? _image;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedHistory = prefs.getStringList('translation_history');
    if (savedHistory != null) {
      setState(() {
        history = savedHistory
            .map((e) => Map<String, String>.from(Uri.splitQueryString(e)))
            .toList();
      });
    }
  }

  Future<void> saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedHistory =
        history.map((e) => Uri(queryParameters: e).query).toList();
    await prefs.setStringList('translation_history', savedHistory);
  }

  Future<void> performOCR() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    setState(() {
      _image = File(pickedImage.path);
    });

    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String extractedText = recognizedText.text;
      setState(() {
        controller.text = extractedText;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to extract text: $e')),
      );
    } finally {
      textRecognizer.close();
    }
  }

  translate() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await translator
            .translate(controller.text, from: from, to: to)
            .then((value) {
          setState(() {
            data = value.text;
            history.add({
              'input': controller.text,
              'output': data,
              'from': selectedvalue,
              'to': selectedvalue2,
            });
            saveHistory();
            isLoading = false;
          });
        });
      } on SocketException catch (_) {
        setState(() {
          isLoading = false;
        });
        SnackBar mysnackbar = const SnackBar(
          content: Text('Internet not Connected!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(mysnackbar);
      }
    }
  }

  speak() async {
    if (data.isNotEmpty) {
      await flutterTts.setLanguage(to);
      await flutterTts.speak(data);
    }
  }

  Future<void> shareTranslation() async {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to share!'),
          backgroundColor: Colors.deepPurple,
        ),
      );
      return;
    }

    final shareContent =
        'Hey! Check out this translated text:\n\n"$data"\n\nShared via Language Translator App';

    try {
      await Share.share(shareContent);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.deepPurple,
    title: Row(
      mainAxisSize: MainAxisSize.min, // Ensures the Row is as compact as possible
      children: [
        Image.asset(
          'assets/app_bar2.png', // Path to your logo in assets
          height: 55, // Adjust height to fit the AppBar
        ),
        const SizedBox(width: 10), // Spacing between logo and app name
        const Text(
          'LangFusion',
          style: TextStyle(
            color: Color.fromARGB(255, 212, 212, 212),
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
      ],
    ),
    elevation: 5,
    centerTitle: true,
  ),
  body: Container(
    height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.deepPurple, Colors.purple, Colors.pinkAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // From Language Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: dropdownWidget(
                selectedvalue,
                languages,
                (value) {
                  setState(() {
                    selectedvalue = value!;
                    from = languageCodes[languages.indexOf(value)];
                  });
                },
              ),
            ),
            const SizedBox(height: 5),

            // Input Text Area
            textInputWidget(),
            const SizedBox(height: 10),

            // OCR Button
            ElevatedButton.icon(
              onPressed: performOCR,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text("Extract Text from Image", style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600
              ),),
              style: ElevatedButton.styleFrom(
                elevation: 8,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor:  const Color.fromARGB(255, 166, 49, 187),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // To Language Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: dropdownWidget(
                selectedvalue2,
                languages,
                (value) {
                  setState(() {
                    selectedvalue2 = value!;
                    to = languageCodes[languages.indexOf(value)];
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Translation Output
            Card(
              elevation: 8,
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20, left: 15, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Translation Output:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      data.isEmpty ? "Translation will appear here" : data,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.deepPurple),
                          onPressed: () {
                            // Copy functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.pink),
                          onPressed: shareTranslation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Translate & Speak Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : translate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(140, 45),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Translate',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                ElevatedButton(
                  onPressed: data.isEmpty ? null : speak,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(140, 45),
                  ),
                  child: const Text(
                    'Speak',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
  floatingActionButton: FloatingActionButton(
    backgroundColor: Colors.deepPurple,
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryPage()),
      );
    },
    child: const Icon(
      Icons.history,
      color: Colors.white,
    ),
  ),
);

  }

  Widget dropdownWidget(String selectedValue, List<String> items,
      ValueChanged<String?> onChanged) {
    return SizedBox(
      width: MediaQuery.of(context).size.height * 0.3,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((lang) {
          return DropdownMenuItem(
            value: lang,
            child: Text(
              lang,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.8,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 224, 227, 235),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
          ),
        ),
        dropdownColor: const Color.fromARGB(255, 224, 227, 235),
      ),
    );
  }

  Widget textInputWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Form(
        key: formkey,
        child: TextFormField(
          controller: controller,
          maxLines: null,
          minLines: 1,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your text';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: "Enter your text here",
            hintStyle: TextStyle(
              color: Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            errorBorder: InputBorder.none,
          ),
          style: const TextStyle(
            color: Color.fromARGB(255, 23, 23, 23),
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
