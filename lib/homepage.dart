import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _overallConfidence = 1.0;  // to store overall confidence

  List<Map<String, dynamic>> wordsData = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 238, 238),
      appBar: AppBar(
        title: const Text(
          'Speech to Text Demo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 22, 22, 22),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        onPressed: () async {
          if (!_isListening) {
            bool available = await _speech.initialize(
              onStatus: (val) => setState(() => _isListening = val == 'listening'),
              onError: (val) => print('Error: $val'),
            );
            if (available) {
              _speech.listen(
                onResult: (val) => setState(() {
                  List<String> mainWords = val.recognizedWords.split(' ');
                  wordsData.clear();

                  for (int i = 0; i < mainWords.length; i++) {
                    int similarCount = 0;
                    for (var alt in val.alternates) {
                      List<String> altWords = alt.recognizedWords.split(' ');
                      if (altWords.length > i && altWords[i] == mainWords[i]) {
                        similarCount++;
                      }
                    }
                    double wordConfidence = (similarCount / val.alternates.length) * 100;
                    wordsData.add({'word': mainWords[i], 'confidence': wordConfidence});
                  }

                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _overallConfidence = val.confidence;  // Update the overall confidence
                  }
                }),
              );
            }
          } else {
            _speech.stop();
            setState(() => _isListening = false);
          }
        },
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Column(
            children: <Widget>[
              Text(
                'Press the button and start speaking',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              DataTable(
                columns: [
                  DataColumn(label: Text('Word')),
                  DataColumn(label: Text('Confidence')),
                ],
                rows: wordsData.map((entry) => DataRow(
                  cells: [
                    DataCell(Text(entry['word'])),
                    DataCell(Text('${entry['confidence'].toStringAsFixed(1)}%')),
                  ]
                )).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Overall Confidence: ${(_overallConfidence * 100.0).toStringAsFixed(1)}%',  // Display overall confidence
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _lastWord = '';
//   double _confidence = 1.0;
//   String? _previousResult;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 241, 238, 238),
//       appBar: AppBar(
//         title: const Text(
//           'Speech to Text Demo',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color.fromARGB(255, 22, 22, 22),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: FloatingActionButton(
//         child: Icon(_isListening ? Icons.mic_off : Icons.mic),
//         onPressed: () async {
//           if (!_isListening) {
//             _previousResult = null; // reset previous result
//             bool available = await _speech.initialize(
//               onStatus: (val) =>
//                   setState(() => _isListening = val == 'listening'),
//               onError: (val) => print('Error: $val'),
//             );
//             if (available) {
//               _speech.listen(
//                 listenFor: Duration(hours: 1), // Listen for a long time
//                 onResult: (val) => setState(() {
//                   String currentResult = val.recognizedWords;
//                   if (_previousResult != null && currentResult != _previousResult) {
//                     List<String> newWords = currentResult
//                         .replaceFirst(_previousResult!, '')
//                         .trim()
//                         .split(' ');
//                     _lastWord = newWords.last;
//                   } else {
//                     _lastWord = currentResult.split(' ').last;
//                   }
//                   _previousResult = currentResult;
//                   if (val.hasConfidenceRating && val.confidence > 0) {
//                     _confidence = val.confidence;
//                   }
//                 }),
//               );
//             }
//           } else {
//             _speech.stop();
//             setState(() => _isListening = false);
//           }
//         },
//       ),
//       body: SingleChildScrollView(
//         reverse: true,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
//           child: Column(
//             children: <Widget>[
//               Text(
//                 'Press the button and start speaking',
//                 style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Word: ${_lastWord}',
//                 style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
//                 style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:leopard_flutter/leopard.dart';
// // import 'package:leopard_flutter/leopard_error.dart';
// import 'package:leopard_flutter/leopard_transcript.dart';
// import 'package:flutter_voice_processor/flutter_voice_processor.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final String accessKey = "{YOUR_ACCESS_KEY}";
//   final String modelPath = "assets/{MODEL_FILE}.pv";

//   Leopard? leopard;
//   VoiceProcessor? voiceProcessor;
//   final int frameLength = 512;
//   List<int> audioData = [];
//   bool _isListening = false;
//   List<Map<String, dynamic>> _wordsAndConfidence = [];

//   @override
//   void initState() {
//     super.initState();
//     initLeopard();
//   }

//   Future<void> initLeopard() async {
//     try {
//       leopard = await Leopard.create(accessKey, modelPath);
//       initVoiceProcessor(leopard!.sampleRate);
//     } catch (err) {
//       print(err.toString());
//       // handle Leopard init error
//     }
//   }

//   void initVoiceProcessor(int sampleRate) {
//     voiceProcessor = VoiceProcessor.getVoiceProcessor(frameLength, sampleRate);
//     voiceProcessor!.addListener((buffer) {
//       List<int> frame = (buffer as List<dynamic>).cast<int>();
//       audioData.addAll(frame);
//     });
//   }

//   Future<void> startRecording() async {
//     setState(() {
//       _isListening = true;
//     });
//     audioData = [];
//     if (await voiceProcessor!.hasRecordAudioPermission()) {
//       await voiceProcessor!.start();
//     }
//   }

//   Future<void> stopRecording() async {
//     await voiceProcessor!.stop();
//     LeopardTranscript result = await leopard!.process(audioData);
//     setState(() {
//       _isListening = false;
//       _wordsAndConfidence.clear();
//       for (LeopardWord word in result.words) {
//         _wordsAndConfidence.add({
//           'word': word.transcript,
//           'confidence': word.confidence,
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 241, 238, 238),
//       appBar: AppBar(
//         title: const Text(
//           'Speech to Text Demo using Leopard',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color.fromARGB(255, 22, 22, 22),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: FloatingActionButton(
//         child: Icon(_isListening ? Icons.mic_off : Icons.mic),
//         onPressed: _isListening ? stopRecording : startRecording,
//       ),
//       body: SingleChildScrollView(
//         reverse: true,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
//           child: Column(
//             children: <Widget>[
//               Text(
//                 'Press the button and start speaking',
//                 style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               ..._wordsAndConfidence.map((entry) {
//                 return Column(
//                   children: [
//                     Text(
//                       'Word: ${entry['word']}',
//                       style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300),
//                     ),
//                     Text(
//                       'Confidence: ${(entry['confidence'] * 100.0).toStringAsFixed(1)}%',
//                       style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   List<Map<String, dynamic>> _wordsAndConfidence = [];

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 241, 238, 238),
//       appBar: AppBar(
//         title: const Text(
//           'Speech to Text Demo',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color.fromARGB(255, 22, 22, 22),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: FloatingActionButton(
//         child: Icon(_isListening ? Icons.mic_off : Icons.mic),
//         onPressed: () async {
//           if (!_isListening) {
//             bool available = await _speech.initialize(
//               onStatus: (val) => setState(() => _isListening = val == 'listening'),
//               onError: (val) => print('Error: $val'),
//             );
//             if (available) {
//               _speech.listen(
//                 onResult: (val) => setState(() {
//                   _wordsAndConfidence.clear();
//                   for (var word in val.alternates) {
//                     _wordsAndConfidence.add({
//                       'word': word.recognizedWords,
//                       'confidence': word.confidence
//                     });
//                   }
//                 }),
//               );
//             }
//           } else {
//             _speech.stop();
//             setState(() => _isListening = false);
//           }
//         },
//       ),
//       body: SingleChildScrollView(
//         reverse: true,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
//           child: Column(
//             children: <Widget>[
//               Text(
//                 'Press the button and start speaking',
//                 style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               ..._wordsAndConfidence.map((entry) {
//                 return Column(
//                   children: [
//                     Text(
//                       'Word: ${entry['word']}',
//                       style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300),
//                     ),
//                     Text(
//                       'Confidence: ${(entry['confidence'] * 100.0).toStringAsFixed(1)}%',
//                       style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _lastWord = '';
//   double _confidence = 1.0;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 241, 238, 238),
//       appBar: AppBar(
//         title: const Text(
//           'Speech to Text Demo',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color.fromARGB(255, 22, 22, 22),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: FloatingActionButton(
//         child: Icon(_isListening ? Icons.mic_off : Icons.mic),
//         onPressed: () async {
//           if (!_isListening) {
//             bool available = await _speech.initialize(
//               onStatus: (val) =>
//                   setState(() => _isListening = val == 'listening'),
//               onError: (val) => print('Error: $val'),
//             );
//             if (available) {
//               _speech.listen(
//                 onResult: (val) => setState(() {
//                   _lastWord = val.recognizedWords;
//                   print(_lastWord);
//                   if (val.hasConfidenceRating && val.confidence > 0) {
//                     _confidence = val.confidence;
//                   }
//                 }),
//               );
//             }
//           } else {
//             _speech.stop();
//             setState(() => _isListening = false);
//           }
//         },
//       ),
//       body: SingleChildScrollView(
//         reverse: true,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
//           child: Column(
//             children: <Widget>[
//               Text(
//                 'Press the button and start speaking',
//                 style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Word: ${_lastWord}',
//                 style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
//                 style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
