import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'Screen2.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _modiChatScreenState();
}

class _modiChatScreenState extends State<MapScreen> {
  List<String> welcomeItems = [];
  List<String> categoryItems = [];

  static const int maxWelcome = 3;
  static const int maxCategory = 5;

  Future<void> _showEditDialog({
    required String initialText,
    required ValueChanged<String> onConfirm,
  }) async {
    final controller = TextEditingController(text: initialText);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE9EFF0),
        title: const Text('내용 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              onConfirm(controller.text);
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          customTopBar(),
          const Divider(color: Color(0xFFE7E7E7), thickness: 1, height: 0.5),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    _buildAddBox(
                      label: '환영 메시지',
                      count: welcomeItems.length,
                      max: maxWelcome,
                      onAdd: () {
                        if (welcomeItems.length < maxWelcome) {
                          setState(() => welcomeItems.add('안녕하세요'));
                        }
                      },
                    ),
                    for (int i = 0; i < welcomeItems.length; i++)
                      _buildEditableBox(
                        text: welcomeItems[i],
                        onEdit: () => _showEditDialog(
                          initialText: welcomeItems[i],
                          onConfirm: (newText) =>
                              setState(() => welcomeItems[i] = newText),
                        ),
                        onDelete: () => setState(() => welcomeItems.removeAt(i)),
                      ),
                    _buildAddBox(
                      label: '카테고리 추가',
                      count: categoryItems.length,
                      max: maxCategory,
                      onAdd: () {
                        if (categoryItems.length < maxCategory) {
                          setState(() => categoryItems
                              .add('카테고리 ${categoryItems.length + 1}'));
                        }
                      },
                    ),
                    for (int i = 0; i < categoryItems.length; i++)
                      _buildEditableBox(
                        text: categoryItems[i],
                        onEdit: () => _showEditDialog(
                          initialText: categoryItems[i],
                          onConfirm: (newText) =>
                              setState(() => categoryItems[i] = newText),
                        ),
                        onDelete: () => setState(() => categoryItems.removeAt(i)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }

  Widget customTopBar() {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFF1C1B1F), size: 24),
                ),
                const Spacer(),
                const Text(
                  "모디챗 설정",
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            Screen2(categoryItems: categoryItems),
                      ),
                    );
                  },
                  child: const Text(
                    "다음",
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddBox({
    required String label,
    required int count,
    required int max,
    required VoidCallback onAdd,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF000000)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$count/$max',
                    style: const TextStyle(fontSize: 12)),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableBox({
    required String text,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color(0xFF3D3D3D),
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 12,
                    icon: const Icon(Icons.more_vert, size: 20),
                    color: const Color(0xFFE9EFF0),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      else if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('수정하기')),
                      PopupMenuItem(value: 'delete', child: Text('삭제하기')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(color: Color(0xFFE7E7E7), thickness: 0.1, height: 0.1),
      ],
    );
  }
}
