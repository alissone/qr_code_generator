import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:simple_qr_code_generator/share_service.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Share as QR Code",
      home: MyHomePage(title: "Share as QR Code"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  final globalKey = GlobalKey();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _sharedText = "";
  String _gitHubUrl = "https://github.com/alissone/qr_code_generator";

  @override
  void initState() {
    super.initState();

    ShareService()
      ..onDataReceived = _handleSharedData
      ..getSharedData().then(_handleSharedData);
  }

  void _handleSharedData(String sharedData) {
    setState(() {
      _sharedText = sharedData;
    });
  }

  void _launchGitHub() async => await canLaunch(_gitHubUrl)
      ? await launch(_gitHubUrl)
      : throw "Could not launch $_gitHubUrl";

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<String> _captureAndSavePng({double imageSize = 2048}) async {
    final version = QrVersions.auto;
    final errorCorrectionLevel = QrErrorCorrectLevel.L;

    try {
      final qrValidationResult = QrValidator.validate(
        data: _sharedText,
        version: version,
        errorCorrectionLevel: errorCorrectionLevel,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;

        final painter = QrPainter.withQr(
          qr: qrCode ?? QrCode(version, errorCorrectionLevel),
          color: const Color(0xFF000000),
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null,
        );
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        final ts = DateTime.now().millisecondsSinceEpoch.toString();
        String path = '$tempPath/$ts.png';

        final picData =
            await painter.toImageData(imageSize, format: ImageByteFormat.png);
        await writeToFile(picData!, path);
        return path;
      }
    } catch (e) {
      print(e.toString());
    }
    return "";
  }

  Future<void> _shareImagePath(String imagePath) async {
    if (imagePath != "") {
      await Share.shareFiles(
        [imagePath],
        mimeTypes: ["image/png"],
        subject: "Qr code",
        text: "Scan me to view the content",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: _sharedText == ""
            ? Text("Share any text and choose this app to generate a QR code.")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  Text(
                    _sharedText,
                  ),
                  SizedBox(height: 18),
                  QrImage(
                    data: _sharedText,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  Spacer(),
                  RoundedElevatedButton(
                    icon: Icon(Icons.copy),
                    label: "Copy text",
                    buttonHeight: 56,
                    buttonWidth: 200,
                    textColor: Colors.white,
                    backgroundColor: Colors.grey,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _sharedText));
                    },
                  ),
                  SizedBox(height: 18),
                  RoundedElevatedButton(
                    icon: Icon(Icons.share),
                    label: "Share as image",
                    buttonHeight: 56,
                    buttonWidth: 200,
                    textColor: Colors.white,
                    backgroundColor: Colors.blueGrey,
                    onTap: () async {
                      String path = await _captureAndSavePng();
                      _shareImagePath(path);
                    },
                  ),
                  SizedBox(height: 18),
                  RoundButton(
                    content: FaIcon(FontAwesomeIcons.github),
                    radius: 56.0,
                    color: Colors.blueGrey[100],
                    onTap: _launchGitHub,
                  ),
                  SizedBox(height: 16),
                ],
              ),
      ),
    );
  }
}

class RoundedElevatedButton extends StatelessWidget {
  const RoundedElevatedButton({
    Key? key,
    required this.buttonHeight,
    required this.buttonWidth,
    required this.textColor,
    required this.backgroundColor,
    required this.label,
    this.onTap,
    this.icon,
  }) : super(key: key);

  final double buttonHeight;
  final double buttonWidth;
  final Color textColor;
  final MaterialColor backgroundColor;
  final String label;
  final Widget? icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      width: buttonWidth,
      child: ElevatedButton.icon(
          icon: this.icon ?? Icon(Icons.no_encryption),
          label: Text(label, style: TextStyle(fontSize: 18)),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(textColor),
            backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ),
          ),
          onPressed: onTap ?? () => null),
    );
  }
}

class RoundButton extends StatelessWidget {
  const RoundButton({
    Key? key,
    this.radius,
    this.color,
    required this.content,
    this.onTap,
  }) : super(key: key);

  final double? radius;
  final Color? color;
  final FaIcon content;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(radius ?? 56, radius ?? 56),
      child: ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            splashColor: Colors.green,
            onTap: onTap ?? () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[content],
            ),
          ),
        ),
      ),
    );
  }
}
