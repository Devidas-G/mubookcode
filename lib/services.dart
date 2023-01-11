import 'dart:convert';
import 'package:http/http.dart' as http;
//http://10.0.2.2:5000
//https://ubooks.onrender.com
//railway: https://flask-production-c153.up.railway.app/
String apiUrl = "https://flask-production-c153.up.railway.app/";

fetchStreams()async{
  try{
    http.Response response =await http.get(Uri.parse(apiUrl));
    var decode = jsonDecode(response.body);
    if(response.statusCode == 200){
      return decode;
    }
  }catch(e){
    print(e);
  }

}

fetchDept(String stream)async{
  var url = "/getDept?stream="+stream;
  try{
    http.Response response =await http.get(Uri.parse(apiUrl+url));
    var decode = jsonDecode(response.body);
    if(response.statusCode == 200){
      return decode;
    }
  }catch(e){
    print(e);
  }
}

fetchInfo(String stream,String faculty,String dept)async{
  var url = apiUrl+"/getinfo?path="+stream+'/'+faculty+'/'+dept;
  try{
    http.Response response =await http.get(Uri.parse(url));
    var decode = jsonDecode(response.body);
    if(response.statusCode == 200){
      return decode;
    }
  }catch(e){
    print(e);
  }
}

fetchList(String path)async{
  var url = apiUrl+"/getlist?path="+path;
  try{
    http.Response response =await http.get(Uri.parse(url));
    var decode = jsonDecode(response.body);
    if(response.statusCode == 200){
      return decode;
    }
  }catch(e){
    print(e);
  }
}

fetchUrl(String path,String file,uid,String sem)async{
  var url = apiUrl+"/geturl?path="+path+"&&file="+file+"&&uid="+uid+"&&sem="+sem;
  try{
    http.Response response =await http.get(Uri.parse(url));
    var decode = response.body;
    if(response.statusCode == 200){
      if(response.headers["content-type"]!.contains("url")){
        return decode;
      }else if(response.headers["content-type"]!.contains("error")){
        return Future.error(decode);
      }
    }
  }catch(e){
    print(e);
  }
}