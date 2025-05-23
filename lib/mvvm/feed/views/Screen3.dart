import 'package:flutter/material.dart';

class Screen3 extends StatefulWidget {
  final String itemName;

  const Screen3({Key? key, required this.itemName}) : super(key: key);

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  final TextEditingController _contentController = TextEditingController();
  Color buttonColor = const Color(0xFF888888); // 초기 버튼 색상

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {
      buttonColor = text.isEmpty ? const Color(0xFF888888) : const Color(0xFF000000);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        '큐레이션 리스트',
        buttonColor,
            () => debugPrint('완료 Pressed'),
        buttonText: '완료',
        controller: _contentController,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFE7E7E7), thickness: 5, height: 0.5),
                  _buildBlackBox('큐레이션 리스트'),
                  const Divider(color: Color(0xFFE7E7E7), thickness: 0.1, height: 0.1),
                  _buildGreyBox(widget.itemName),
                  const Divider(color: Color(0xFFE7E7E7), thickness: 0.1, height: 0.1),
                  _buildBlackBox('답변'),
                  const Divider(color: Color(0xFFE7E7E7), thickness: 0.1, height: 0.1),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      minLines: 10,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: _onTextChanged,
                      decoration: const InputDecoration(
                        hintText: '내용을 입력해주세요',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF888888),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), /// 여기가 글쓰는곳이랑 이미지 거리 벌어주는곳 16정도로하니 제눈엔 괜찮아서 이렇게 뒀습니다.
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    _buildImageBox('assets/doisy.png'),
                    const SizedBox(width: 8),
                    _buildImageBox('assets/doisy.png'),
                    const SizedBox(width: 8),
                    _buildImageBox('assets/doisy.png'),
                    const SizedBox(width: 8),
                    _buildImageBox('assets/doisy.png'),
                    const SizedBox(width: 8),
                    _buildImageBox('assets/doisy.png'),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            color: Color(0xFFE7E7E7),
            thickness: 1,
            height: 1,
            indent: 0,
            endIndent: 0,
          ),
        ],
      ),
      bottomNavigationBar: bottomBar(),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildGreyBox(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF000000),
      ),
    ),
  );

  Widget _buildBlackBox(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF000000),
      ),
    ),
  );

  Widget _buildImageBox(String path) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.asset(path, width: 160, height: 200, fit: BoxFit.cover),
  );
}

// ─────────── 재사용 AppBar ───────────

PreferredSizeWidget customAppBar(
    BuildContext context,
    String title,
    Color completeButtonColor,
    VoidCallback onCompletePressed, {
      String buttonText = '다음',
      required TextEditingController controller,
    }) =>
    PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            if (controller.text.trim().isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: const Color(0xFFF0F0F0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 텍스트 영역
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                            child: Column(
                              children: const [
                                Text(
                                  '아직 큐레이션의 내용을 입력하지 않았어요 큐레이션 작성을 취소하시겠어요?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 가로 디바이더
                          const Divider(
                            color: Color(0xFFE0E0E0),
                            thickness: 1,
                            height: 1,
                          ),

                          // 버튼 영역
                          SizedBox(
                            height: 44,
                            child: Row(
                              children: [
                                // '닫기' 버튼
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(),
                                      ),
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Center(
                                        child: Text(
                                          '닫기',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF3D3D3D),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // 수직 디바이더
                                Container(
                                  width: 1,
                                  height: double.infinity,
                                  color: Color(0xFFE0E0E0),
                                ),

                                // '확인' 버튼
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Center(
                                        child: Text(
                                          '확인',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF3D3D3D),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );


            } else {
              Navigator.pop(context);
            }
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1C1B1F),
              size: 24,
            ),
          ),
        ),
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: onCompletePressed,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: completeButtonColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

// ─────────── 재사용 BottomBar ───────────

Widget bottomBar() => Container(
  height: 56,
  color: const Color(0xFFFFFFFF),
  padding: const EdgeInsets.all(8),
  child: Column(
    children: [
      Expanded(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => print("이미지"),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF3D3D3D),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => print("카메라"),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: Color(0xFF3D3D3D),
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
