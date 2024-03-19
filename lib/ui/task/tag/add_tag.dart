import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/Todo.dart';
import '../viewmodel/TodoViewModel.dart';

class AddTag extends StatefulWidget {
  AddTag({Key? key}) : super(key: key);

  @override
  State<AddTag> createState() => _AddTagState();
}

class _AddTagState extends State<AddTag> {
  final TextEditingController _tagTypeController = TextEditingController();
  late String selectedTag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Tag'),
        FutureBuilder<List<TagType>>(
          future: _fetchAllTagTypes(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<String> tagTypeNames =
                  snapshot.data!.map((tagType) => tagType.tagName).toList();

              return DropdownButton<String>(
                value: selectedTag,
                onChanged: (value) {
                  setState(() {
                    selectedTag = value!;
                    if (selectedTag == 'createNewTag') {
                      _showAddTagTypeDialog(context);
                    }
                  });
                },
                items: [
                  ...tagTypeNames.map((tagName) {
                    return DropdownMenuItem<String>(
                      value: tagName,
                      child: Text(tagName),
                    );
                  }),
                  if (!tagTypeNames.contains(selectedTag))
                    DropdownMenuItem<String>(
                      value: selectedTag,
                      child: Text(selectedTag),
                    ),
                  const DropdownMenuItem<String>(
                    value: 'createNewTag',
                    child: Text('Create New Tag'),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return const Text('Error loading tag types');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<List<TagType>> _fetchAllTagTypes(BuildContext context) async {
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    return await todoViewModel.fetchTags();
  }

  void _showAddTagTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Tag'),
          content: TextField(
            controller: _tagTypeController,
            decoration: const InputDecoration(labelText: 'Tag Name'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final newTagType = TagType(
                  tagName: _tagTypeController.text,
                  icon: Icons.tag,
                );

                Provider.of<TodoViewModel>(context, listen: false)
                    .addTagType(newTagType);

                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
