import 'dart:convert';
import 'dart:typed_data';

import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_desafio_tecnico/repository.dart';

import 'model_file_attachment.dart';
import 'model_file_upload.dart';
import 'page_user.dart';

class PageMain extends StatefulWidget {
  const PageMain(
      {super.key, required this.authorization, required this.userId});
  final String authorization;
  final String userId;
  @override
  State<PageMain> createState() => _PageMainState();
}

class _PageMainState extends State<PageMain> {
  final List<FileAttachment> _fileAttachmentList = [];
  List<FileUpload>? _fileUploadList;
  bool _sending = false;

  void _getFileUploadList() async {
    final result = await Repository.getFileUploadList(widget.authorization);
    if (mounted) {
      if (result.statusCode < 400) {
        final jsonResponse = json.decode(result.body);
        Iterable i = jsonResponse['data'];
        List<FileUpload> list = List<FileUpload>.from(
          i.map((o) => FileUpload.fromMap(o)),
        );
        setState(() {
          _fileUploadList = list;
        });
      } else {
        if (_fileUploadList == null) {
          setState(() {
            _fileUploadList = [];
          });
        }
      }
    }
  }

  void _attachFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (mounted && result != null && result.files.isNotEmpty) {
      final found = _fileAttachmentList.firstWhere(
        (e) => e.fileName == result.files.first.name,
        orElse: () => FileAttachment(
          fileName: '',
          fileBytes: Uint8List(0),
        ),
      );
      if (found.fileName.isEmpty) {
        final pickedFile = FileAttachment(
          fileName: result.files.first.name,
          fileBytes: result.files.first.bytes!,
        );
        setState(() {
          _fileAttachmentList.insert(0, pickedFile);
        });
      } else {
        const snackBar = SnackBar(
          content: Text(
            'Este item já está anexado.',
            style: TextStyle(color: Colors.white),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future _sendFile(FileAttachment file) async {
    final response = await Repository.sendFile(widget.authorization, file);
    if (response.statusCode < 400) {
      final uploadedFile = FileUpload.fromJson(response.body);
      setState(() {
        final index = _fileAttachmentList.indexOf(file);
        if (index >= 0) {
          _fileAttachmentList.removeAt(index);
        }
        _fileUploadList?.insert(0, uploadedFile);
      });
    }
  }

  Future _deleteFile(String id, int index) async {
    final response = await Repository.deleteFile(widget.authorization, id);
    if (mounted) {
      if (response.statusCode < 400) {
        setState(() {
          _fileUploadList!.removeAt(index);
        });
      } else {
        const snackBar = SnackBar(
          content: Text(
            'Erro ao excluir arquivo.',
            style: TextStyle(color: Colors.white),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void _sendFiles() async {
    setState(() {
      _sending = true;
    });
    await Future.wait(_fileAttachmentList.map((e) {
      return _sendFile(e);
    }).toList());
    setState(() {
      _sending = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getFileUploadList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bem-vindo (a)',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Usuário'),
                    content: PageUser(
                      authorization: widget.authorization,
                      userId: widget.userId,
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Fechar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.person),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirmação'),
                    content: const Text('Você tem certeza que deseja sair?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Confirmar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.exit_to_app),
            color: Colors.black,
          ),
          const SizedBox(
            width: 16,
          ),
        ],
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 24,
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 128),
              child: Text(
                'Itens anexados anteriormente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Center(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: SizedBox(
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: double.maxFinite,
                                  child: Material(
                                    color: Colors.white,
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _sending
                                          ? null
                                          : () {
                                              _attachFile();
                                            },
                                      child: const Column(
                                        children: [
                                          SizedBox(
                                            height: 24,
                                          ),
                                          Icon(
                                            Icons.add,
                                            size: 32,
                                          ),
                                          Text(
                                            'Clique aqui para\nanexar um arquivo',
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                const Text(
                                  'Itens anexados',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  height: 180,
                                  child: _fileAttachmentList.isEmpty
                                      ? Center(
                                          child: Text(
                                            'Nenhum item anexado',
                                            style: TextStyle(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount:
                                              _fileAttachmentList.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index ==
                                                _fileAttachmentList.length) {
                                              return const SizedBox(
                                                height: 32,
                                              );
                                            }
                                            final item =
                                                _fileAttachmentList[index];
                                            return ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0,
                                              title: Text(item.fileName),
                                              leading:
                                                  const Icon(Icons.attach_file),
                                              trailing: _sending
                                                  ? const Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 12),
                                                      child: SizedBox(
                                                        width: 14,
                                                        height: 14,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                    )
                                                  : IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _fileAttachmentList
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      color: Colors.pink,
                                                      icon: const Icon(Icons
                                                          .delete_outlined),
                                                    ),
                                            );
                                          },
                                        ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  width: double.maxFinite,
                                  child: ElevatedButton(
                                    onPressed:
                                        _fileAttachmentList.isEmpty || _sending
                                            ? null
                                            : () {
                                                _sendFiles();
                                              },
                                    style: _fileAttachmentList.isEmpty ||
                                            _sending
                                        ? ButtonStyle(
                                            elevation: MaterialStateProperty
                                                .all<double>(0),
                                            fixedSize:
                                                MaterialStateProperty.all<Size>(
                                              const Size(double.maxFinite, 40),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.grey.shade300),
                                          )
                                        : ButtonStyle(
                                            elevation: MaterialStateProperty
                                                .all<double>(0),
                                            fixedSize:
                                                MaterialStateProperty.all<Size>(
                                              const Size(double.maxFinite, 40),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black),
                                          ),
                                    child: const Text('Enviar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: Center(
                      child: _fileUploadList == null
                          ? const CircularProgressIndicator()
                          : _fileUploadList!.isEmpty
                              ? Text(
                                  'Nenhum arquivo enviado.',
                                  style: TextStyle(
                                    color: Colors.grey.shade300,
                                  ),
                                )
                              : ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    child: ListView.builder(
                                      itemCount: _fileUploadList!.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == _fileUploadList!.length) {
                                          return const SizedBox(
                                            height: 32,
                                          );
                                        }
                                        final item = _fileUploadList![index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                side: BorderSide(
                                                  color: Colors.grey.shade300,
                                                )),
                                            title: Text(
                                              item.nomeUpload!,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Confirmação'),
                                                          content: const Text(
                                                              'Excluir este arquivo do servidor?'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: const Text(
                                                                  'Cancelar'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Confirmar'),
                                                              onPressed: () {
                                                                _deleteFile(
                                                                    item.id!,
                                                                    index);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  iconSize: 16,
                                                  color: Colors.pink,
                                                  icon: const Icon(
                                                      Icons.delete_outline),
                                                ),
                                                IconButton(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onPressed: () {
                                                    final Stream<int> stream =
                                                        Stream.fromIterable(item
                                                            .arquivo!.data!);
                                                    download(stream,
                                                        item.nomeUpload!);
                                                  },
                                                  iconSize: 16,
                                                  color: Colors.yellow.shade700,
                                                  icon: const Icon(
                                                      Icons.arrow_downward),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 48,
          ),
        ],
      ),
    );
  }
}
