import 'package:flutter/material.dart';

class UnitConverterApp extends StatefulWidget {
  @override
  _UnitConverterAppState createState() => _UnitConverterAppState();
}

class _UnitConverterAppState extends State<UnitConverterApp> {
  String _currentCategory = 'Length';
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  String _fromUnit = 'meters';
  String _toUnit = 'kilometers';

  final Map<String, Map<String, List<String>>> _categories = {
    'Length': {
      'units': ['meters', 'kilometers', 'miles', 'feet', 'inches', 'yards'],
      'symbols': ['m', 'km', 'mi', 'ft', 'in', 'yd']
    },
    'Weight': {
      'units': ['kilograms', 'grams', 'pounds', 'ounces'],
      'symbols': ['kg', 'g', 'lb', 'oz']
    },
    'Temperature': {
      'units': ['Celsius', 'Fahrenheit', 'Kelvin'],
      'symbols': ['°C', '°F', 'K']
    }
  };

  final Map<String, Map<String, double>> _conversions = {
    'Length': {
      'meters_to_kilometers': 0.001,
      'meters_to_miles': 0.000621371,
      'meters_to_feet': 3.28084,
      'meters_to_inches': 39.3701,
      'meters_to_yards': 1.09361,
      'kilometers_to_meters': 1000,
      'kilometers_to_miles': 0.621371,
      'miles_to_meters': 1609.34,
      'feet_to_meters': 0.3048,
      'inches_to_meters': 0.0254,
      'yards_to_meters': 0.9144,
    },
    'Weight': {
      'kilograms_to_grams': 1000,
      'kilograms_to_pounds': 2.20462,
      'kilograms_to_ounces': 35.274,
      'grams_to_kilograms': 0.001,
      'pounds_to_kilograms': 0.453592,
      'ounces_to_kilograms': 0.0283495,
    },
  };

  @override
  void initState() {
    super.initState();
    _fromUnit = _categories[_currentCategory]!['units']![0];
    _toUnit = _categories[_currentCategory]!['units']![1];
    _inputController.addListener(_convertUnits);
  }

  String _getSymbol(String unit) {
    int index = _categories[_currentCategory]!['units']!.indexOf(unit);
    return _categories[_currentCategory]!['symbols']![index];
  }

  void _convertUnits() {
    if (_inputController.text.isEmpty) {
      _outputController.text = '';
      return;
    }

    double? inputValue = double.tryParse(_inputController.text);
    if (inputValue == null) {
      _outputController.text = 'Invalid input';
      return;
    }

    if (_currentCategory == 'Temperature') {
      _convertTemperature(inputValue);
      return;
    }

    String conversionKey = '${_fromUnit}_to_${_toUnit}';
    Map<String, double> categoryConversions = _conversions[_currentCategory]!;

    double result;
    if (_fromUnit == _toUnit) {
      result = inputValue;
    } else if (categoryConversions.containsKey(conversionKey)) {
      result = inputValue * categoryConversions[conversionKey]!;
    } else {
      // Convert to base unit first, then to target unit
      String toBaseKey = '${_fromUnit}_to_${_categories[_currentCategory]!['units']![0]}';
      String fromBaseKey = '${_categories[_currentCategory]!['units']![0]}_to_${_toUnit}';

      double toBase = categoryConversions[toBaseKey]! * inputValue;
      result = toBase * categoryConversions[fromBaseKey]!;
    }

    _outputController.text = result.toStringAsFixed(4);
  }

  void _convertTemperature(double value) {
    double result;
    if (_fromUnit == _toUnit) {
      result = value;
    } else if (_fromUnit == 'Celsius' && _toUnit == 'Fahrenheit') {
      result = (value * 9/5) + 32;
    } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Celsius') {
      result = (value - 32) * 5/9;
    } else if (_fromUnit == 'Celsius' && _toUnit == 'Kelvin') {
      result = value + 273.15;
    } else if (_fromUnit == 'Kelvin' && _toUnit == 'Celsius') {
      result = value - 273.15;
    } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Kelvin') {
      result = (value - 32) * 5/9 + 273.15;
    } else if (_fromUnit == 'Kelvin' && _toUnit == 'Fahrenheit') {
      result = (value - 273.15) * 9/5 + 32;
    } else {
      result = value;
    }

    _outputController.text = result.toStringAsFixed(2);
  }

  void _swapUnits() {
    setState(() {
      String temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      if (_inputController.text.isNotEmpty) {
        _convertUnits();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Unit Converter',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildCategorySelector(),
                SizedBox(height: 20),
                _buildConverterCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('Category: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currentCategory,
                isExpanded: true,
                items: _categories.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _currentCategory = value!;
                    _fromUnit = _categories[_currentCategory]!['units']![0];
                    _toUnit = _categories[_currentCategory]!['units']![1];
                    _convertUnits();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConverterCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildUnitSelector(_fromUnit, (value) {
              setState(() {
                _fromUnit = value!;
                _convertUnits();
              });
            }, 'From'),
            SizedBox(height: 16),
            _buildSwapButton(),
            SizedBox(height: 16),
            _buildUnitSelector(_toUnit, (value) {
              setState(() {
                _toUnit = value!;
                _convertUnits();
              });
            }, 'To'),
            SizedBox(height: 24),
            _buildInputField(),
            SizedBox(height: 24),
            _buildOutputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector(String value, Function(String?) onChanged, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: _categories[_currentCategory]!['units']!.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text('$unit (${_getSymbol(unit)})'),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return IconButton(
      icon: Icon(Icons.swap_vert, size: 30, color: Colors.blue[700]),
      onPressed: _swapUnits,
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: _inputController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Enter value',
        suffixText: _getSymbol(_fromUnit),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildOutputField() {
    return TextField(
      controller: _outputController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Result',
        suffixText: _getSymbol(_toUnit),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}