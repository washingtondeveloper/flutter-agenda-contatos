import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderAz, orderZa }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper _helper = ContactHelper();

  List<Contact> _contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  void _getAllContacts() {
    _helper.getAllContacts().then((list) {
      print('vvv');
      print(list.length);
      setState(() {
        _contacts = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar de A-Z'),
                value: OrderOptions.orderAz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar de Z-A'),
                value: OrderOptions.orderZa,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          onPressed: _showContactPage,
          child: Icon(Icons.add),
          backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: _contacts[index].img != null
                          ? FileImage(File(_contacts[index].img))
                          : AssetImage('images/person.png')
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_contacts[index].name ?? '', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(_contacts[index].email ?? '', style: TextStyle(fontSize: 18.0)),
                    Text(_contacts[index].phone ?? '', style: TextStyle(fontSize: 18.0))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _orderList(OrderOptions result) {
    switch(result)  {
      case OrderOptions.orderAz:
        _contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderZa:
        _contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
      default:
        break;
    }
    setState(() {});
  }

  void _showOptions(context, index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text('Ligar', style: TextStyle( color: Colors.deepPurpleAccent, fontSize: 20.0)),
                        onPressed: () {
                          Navigator.pop(context);
                          launch('tel:${_contacts[index].phone}');
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text('Editar', style: TextStyle( color: Colors.deepPurpleAccent, fontSize: 20.0)),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: _contacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text('Excluir', style: TextStyle( color: Colors.deepPurpleAccent, fontSize: 20.0)),
                        onPressed: () {
                          _helper.deleteContact(_contacts[index].id);
                          setState(() {
                            _contacts.removeAt(index);
                            Navigator.pop(context);
                          });

                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact))
    );
    if(recContact != null) {
      if(contact != null) {
        await _helper.updateContact(recContact);
      } else {
        await _helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }
}
