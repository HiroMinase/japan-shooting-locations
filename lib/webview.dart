import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";

// 機能の要望やバグ報告フォーム
class RequestFormDialog extends StatefulWidget {
  const RequestFormDialog({super.key});

  @override
  RequestFormDialogState createState() => RequestFormDialogState();
}

class RequestFormDialogState extends State<RequestFormDialog> {
  final _textEditingController = TextEditingController();
  final _nameEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          "機能の要望やバグ報告",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textEditingController,
            minLines: 6,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("内容"),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameEditingController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("名前(任意入力)"),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final text = _textEditingController.value.text;
              final name = _nameEditingController.value.text;
              if (text.isEmpty) {
                throw Exception("内容を入力してください");
              }
              try {
                await _addRequest(text, name);
              } on Exception catch (e) {
                debugPrint(
                  "🚨 送信に失敗 $e",
                );
              }
              navigator.pop();
            },
            child: const Text(
              "送信",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  //　Firestore に登録
  Future<void> _addRequest(
    String text,
    String name,
  ) async {
    await FirebaseFirestore.instance.collection("requests").add({
      "text": text,
      "name": name,
      "createdAt": Timestamp.now(),
    });
    debugPrint("🌍 リクエストを作成: "
        "text: $text, "
        "name: $name");
  }
}
