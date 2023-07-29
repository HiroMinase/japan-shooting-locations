import "package:cached_network_image/cached_network_image.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";

// ロケーション更新用のダイアログ
class SetLocationDialog extends StatefulWidget {
  const SetLocationDialog({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String imageUrl;

  @override
  State<SetLocationDialog> createState() => _SetLocationDialogState();
}

class _SetLocationDialogState extends State<SetLocationDialog> {
  final _nameEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameEditingController.text = widget.name;
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10.0),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              placeholder: (context, url) => const SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Text("${widget.name}を編集"),
          const SizedBox(height: 16),
          TextField(
            controller: _nameEditingController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("名前"),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final newName = _nameEditingController.value.text;
              if (newName.isEmpty) {
                throw Exception("名前を入力してください");
              }
              try {
                await _set(
                  widget.id,
                  newName,
                );
              } on Exception catch (e) {
                debugPrint(
                  "🚨 ロケーション更新に失敗 $e",
                );
              }
              navigator.popUntil((route) => route.isFirst);
            },
            child: const Text("更新"),
          ),
        ],
      ),
    );
  }

  // Frestore のデータを更新
  Future<void> _set(
    String id,
    String newName,
  ) async {
    await GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection("locations"),
    ).set(
      id: id,
      data: {
        "name": newName,
      },
      options: SetOptions(merge: true),
    );
    debugPrint("🌍 ロケーションを更新: "
        "id: $id");
  }
}
