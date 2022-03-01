import 'dart:convert';
import 'dart:io';

import 'package:app/register/register_sheep.dart';
import 'package:app/utils/custom_widgets.dart';
import 'package:app/utils/other.dart';
import 'package:app/utils/question_sets.dart';
import 'package:app/utils/speech_input_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class RegisterSheepOrally extends StatefulWidget {
  const RegisterSheepOrally(this.fileName, this.stt, this.ongoingDialog,
      {this.onCompletedSuccessfully, Key? key})
      : super(key: key);

  final void Function(int)? onCompletedSuccessfully;
  final String fileName;
  final SpeechToText stt;
  final ValueNotifier<bool> ongoingDialog;

  static const String route = 'register-sheep-orally';

  @override
  State<RegisterSheepOrally> createState() => _RegisterSheepOrallyState();
}

enum TtsState { speaking, notSpeaking }
enum SttState { listening, notListening }

class _RegisterSheepOrallyState extends State<RegisterSheepOrally> {
  _RegisterSheepOrallyState();

  int questionIndex = 0;

  late FlutterTts _tts;
  static const double volume = 1.0;
  static const double pitch = 1.0;
  static const double rate = 0.5;

  final _formKey = GlobalKey<FormState>();

  final scrollController = ScrollController();
  final List<GlobalKey> firstHeadlineFieldKeys = [GlobalKey(), GlobalKey()];
  final List<int> firstHeadlineFieldIndexes = [5, 8];
  int currentHeadlineIndex = 0;

  final _textControllers = <String, TextEditingController>{
    'sheep': TextEditingController(),
    'lambs': TextEditingController(),
    'white': TextEditingController(),
    'black': TextEditingController(),
    'blackHead': TextEditingController(),
    'redTie': TextEditingController(),
    'blueTie': TextEditingController(),
    'yellowTie': TextEditingController(),
    'redEar': TextEditingController(),
    'blueEar': TextEditingController(),
  };

  List<String> questions = allSheepQuestions.keys.toList();
  List<QuestionContext> questionContexts = allSheepQuestions.values.toList();
  List<String> numbers = numbersFilter.keys.toList();
  List<String> colors = colorsFilter.keys.toList();

