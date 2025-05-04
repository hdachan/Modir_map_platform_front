import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/WithdrawalViewModel.dart';
import '../widget/mypage_appbar.dart';



class WithdrawalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WithdrawalViewModel>(context);

    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Column 자체도 왼쪽 정렬
              children: [
                CustomAppBar(title: '탈퇴하기', context: context),
                Container(
                  height: 130,
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 내부 Column도 왼쪽 정렬
                    children: [
                      Container(
                        height: 50,
                        child: Text(
                          '모디랑 서비스를 이용해주신 지난 날들을\n진심으로 감사하게 생각합니다.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.40,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 40,
                        child: Text(
                          '고객님이 느끼신 불편한 점들을 저희에게 알려주신다면\n더욱 도움이 되는 서비스를 제공할 수 있도록 하겠습니다.',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.40,
                            letterSpacing: -0.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: List.generate(viewModel.reasons.length, (index) {
                      bool isSelected = viewModel.selectedIndexes.contains(index);
                      bool isOther = index == viewModel.reasons.length - 1;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => viewModel.toggleReason(index),
                            child: Container(
                              height: 36,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: ShapeDecoration(
                                      color: isSelected ? Color(0xFF888888) : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.check,
                                        color: isSelected ? Colors.white :Colors.black ,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    width: 300,
                                    child: Text(
                                      viewModel.reasons[index],
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Color(0xFF888888),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.40,
                                        letterSpacing: -0.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isOther && isSelected)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: TextField(
                                controller: viewModel.otherReasonController,
                                style: TextStyle(color: Colors.black, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: "기타 사유를 입력해주세요",
                                  hintStyle: TextStyle(color: Color(0xFF888888)),
                                  filled: true,
                                  fillColor: Color(0xFFF6F6F6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
                Container(
                  width: double.infinity, // 전체 너비로 설정
                  padding: EdgeInsets.symmetric(horizontal: 16), // 양쪽에 16의 패딩 추가
                  child: ElevatedButton(
                    onPressed: () => viewModel.saveWithdrawalReason(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "탈퇴하기",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )


              ],
            ),


          ),
        ),
      ),
    );
  }
}
