import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mubooks/Pages/pdfview.dart';
import 'package:mubooks/Widgets.dart';
import 'package:mubooks/services.dart';
import 'package:permission_handler/permission_handler.dart';

class DeptPage extends StatefulWidget {
  final String stream;
  final String faculty;
  final String dept;

  const DeptPage(
      {Key? key,
      required this.stream,
      required this.faculty,
      required this.dept})
      : super(key: key);

  @override
  State<DeptPage> createState() => _DeptPageState();
}

class _DeptPageState extends State<DeptPage> {
  Map info = {};
  Map tabList = {};
  List title = ['Sem 1', 'Sem 2'];
  Map files = {};
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    getInfo();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  getInfo() async {
    var resp = await fetchInfo(widget.stream, widget.faculty, widget.dept);
    if (resp != null) {
      await getList();
      setState(() {
        info = resp;
      });
    }
  }

  getList() async {
    var resp = await fetchDept(
        "${widget.stream}/${widget.faculty}/${widget.dept}");
    tabList = resp;
  }

  getFiles(String tab, String item) async {
    var resp = await fetchList("${widget.stream}/${widget.faculty}/${widget.dept}/$tab/$item");
    files = resp;
  }

  Future download(String url, String filename) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final dir = Directory("/storage/emulated/0/Download/");
      if (await dir.exists()) {
        var pos = url.lastIndexOf('/') + 1;
        filename = filename.isEmpty
            ? (pos != -1)
                ? url.substring(pos, url.length)
                : url
            : filename;
        if (await File(dir.path + filename).exists()) {
          filename = await fileCheck(filename, dir);
          print(filename);
          download(url, filename);
        } else {
          await FlutterDownloader.enqueue(
              url: url,
              savedDir: dir.path,
              fileName: filename,
              showNotification: true,
              openFileFromNotification: true);
        }
      } else {
        dir.create();
        download(url, filename);
      }
    }
  }

  Future fileCheck(String filename, Directory dir) async {
    if (await File(dir.path + filename).exists()) {
      var count = 1;
      var pos = filename.lastIndexOf('.');
      String extension =
          (pos != -1) ? filename.substring(pos, filename.length) : filename;
      filename = (pos != -1) ? filename.substring(0, pos) : filename;
      String finalfilename = "$filename($count)$extension";
      while (await File(dir.path + finalfilename).exists()) {
        count++;
        finalfilename = "$filename($count)$extension";
      }
      return finalfilename;
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      // Persistent AppBar that never scrolls
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.dept,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        elevation: 0.0,
      ),
      body: (() {
        if (info.isEmpty || tabList.isEmpty) {
          return LoadingScreen(
            isDarkMode: isDarkMode,
            retry: () {
              getInfo();
              setState(() {});
            },
          );
        }
        return DefaultTabController(
          length: tabList.keys.length,
          child: NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: isDarkMode ? Colors.black : Colors.white,
                  automaticallyImplyLeading: false,
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: info.length,
                              itemBuilder: (BuildContext context, int index) {
                                String key = info.keys.elementAt(index);
                                return ListTile(
                                  title: Text(
                                    key,
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  subtitle: Text(
                                    "${info[key]}",
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ), // This is where you build the profile part
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                TabBar(
                  indicatorColor: Colors.tealAccent,
                  labelColor: isDarkMode ? Colors.white : Colors.black,
                  tabs: tabList.entries
                      .map((e) => Tab(
                            text: e.key,
                          ))
                      .toList(),
                ),
                Expanded(
                    child: Container(
                  color: isDarkMode ? Colors.black : Colors.white,
                  child: TabBarView(
                    children: tabList.entries.map((tab) {
                      return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: tab.value.length,
                          itemBuilder: (BuildContext context, int index) {
                            var text = tab.value[index];
                            return Container(
                              margin: const EdgeInsets.all(10.0),
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode ? Colors.grey[600] : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode
                                        ? Colors.transparent
                                        : Colors.grey,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await getFiles(tab.key, text);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            insetPadding:
                                                const EdgeInsets.all(25),
                                            backgroundColor: Colors.grey[700],
                                            child: (() {
                                              if (files.isEmpty) {
                                                return LoadingScreen(
                                                    isDarkMode: isDarkMode,
                                                    retry: () {
                                                      Navigator.pop(context);
                                                    });
                                              }
                                              return DefaultTabController(
                                                length: files.length,
                                                child: Column(
                                                  children: [
                                                    TabBar(
                                                      indicatorColor:
                                                          Colors.tealAccent,
                                                      tabs: files.entries
                                                          .map((e) => Tab(
                                                                text: e.key,
                                                              ))
                                                          .toList(),
                                                    ),
                                                    Expanded(
                                                        child: TabBarView(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            children: files
                                                                .entries
                                                                .map((e) =>
                                                                    ListView
                                                                        .builder(
                                                                      physics:
                                                                          const BouncingScrollPhysics(),
                                                                      itemCount: e
                                                                          .value
                                                                          .length,
                                                                      itemBuilder:
                                                                          (BuildContext context,
                                                                              int index) {
                                                                        Map list =
                                                                            e.value;
                                                                        String
                                                                            title =
                                                                            list.keys.elementAt(index);
                                                                        Map listTwo = list
                                                                            .values
                                                                            .elementAt(index);
                                                                        String
                                                                            subtitle =
                                                                            (() {
                                                                          if (listTwo["subtitle"] == null ||
                                                                              listTwo["subtitle"]?.isEmpty) {
                                                                            return "Subtitle";
                                                                          }
                                                                          return listTwo[
                                                                              "subtitle"];
                                                                        }());
                                                                        bool
                                                                            lock =
                                                                            listTwo["lock"] ??
                                                                                false;
                                                                        return ListTile(
                                                                          iconColor:
                                                                              Colors.tealAccent,
                                                                          title:
                                                                              Text(title),
                                                                          subtitle:
                                                                              Text(subtitle),
                                                                          trailing:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              (() {
                                                                                if (lock) {
                                                                                  return const Icon(
                                                                                    Icons.lock,
                                                                                    color: Colors.red,
                                                                                  );
                                                                                }
                                                                                return IconButton(
                                                                                    onPressed: () async {
                                                                                      var url = await fetchUrl("${widget.stream + "/" + widget.faculty + "/" + widget.dept + "/" + tab.key}/" + text, title, "", e.key);
                                                                                      download(url, "");
                                                                                    },
                                                                                    icon: const Icon(Icons.download));
                                                                              }()),
                                                                              const Icon(Icons.arrow_forward_ios_sharp),
                                                                            ],
                                                                          ),
                                                                          onTap:
                                                                              () async {
                                                                            try {
                                                                              var url = await fetchUrl("${widget.stream + "/" + widget.faculty + "/" + widget.dept + "/" + tab.key}/" + text, title, "", e.key);
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => PdfView(
                                                                                            url: url.toString(),
                                                                                            title: title,
                                                                                          )));
                                                                            } catch (e) {
                                                                              Fluttertoast.showToast(
                                                                                  msg: e.toString(),
                                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                                  // length
                                                                                  gravity: ToastGravity.BOTTOM,
                                                                                  // location
                                                                                  timeInSecForIosWeb: 1);
                                                                            }
                                                                          },
                                                                        );
                                                                      },
                                                                    ))
                                                                .toList()))
                                                  ],
                                                ),
                                              );
                                            }()),
                                          );
                                        });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(text),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_sharp,
                                          color: Colors.tealAccent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    }).toList(),
                  ),
                )),
              ],
            ),
          ),
        );
      }()),
    );
  }
}