  @override
  void initState() {
    super.initState();
    _initTextToSpeech();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.stt.isAvailable) {
        _startDialog(questions, questionContexts);
      } else {
        showDialog(
            context: context,
            builder: (_) => speechNotEnabledDialog(
                context,
                MaterialPageRoute(
                    builder: (context) => RegisterSheep(widget.fileName,
                        onCompletedSuccessfully:
                            widget.onCompletedSuccessfully))));
      }
    });
  }

  void _startDialog(
      List<String> questions, List<QuestionContext> questionContexts) async {
    setState(() {
      widget.ongoingDialog.value = true;
      FocusManager.instance.primaryFocus?.unfocus();
    });
    await _speak(questions[questionIndex]);
    await _listen(questionContexts[questionIndex]);
  }

  Future<void> _listen(QuestionContext questionContext) async {
    await widget.stt.listen(
        onResult: (result) => _onSpeechResult(result, questionContext),
        localeId: 'en-US',
        onDevice: true,
        listenFor: const Duration(seconds: 5));
  }

  void _onSpeechResult(
      SpeechRecognitionResult result, QuestionContext questionContext) async {
    if (result.finalResult) {
      String spokenWord = result.recognizedWords;

      if (spokenWord == 'previous' || spokenWord == 'back') {
        if (questionIndex > 0) {
          if (questionIndex == firstHeadlineFieldIndexes[0] ||
              questionIndex == firstHeadlineFieldIndexes[1]) {
            currentHeadlineIndex--;
          }
          questionIndex--;
        }
        setState(() {
          _textControllers.values.elementAt(questionIndex).text = '';
        });

        await _speak(questions[questionIndex]);
        await _listen(questionContexts[questionIndex]);
      } else {
        if (questionContext == QuestionContext.numbers &&
            !numbers.contains(spokenWord)) {
          spokenWord = correctErroneousInput(spokenWord, questionContext);
        } else if (questionContext == QuestionContext.colors &&
            !colors.contains(spokenWord)) {
          spokenWord = correctErroneousInput(spokenWord, questionContext);
        }

        if (spokenWord == '') {
          String response = "Jeg forstod ikke. " + questions[questionIndex];
          await _speak(response);
          await _listen(questionContexts[questionIndex]);
        } else {
          await _speak(spokenWord, language: 'en-US');

          setState(() {
            _textControllers.values.elementAt(questionIndex).text = spokenWord;
          });

          questionIndex++;

          if (questionIndex < allSheepQuestions.length) {
            if (firstHeadlineFieldIndexes.contains(questionIndex)) {
              scrollToKey(scrollController,
                  firstHeadlineFieldKeys[currentHeadlineIndex++]);
            }

            await _speak(questions[questionIndex]);
            await _listen(questionContexts[questionIndex]);
          } else {
            questionIndex = 0;
            currentHeadlineIndex = 0;
            setState(() {
              widget.ongoingDialog.value = false;
            });
          }
        }
      }
    }
  }

  void _initTextToSpeech() {
    _tts = FlutterTts();

    _tts.setVolume(volume);
    _tts.setSpeechRate(rate);
    _tts.setPitch(pitch);

    _setAwaitOptions();
  }

  Future<void> _setAwaitOptions() async {
    await _tts.awaitSpeakCompletion(true);
    var engine = await _tts.getDefaultEngine;
    debugPrint(engine);
  }

  Future<void> _speak(String text, {String language = 'nb-NO'}) async {
    await _tts.setLanguage(language);
    await _tts.speak(text);
  }

  void _registerSheep() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;

    final File file = File('$path/${widget.fileName}.json');
    final Map data = gatherRegisteredData(_textControllers);

    file.writeAsString(json.encode(data));

    if (widget.onCompletedSuccessfully != null) {
      int sheepAmount = _textControllers['sheep']!.text == ''
          ? 0
          : int.parse(_textControllers['sheep']!.text);
      widget.onCompletedSuccessfully!(sheepAmount);
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    _textControllers.forEach((_, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Form(
            key: _formKey,
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('Registrer sau muntlig'),
                  leading: BackButton(
                      onPressed: () => {
                            widget.stt.stop(),
                            _tts.stop(),
                            setState(() {
                              widget.ongoingDialog.value = false;
                            }),
                            showDialog(
                                context: context,
                                builder: (_) =>
                                    cancelRegistrationDialog(context))
                          }),
                ),
                body: SingleChildScrollView(
                    controller: scrollController,
                    child: Center(
                        child: Column(children: [
                      const SizedBox(height: 10),
                      inputDividerWithHeadline('Antall'),
                      inputRow('Sauer', _textControllers['sheep']!,
                          RpgAwesome.sheep, Colors.grey),
                      inputFieldSpacer(),
                      inputRow('Lam', _textControllers['lambs']!,
                          RpgAwesome.sheep, Colors.grey,
                          iconSize: 24),
                      inputFieldSpacer(),

                      inputRow(
                        'Hvite',
                        _textControllers['white']!,
                        RpgAwesome.sheep,
                        Colors.white,
                      ),
                      inputFieldSpacer(),
                      inputRow(
                        'Svarte',
                        _textControllers['black']!,
                        RpgAwesome.sheep,
                        Colors.black,
                      ),
                      inputFieldSpacer(),
                      inputRow('Svart hode', _textControllers['blackHead']!,
                          RpgAwesome.sheep, Colors.black,
                          scrollController: scrollController,
                          fieldAmount: 5,
                          key: firstHeadlineFieldKeys[0]),

                      inputDividerWithHeadline(
                          'Slips', firstHeadlineFieldKeys[0]),

                      // TODO: Conditional basert på mulige farger
                      inputRow(
                        'Røde',
                        _textControllers['redTie']!,
                        FontAwesome5.black_tie,
                        Colors.red,
                      ),
                      inputFieldSpacer(),
                      inputRow(
                        'Blå',
                        _textControllers['blueTie']!,
                        FontAwesome5.black_tie,
                        Colors.blue,
                      ),
                      inputFieldSpacer(),
                      inputRow('Gule', _textControllers['yellowTie']!,
                          FontAwesome5.black_tie, Colors.yellow,
                          scrollController: scrollController,
                          fieldAmount: 3,
                          key: firstHeadlineFieldKeys[1]),
                      // TODO: Conditional basert på mulige farger

                      inputDividerWithHeadline(
                          'Øremerker', firstHeadlineFieldKeys[1]),

                      inputRow(
                        'Røde',
                        _textControllers['redEar']!,
                        Icons.local_offer,
                        Colors.red,
                      ),
                      inputFieldSpacer(),
                      inputRow(
                        'Blå',
                        _textControllers['blueEar']!,
                        Icons.local_offer,
                        Colors.blue,
                      ),
                      inputFieldSpacer(),
                      const SizedBox(height: 80),
                    ]))),
                floatingActionButton: !widget
                        .ongoingDialog.value // TODO if no else
                    ? Row(
                        mainAxisAlignment:
                            MediaQuery.of(context).viewInsets.bottom == 0
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          startDialogButton(
                              () => _startDialog(questions, questionContexts)),
                          MediaQuery.of(context).viewInsets.bottom == 0
                              ? const SizedBox(
                                  width: 20,
                                )
                              : const Spacer(),
                          completeRegistrationButton(context, _registerSheep)
                        ],
                      )
                    : null,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat)));
  }
}
