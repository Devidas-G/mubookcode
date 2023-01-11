import 'package:flutter/material.dart';
import 'package:mubooks/Pages/deptPage.dart';
import 'package:mubooks/Widgets.dart';
import 'package:mubooks/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dropdownValue = 'Science';
  List list = [];
  Map deptList = {};

  @override
  void initState() {
    super.initState();
    getStreams();
  }


  void getStreams() async {
    var resp = await fetchStreams();
    List l=[];
    if(resp!=null){
      l = resp['Streams'];
    }
    if (l.isNotEmpty) {
      setState(() {
        list = l;
      });
      getDept();
    }
  }

  getDept() async {
    var resp = await fetchDept(dropdownValue);
    setState((){
      deptList = resp;
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        actionsIconTheme:
        IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(
              Icons.arrow_drop_down_sharp,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
            elevation: 16,
            style: const TextStyle(),
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
              getDept();
            },
            isExpanded: true,
            items: list.map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: (() {
          if (deptList.isEmpty) {
            return LoadingScreen(isDarkMode: isDarkMode, retry: (){
              getStreams();
              setState((){});
            });
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: deptList.keys.length,
            itemBuilder: (BuildContext context, int index) {
              var text = deptList.keys.elementAt(index);
              return Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  collapsedIconColor: Colors.tealAccent,
                  iconColor: Colors.tealAccent,
                  title: Text(
                    text,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: deptList[text]?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          var depText = deptList[text][index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DeptPage(dept: depText, faculty: text, stream: dropdownValue,)),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                color: isDarkMode
                                    ? Colors.grey[900]
                                    : Colors.white,
                                child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        depText,
                                        style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    )),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }()),
      ),
    );
  }
}