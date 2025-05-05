import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modir/mvvm/feed/viewmodels/FeedViewModel.dart';
import 'package:provider/provider.dart';


class WriteFeedScreen extends StatefulWidget {
  const WriteFeedScreen({super.key});

  @override
  State<WriteFeedScreen> createState() => _WriteFeedScreenState();
}

class _WriteFeedScreenState extends State<WriteFeedScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isContentEmpty = true;
  Color _completeButtonColor = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_textFieldListener);
    _contentController.addListener(_textFieldListener);
  }

  void _textFieldListener() {
    setState(() {
      _isContentEmpty = _contentController.text.trim().isEmpty;
      _completeButtonColor = (_titleController.text.trim().isNotEmpty &&
          _contentController.text.trim().isNotEmpty)
          ? Colors.black
          : const Color(0xFF888888);
    });
  }

  void _onCompletePressed(BuildContext context, TextEditingController _titleController, TextEditingController _contentController) async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력하세요')),
      );
      return;
    }

    try {
      final viewModel = Provider.of<FeedViewModel>(context, listen: false);
      await viewModel.postFeed(title, content, pics: null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 등록되었습니다')),
      );
      context.go('/community');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 등록 실패: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  File? _image; // 선택한 이미지를 저장
  Uint8List? _webImage; // 웹용


  // 이미지 선택 함수
  Future<void> _pickImage() async {
    try {
      print('Initializing ImagePicker for web');
      final picker = ImagePicker();
      print('Calling pickImage with source: gallery');
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      print('Picked file: ${pickedFile?.name}');

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        print('Image bytes length: ${bytes.length}');
        setState(() {
          _webImage = bytes;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 선택되지 않았습니다')),
        );
      }
    } catch (e) {
      print('Image picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 실패: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        "글쓰기",
        _completeButtonColor,
            () => _onCompletePressed(context, _titleController, _contentController), // 클로저로 인자 전달
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                Container(
                height: 248,
                padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 24),
                child: Stack(
                  children: [
                    Container(
                      width: 160,
                      height: 200,
                      decoration: ShapeDecoration(
                        color: _image == null ? Colors.redAccent : null, // 이미지가 있으면 색상 제거
                        image: _image != null
                            ? DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
                        )
                            : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: GestureDetector(
                        onTap: _pickImage, // 버튼 클릭 시 이미지 선택
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..scale(-1.0, 1.0),
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: _titleController,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: "제목을 입력해주세요",
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF888888),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFF888888), width: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _contentController,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: null,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            hintText: "내용을 입력해주세요",
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF888888),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                top: 16, left: 16, right: 16, bottom: 10),
                          ),
                        ),
                        if (_isContentEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              '본 게시판의 사용 목적은 패션을 주제로 한 커뮤니티입니다.\n'
                                  '사용 목적이 옳바르지 않은 글을 게시하거나 시도한다면 서비스 사용이\n'
                                  '영구 제한 될 수도 있습니다.\n\n'
                                  '아래에는 이 게시판에 해당되는 핵심 내용에 대한 요약사항이며, 게시물 작성전 커뮤니티\n'
                                  '이용규칙 전문을 반드시 확인하시길 바랍니다.\n\n'
                                  '게시판에서 미리보기로 확인 가능한 텍스트는 첫 줄에 해당되는 텍스트입니다.\n'
                                  '게시판에서 미리보기로 확인 가능한 이미지는 처음 올리는 이미지 한 장입니다.\n\n'
                                  '• 정치·사회 관련 행위 금지\n'
                                  '• 홍보 및 판매 관련 행위 금지\n'
                                  '• 불법촬영물 유통 금지\n'
                                  '• 타인의 권리를 침해하거나 불쾌감을 주는 행위\n'
                                  '• 범죄, 불법 행위 등 법령을 위반하는 행위\n'
                                  '• 욕설, 비하, 차별, 혐오, 자살, 폭력 관련 내용 금지\n'
                                  '• 음란물, 성적, 수치심 유발 금지\n'
                                  '• 스포일러, 공포, 속임, 놀람 유도 금지',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

PreferredSizeWidget customAppBar(
    BuildContext context,
    String title,
    Color completeButtonColor,
    VoidCallback onCompletePressed,
    ) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 뒤로가기
              GestureDetector(
                onTap: () => context.go('/community'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),

              // 가운데 타이틀
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),

              // 완료 버튼
              GestureDetector(
                onTap: onCompletePressed,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "완료",
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: completeButtonColor,
                    ),
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

// Widget bottomBar() {
//   return Container(
//     height: 56,
//     color: Colors.white,
//     child: Center(
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Container(
//           decoration: const BoxDecoration(
//             border: Border(
//               top: BorderSide(color: Color(0xFF888888), width: 0.1),
//             ),
//           ),
//           child: Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: GestureDetector(
//                   onTap: () => print("이미지"),
//                   child: Icon(
//                     Icons.broken_image_outlined,
//                     color: Colors.black,
//                     size: 24,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: GestureDetector(
//                   onTap: () => print("카메라"),
//                   child: Icon(
//                     Icons.add_a_photo_outlined,
//                     color: Colors.black,
//                     size: 24,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: GestureDetector(
//                   onTap: () => print("투표"),
//                   child: Icon(
//                     Icons.how_to_vote_outlined,
//                     color: Colors.black,
//                     size: 24,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// 여기서부터 카테고리 부분
class SelectableTagList extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onChanged;

  const SelectableTagList({
    super.key,
    required this.tags,
    required this.onChanged,
  });

  @override
  State<SelectableTagList> createState() => _SelectableTagListState();
}

class _SelectableTagListState extends State<SelectableTagList> {
  List<String> selectedTags = [];

  void toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        if (selectedTags.length < 3) {
          selectedTags.add(tag);
        }
      }
    });
    widget.onChanged(selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.tags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return GestureDetector(
          onTap: () => toggleTag(tag),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.black : Color(0xff888888),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
