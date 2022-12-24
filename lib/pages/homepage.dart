import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestorecrud/logic/fetchdata/cubit/fetchdata_cubit.dart';
import 'package:firestorecrud/refactor/snackbar.dart';
import 'package:firestorecrud/services/serviceapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<DashboardPage> {
  List documentidlist = [];
  @override
  void initState() {
    super.initState();

    getdocumentid();
  }

  Future getdocumentid() async {
    dynamic resultant = await ServiceApi().getdocumentid();

    if (resultant == null) {
      print('Unable to retrieve id');
    } else {
      setState(() {
        documentidlist = resultant;
      });
      log(documentidlist.toString());
    }
  }

  final CollectionReference expenditurelist =
      FirebaseFirestore.instance.collection('expenditure');

  var format = DateFormat("dd-MM-yyyy");
  DateTime? initialdate = DateTime(2010);
  Timestamp? datetime2;
  Timestamp? datetimeforshow;
  String datetimeupdate = '';
  String datetimeforshow2 = '';
//for Creating
  TextEditingController namecontroller = TextEditingController();
  TextEditingController amountcontroller = TextEditingController();
// for Updating
  TextEditingController namecontroller2 = TextEditingController();
  TextEditingController amountcontroller2 = TextEditingController();

  Widget _dataofbirth(String dob) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DateTimeField(
              controller: TextEditingController(text: dob),
              decoration: InputDecoration(
                labelStyle: GoogleFonts.kreon(),
                labelText: 'Date ',
              ),
              format: format,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                        context: context,
                        initialDate: initialdate!,
                        firstDate: DateTime(2010),
                        lastDate: DateTime(2025),
                        helpText: "SELECT DATE OF BIRTH",
                        cancelText: "CANCEL",
                        confirmText: "OK",
                        fieldHintText: "DATE/MONTH/YEAR",
                        fieldLabelText: "ENTER YOUR DATE OF BIRTH",
                        errorFormatText: "Enter a Valid Date",
                        errorInvalidText: "Date Out of Range")
                    .then((value) {
                  setState(() {
                    datetime2 = Timestamp.fromDate(value!);
                  });
                  return value;
                });
              },
            ),
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    var c = context.watch<FetchdataCubit>();

    var status = c.state.status;
    switch (status) {
      case Status.initial:
        log('Initial');
        break;
      case Status.loading:
        log('loading');
        break;
      case Status.loaded:
        log('Loaded');
        break;
      case Status.error:
        log('Error');
        break;
      default:
    }
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            onPressed: (() {
              showDialog(
                context: context,
                builder: (cnt) {
                  return StatefulBuilder(builder: ((BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      side:
                                          const BorderSide(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    namecontroller.clear();
                                    amountcontroller.clear();
                                    datetime2 = null;
                                    datetimeupdate = '';
                                    setState(() {});
                                  },
                                  child: const Text("CANCEL")),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    onPressed: () async {
                                      await ServiceApi()
                                          .addexpenditureitem(
                                              amount: int.parse(
                                                  amountcontroller.text),
                                              date: datetime2!,
                                              name: namecontroller.text)
                                          .whenComplete(() {
                                        context.router.pop();
                                        getdocumentid();
                                        CustomSnackBar(
                                            context,
                                            const Text(
                                                'Added Items Successfully'),
                                            Colors.green);
                                        namecontroller.clear();
                                        amountcontroller.clear();
                                        datetime2 = null;
                                        datetimeupdate = '';
                                        setState(() {});
                                      });
                                    },
                                    child: const Text("ADD")),
                              )
                            ],
                          ),
                        ],
                        title: Text(
                          "Add Expenditure Items",
                          style: GoogleFonts.kreon(),
                        ),
                        content: SingleChildScrollView(
                            child: Form(
                          child: SizedBox(
                            height: 180,
                            child: Column(children: [
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: namecontroller,
                                  decoration: InputDecoration(
                                    hintStyle: GoogleFonts.kreon(),
                                    hintText: 'Expenditure Item Name',
                                  )),
                              _dataofbirth(datetimeupdate),
                              TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: amountcontroller,
                                  decoration: InputDecoration(
                                    hintStyle: GoogleFonts.kreon(),
                                    hintText: 'Expenditure Amount',
                                  )),
                            ]),
                          ),
                        )));
                  }));
                },
              );
            }),
            label: Text(
              'Add Expenditure Item',
              style: GoogleFonts.kreon(),
            )),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Text(
                          'CRUD OPERATION ON FIRESTORE',
                          style: GoogleFonts.kreon(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Container(
                            color: Colors.green,
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          'All Expenditure List Items',
                          style: GoogleFonts.kreon(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    child: StreamBuilder(
                      stream: expenditurelist.snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> streamsnapshot) {
                        if (streamsnapshot.hasData) {
                          return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: streamsnapshot.data!.docs.length,
                              shrinkWrap: true,
                              itemBuilder: ((context, index) {
                                final DocumentSnapshot documentSnapshot =
                                    streamsnapshot.data!.docs[index];
                                return ListTile(
                                  title: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        datetimeforshow =
                                            documentSnapshot['date'];
                                        var date = datetimeforshow!.toDate();
                                        setState(() {
                                          datetimeforshow2 =
                                              "${date.day}-${date.month}-${date.year}";
                                        });
                                        showDialog(
                                            context: context,
                                            builder: ((context) {
                                              return StatefulBuilder(builder:
                                                  ((context, setState) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "Expenditure Details",
                                                    style: GoogleFonts.kreon(),
                                                  ),
                                                  content:
                                                      SingleChildScrollView(
                                                          child: SizedBox(
                                                    height: 106,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 15),
                                                      child: Column(children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Items Name : ',
                                                              style: GoogleFonts.kreon(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20),
                                                            ),
                                                            Text(
                                                                documentSnapshot[
                                                                    'name'],
                                                                style:
                                                                    GoogleFonts
                                                                        .kreon())
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                                'Items Amount : ',
                                                                style: GoogleFonts.kreon(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20)),
                                                            Text(
                                                                documentSnapshot[
                                                                        'amount']
                                                                    .toString(),
                                                                style:
                                                                    GoogleFonts
                                                                        .kreon())
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text('Date : ',
                                                                style: GoogleFonts.kreon(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20)),
                                                            Text(
                                                                datetimeforshow2,
                                                                style:
                                                                    GoogleFonts
                                                                        .kreon())
                                                          ],
                                                        ),
                                                      ]),
                                                    ),
                                                  )),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: (() {
                                                          context.router.pop();
                                                        }),
                                                        child: const Text('OK'))
                                                  ],
                                                );
                                              }));
                                            }));
                                      },
                                      icon: const Icon(
                                        Icons.price_change,
                                        color: Color.fromARGB(255, 255, 119, 7),
                                        size: 35,
                                      ),
                                      label: Text(
                                        documentSnapshot["name"],
                                        style: GoogleFonts.kreon(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  trailing: PopupMenuButton<int>(
                                    itemBuilder: (context) => [
                                      // PopupMenuItem 1
                                      PopupMenuItem(
                                        value: 1,
                                        // row with 2 children
                                        child: Row(
                                          children: [
                                            const Icon(Icons.edit),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Update",
                                              style: GoogleFonts.kreon(),
                                            )
                                          ],
                                        ),
                                      ),
                                      // PopupMenuItem 2
                                      PopupMenuItem(
                                        value: 2,
                                        // row with two children
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Delete",
                                              style: GoogleFonts.kreon(),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                    offset: const Offset(5, 40),

                                    elevation: 2,
                                    // on selected we show the dialog box
                                    onSelected: (value) {
                                      // if value 1 show dialog
                                      if (value == 1) {
                                        datetime2 = documentSnapshot['date'];
                                        var date = datetime2!.toDate();
                                        setState(() {
                                          namecontroller.text =
                                              documentSnapshot['name'];
                                          amountcontroller.text =
                                              documentSnapshot['amount']
                                                  .toString();
                                          datetimeupdate =
                                              "${date.day}-${date.month}-${date.year}";
                                        });
                                        showDialog(
                                          context: context,
                                          builder: (cnt) {
                                            return StatefulBuilder(builder:
                                                ((BuildContext context,
                                                    void Function(
                                                            void Function())
                                                        setState) {
                                              return AlertDialog(
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                side: const BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              namecontroller
                                                                  .clear();
                                                              amountcontroller
                                                                  .clear();
                                                              datetime2 = null;
                                                              datetimeupdate =
                                                                  '';
                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                                "CANCEL")),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: ElevatedButton(
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green),
                                                              onPressed:
                                                                  () async {
                                                                await ServiceApi()
                                                                    .updateexpenditureitem(
                                                                        id: documentidlist[
                                                                            index],
                                                                        amount: int.parse(amountcontroller
                                                                            .text),
                                                                        date:
                                                                            datetime2!,
                                                                        name: namecontroller
                                                                            .text)
                                                                    .whenComplete(
                                                                        () {
                                                                  context.router
                                                                      .pop();
                                                                  CustomSnackBar(
                                                                      context,
                                                                      const Text(
                                                                          'Updated Items Successfully'),
                                                                      Colors
                                                                          .green);
                                                                  getdocumentid();
                                                                  namecontroller
                                                                      .clear();
                                                                  amountcontroller
                                                                      .clear();
                                                                  datetime2 =
                                                                      null;
                                                                  datetimeupdate =
                                                                      '';
                                                                  setState(
                                                                      () {});
                                                                });
                                                              },
                                                              child: const Text(
                                                                  "UpDATE")),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                  title: Text(
                                                    "Update Expenditure Items",
                                                    style: GoogleFonts.kreon(),
                                                  ),
                                                  content:
                                                      SingleChildScrollView(
                                                          child: Form(
                                                    child: SizedBox(
                                                      height: 180,
                                                      child: Column(children: [
                                                        TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            controller:
                                                                namecontroller,
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle:
                                                                  GoogleFonts
                                                                      .kreon(),
                                                              hintText:
                                                                  'Expenditure Item Name',
                                                            )),
                                                        _dataofbirth(
                                                            datetimeupdate),
                                                        TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller:
                                                                amountcontroller,
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle:
                                                                  GoogleFonts
                                                                      .kreon(),
                                                              hintText:
                                                                  'Expenditure Amount',
                                                            )),
                                                      ]),
                                                    ),
                                                  )));
                                            }));
                                          },
                                        );
                                      } else if (value == 2) {
                                        showDialog(
                                            context: context,
                                            builder: ((BuildContext context) {
                                              return StatefulBuilder(builder:
                                                  ((context, setState) {
                                                return AlertDialog(
                                                  title: Text('Confirm',
                                                      style:
                                                          GoogleFonts.kreon()),
                                                  content: Text(
                                                      'Are You Sure to Delete?',
                                                      style:
                                                          GoogleFonts.kreon()),
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.grey,
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              "CANCEL",
                                                              style: GoogleFonts
                                                                  .kreon(),
                                                            )),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: ElevatedButton(
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green),
                                                              onPressed:
                                                                  () async {
                                                                await ServiceApi()
                                                                    .deleteexpenditureitem(
                                                                        id: documentidlist[
                                                                            index])
                                                                    .whenComplete(
                                                                        () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  getdocumentid();
                                                                });
                                                              },
                                                              child: Text("YES",
                                                                  style: GoogleFonts
                                                                      .kreon())),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }));
                                            }));
                                      }
                                    },
                                  ),
                                );
                              }));
                        } else {
                          return Center(
                            child: Container(
                              alignment: Alignment.center,
                              height: 100,
                              width: 150,
                              child: Column(
                                children: [
                                  Text(
                                    'Please Wait...',
                                    style: GoogleFonts.kreon(fontSize: 18),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
