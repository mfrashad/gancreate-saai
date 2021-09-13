import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Edit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
          children: <Widget>[
            EditForm()
          ]
        );
  }
}

class EditForm extends StatefulWidget {
  EditForm({Key? key}) : super(key: key);

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  Map<String, double> _attributes = {
    'Gender': 0, 
    'Realism': 0,
    'Gray Hair': 0,
    'Hair Length': 0,
    'Chin': 0,
    'Ponytail': 0,
    'Black Hair': 0 
  };

  var img;

  Future<http.Response> requestEditImage() async {
    final response =  await http.post(
      Uri.parse('https://4f7abd5983b3.ngrok.io/edit'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "seed": 0,
        "attributes": _attributes
      }),
    );
    return response;
  }

  void editImage() async {
    http.Response response = await requestEditImage();
    setState(() {
        img = response.bodyBytes;  
    });
  }


  Future<http.Response> getImage() async {
    final response =  await http.get(Uri.parse("https://4f7abd5983b3.ngrok.io/generate"));
    print(response.body);
    return response;
  }
  

  @override
  Widget build(BuildContext context) {
    // Full screen width and height
    // final image = getImage();
    double width = MediaQuery.of(context).size.width;
    double screen_height = MediaQuery.of(context).size.height;

    return Container(
      width: 400,
      height: screen_height - 100,
       child: Column(
         children: [
           Container(
              child:  img != null ? Image.memory(img) : Text('Loading...'),
              width: 400,
              height: 400
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 0),
                child: ListView.builder(
                  padding: const EdgeInsets.only(right: 0),
                  itemCount: _attributes.length,
                  itemBuilder: (BuildContext context, int index) {
                    String key = _attributes.keys.elementAt(index);
                    return AttributeSlider(
                      label: key,
                      value: _attributes[key],
                      onChanged: (double value) {
                        //requestEditImage();
                        setState(() { _attributes[key] = value; });
                      },
                      onChangeEnd: (double value) => editImage(),
                    );
                  }
                )
              )
            )
         ],
       ),
    );
  }
}

class AttributeSlider extends StatelessWidget {
  AttributeSlider({
    Key? key,
    this.label,
    this.value = 0,
    required this.onChanged,
    required this.onChangeEnd
  }) : super(key: key);

  final label;
  final value;
  // final VoidCallback onChanged;
  final Function(double) onChanged;
  final Function(double) onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return 
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          child: Text(label, textAlign: TextAlign.center,),
        ),
        Expanded(
          child:  SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColorLight,
            inactiveTrackColor: Theme.of(context).primaryColorLight,
            trackShape: RectangularSliderTrackShape(),
            trackHeight: 4.0,
            thumbColor: Theme.of(context).primaryColor,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayColor: Theme.of(context).primaryColor.withAlpha(32),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: value,
            min: -20,
            max: 20,
            divisions: 40,
            label: value.round().toString(),
            onChanged: (double val) => onChanged(val),
            onChangeEnd: (double val) => onChangeEnd(val),
          )
        )
        )
       
      ],
    );
  }
}