import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './editpagetest.dart';
import '../scoped_modal/main.dart';

class ListPage extends StatefulWidget {
  final MainModel model;

  ListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ListPageState();
  }
}

class _ListPageState extends State<ListPage> {
  @override
  initState() {
    widget.model.fetchProducts(onlyForUser: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectProduct(model.allProducts[index].id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ProductEditPage();
            },
          ),
        ).then((_) {
          model.selectProduct(null);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.allProducts[index].id),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectProduct(model.allProducts[index].id);
                  model.deleteProduct();
                } else if (direction == DismissDirection.startToEnd) {
                  print('Swiped start to end');
                } else {
                  print('Other swiping');
                }
              },
              background: Container(color: Colors.red),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allProducts[index].image),
                    ),
                    title: Text(model.allProducts[index].creationDate),
                    subtitle:
                        Text('\$${model.allProducts[index].userEmail.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider()
                ],
              ),
            );
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }
}
