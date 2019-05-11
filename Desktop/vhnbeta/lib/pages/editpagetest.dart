import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../widgets/form_inputs/location.dart';
import '../models/product.dart';
import '../scoped_modal/main.dart';
import '../models/location_data.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'verificationStatus': null,
    'creationDate': null,
    'image': 'assets/food.jpg',
  };
  String myDatetime;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _titleTextController = TextEditingController();

  Widget _buildTitleTextField(Product product) {
    if (product == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.creationDate;
    } else if (product != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (product == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else {
      _titleTextController.text = '';
    }
    return TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Product Creation Date'),
        controller: _titleTextController,
        // initialValue: product == null ? '' : product.title
        onSaved: (String value) {
          _formData['creationDate'] = value;
        },
      
    );
  }

  // Widget _buildDescriptionTextField(Product product) {
  //   return  TextFormField(
  //       focusNode: _descriptionFocusNode,
  //       maxLines: 4,
  //       decoration: InputDecoration(labelText: 'Product Description'),
  //       initialValue: product == null ? '' : product.description,
  //       validator: (String value) {
  //         // if (value.trim().length <= 0) {
  //         if (value.isEmpty || value.length < 10) {
  //           return 'Description is required and should be 10+ characters long.';
  //         }
  //       },
  //       onSaved: (String value) {
  //         _formData['description'] = value;
  //       },
      
  //   );
  // }

  // Widget _buildPriceTextField(Product product) {
  //   return TextFormField(
  //       focusNode: _priceFocusNode,
  //       keyboardType: TextInputType.number,
  //       decoration: InputDecoration(labelText: 'Product Price'),
  //       initialValue: product == null ? '' : product.price.toString(),
  //       validator: (String value) {
  //         // if (value.trim().length <= 0) {
  //         if (value.isEmpty ||
  //             !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
  //           return 'Price is required and should be a number.';
  //         }
  //       },
  //       onSaved: (String value) {
  //         _formData['price'] = double.parse(value);
  //       },
      
  //   );
  // }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.addMember,
                    model.selectProduct,
                    model.selectedProductIndex),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(product),
              // _buildDescriptionTextField(product),
              // _buildPriceTextField(product),
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              
              _buildSubmitButton(),
              // GestureDetector(
              //   onTap: _submitForm,
              //   child: Container(
              //     color: Colors.green,
              //     padding: EdgeInsets.all(5.0),
              //     child: Text('My Button'),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  void _setLocation(LocationData locData) {
    _formData['location'] = locData;
  }

  void _setDate(){
    _formData['creationDate'] =DateTime.now();
  }

  void _submitForm(
      Function addProduct, Function updateProduct,Function addMember, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(
          _titleTextController.text,
          myDatetime,
          _formData['image'],
        ); 
      addMember();
        Navigator
          .pushReplacementNamed(context, '/').then((_) => setSelectedProduct(null));
    } else {
      updateProduct(
        _titleTextController.text,
        
        _formData['image'],
      ).then((_) => Navigator
          .pushReplacementNamed(context, '/')
          .then((_) => setSelectedProduct(null)));
    }
  }

  @override
  void initState() {
    myDatetime = DateTime.now().toIso8601String();
    print(myDatetime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
