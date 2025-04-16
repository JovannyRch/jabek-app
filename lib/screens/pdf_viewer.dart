import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:jebek_app/services/share_preferences.dart';
/* import 'package:share_extend/share_extend.dart'; */

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;
  const PdfViewerScreen({Key? key, required this.url, required this.title})
    : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = false;
  PDFDocument? doc;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      _isLoading = true;
    });

    final token = await Preferences.getToken();
    doc = await PDFDocument.fromURL(
      widget.url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  _share() async {
    /*   ShareExtend.share(doc!.filePath!, "file"); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _share();
            },
          ),
        ],
      ),
      body: Center(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: PDFViewer(document: doc!),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
