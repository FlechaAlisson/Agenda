import 'dart:io';

import 'package:agenda/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'contactPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> listC = List();
  @override
  void initState() {
    super.initState();

    _getAllContact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Contatos"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
        padding: EdgeInsets.all(10),
        itemCount: listC.length,
      ),
    );
  }

  Widget _contactCard(context, index) {
    return GestureDetector(
      onTap: () => _showOptions(context, index),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: listC[index].img != null
                            ? FileImage(File(listC[index].img))
                            : AssetImage("images/person.png"),
                        fit: BoxFit.cover)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listC[index].name ?? "", //se for vazio, mostra o vazio
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      listC[index].email ?? "", //se for vazio, mostra o vazio
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      listC[index].phone ?? "", //se for vazio, mostra o vazio
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                          onPressed: () {
                            launch("tel:" + listC[index].phone);
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: listC[index]);
                          },
                          child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                          onPressed: () {
                            setState(() {
                              helper.deleteContact(listC[index].id);
                              listC.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactPage(
            contact: contact,
          ),
        ));
    if (recContact != null) {
      //se eu recebi um contato
      if (contact != null) {
        //e se eu enviei um contato
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
    }
    _getAllContact();
  }

  void _getAllContact() {
    helper.getAllContacts().then((list) {
      setState(() {
        listC = list;
      });
    });
  }
}
