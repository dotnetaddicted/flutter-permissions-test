import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<FileSystemEntity>> _items;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _items = Future<List<FileSystemEntity>>.delayed(
      const Duration(seconds: 0),
      () {
        return _getFileSystemView();
      },
    );
  }

  Future<List<FileSystemEntity>> _getFileSystemView() async {
    if (await Permission.storage.request().isGranted &&
        await Permission.manageExternalStorage.request().isGranted) {
      var storageRootPath = '/storage/emulated/0';
      final List<FileSystemEntity> rawList = await Directory(storageRootPath)
          .list()
          .map((event) => (event))
          .toList();

// SORT ITEMS BY TYPE
// Add DIRS to resultant list

      List<FileSystemEntity> all = rawList.where((item) {
        return item.statSync().type == FileSystemEntityType.directory;
      }).toList();
      all.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

      List<FileSystemEntity> files = rawList.where((item) {
        return item.statSync().type == FileSystemEntityType.file;
      }).toList();
      files
          .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
      all.addAll(files);
      return all;
    } else
      return [];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder<List<FileSystemEntity>>(
          future: _items,
          builder: (BuildContext context,
              AsyncSnapshot<List<FileSystemEntity>> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              children = [
                Container(
                  height: mediaQuery.size.height * 0.85,
                  width: double.infinity,
                  child: ListView.builder(
                      itemBuilder: (ctx, index) {
                        final item = snapshot.data![index];
                        return Text(
                            item.statSync().type.toString() + ' - ' + item.path,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ));
                      },
                      itemCount: snapshot.data!.length),
                ),
              ];
            } else if (snapshot.hasError) {
              children = [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ];
            } else {
              children = [Text('Loading ...')];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            );
          },
        ),
      ],
    );
  }
}
