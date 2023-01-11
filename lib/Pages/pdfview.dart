import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatefulWidget {
  const PdfView({Key? key, required this.url, required this.title})
      : super(key: key);
  final String url;
  final String title;

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool showTextField = false;
  FocusNode myFocusNode = FocusNode();
  late PdfTextSearchResult _searchResult;
  late PdfViewerController _pdfViewerController;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    _searchResult = PdfTextSearchResult();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: showTextField
            ? AppBar(
          backgroundColor: Colors.grey[900],
          leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_sharp),
                  onPressed: () {
                    setState(() {
                      showTextField = false;
                    });
                    _searchResult.clear();
                    textEditingController.clear();
                  },
                ),
                title: TextField(
                  focusNode: myFocusNode,
                  cursorColor: Colors.grey,
                  controller: textEditingController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSubmitted: (val) async {
                    _searchResult = await _pdfViewerController
                        .searchText(textEditingController.text);
                    if(_searchResult.totalInstanceCount==0){
                      Fluttertoast.showToast(msg: "No match found",
                          toastLength: Toast.LENGTH_SHORT, // length
                          gravity: ToastGravity.BOTTOM,    // location
                          timeInSecForIosWeb: 1
                      );
                    }
                    print(
                        'Total instance count: ${_searchResult.totalInstanceCount}');
                  },
                ),
                actions: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  textEditingController.clear();
                                  _searchResult.clear();
                                },
                                icon: const Icon(Icons.clear)),
                            Text("${_searchResult.currentInstanceIndex}"),
                            const Text(" of "),
                            Text("${_searchResult.totalInstanceCount}"),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _searchResult.previousInstance();
                                  });
                                },
                                icon: const Icon(Icons.arrow_back_ios_sharp)),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _searchResult.nextInstance();
                                  });
                                },
                                icon: const Icon(Icons.arrow_forward_ios_sharp))
                          ],
                        ),
                      ],
              )
            : AppBar(
          backgroundColor: Colors.grey[900],
                title: Text(widget.title),
                actions: [
                  IconButton(
                      onPressed: () {
                        _pdfViewerKey.currentState!.openBookmarkView();
                      },
                      icon: const Icon(Icons.bookmark)),
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      setState(() {
                        showTextField = true;
                        myFocusNode.requestFocus();
                      });
                    },
                  ),
                ],
              ),
        body: GestureDetector(
          onHorizontalDragStart: (details) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SfPdfViewer.network(widget.url,
              key: _pdfViewerKey, controller: _pdfViewerController),
        ),
      ),
    );
  }
}
