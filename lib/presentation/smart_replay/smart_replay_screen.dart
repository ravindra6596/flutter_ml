import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/smart_reply/smart_replay_bloc.dart';
import 'package:flutter_ai_ml/bloc/smart_reply/smart_replay_event.dart';
import 'package:flutter_ai_ml/bloc/smart_reply/smart_replay_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SmartReplayScreen extends StatefulWidget {
  const SmartReplayScreen({super.key});

  @override
  State<SmartReplayScreen> createState() => _SmartReplayScreenState();
}

class _SmartReplayScreenState extends State<SmartReplayScreen> {
  TextEditingController senderController = TextEditingController();
  TextEditingController receivedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: smartReplayText),
      body: BlocProvider(
        create: (context) => SmartReplayBloc(),
        child: BlocBuilder<SmartReplayBloc, SmartReplayState>(
          builder: (context, state) {
            final bloc = context.read<SmartReplayBloc>();
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.all(1.h),
                  width: double.infinity,
                  height: 7.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.h),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(1.h),
                            child: TextField(
                              controller: receivedController,
                              decoration: InputDecoration(
                                  fillColor: Colors.transparent,
                                  hintText: receivedText,
                                  filled: true,
                                  border: InputBorder.none),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          bloc.add(ReceivedMessageEvent(receivedController.text));
                          receivedController.clear();
                        },
                        style: IconButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.all(1.5.h),
                          backgroundColor: Colors.red,
                        ),
                        icon: const Icon(
                          Icons.send,
                          size: 25,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(child: SizedBox()),
                /*if (state is SmartReplayLoaded) ...[
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(2.h),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final align = message.isLocal ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                        final color = message.isLocal ? Colors.green[100] : Colors.grey[300];
                        final radius = BorderRadius.only(
                          topLeft: Radius.circular(1.h),
                          topRight: Radius.circular(1.h),
                          bottomLeft: Radius.circular(message.isLocal ? 1.h : 0),
                          bottomRight: Radius.circular(message.isLocal ? 0 : 1.h),
                        );

                        return Column(
                          crossAxisAlignment: align,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 0.5.h),
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: radius,
                              ),
                              child: CustomText(
                                message.text,
                                style: TextStyle(fontSize: 15.px),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (state.suggestions.isNotEmpty) ...[
                    SizedBox(
                      height: 5.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        itemCount: state.suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = state.suggestions[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 1.w),
                            child: OutlinedButton(
                              onPressed: () {
                                bloc.add(SendMessageEvent(suggestion));
                              },
                              child: Text(suggestion),
                            ),
                          );
                        },
                      ),
                    ),
                  ]
                ],*/
                 if(state is SmartReplayLoaded)...[
                  SizedBox(
                    height: 4.h,
                    child: ListView.builder(
                      padding: EdgeInsets.only(left: 2.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.suggestions.length,
                      itemBuilder: (contextList, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1.h),
                              ),
                            ),
                            onPressed: () {
                              bloc.add(SendMessageEvent(state.suggestions[index]));
                            },
                            child: CustomText(state.suggestions[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                Container(
                  margin: EdgeInsets.all(1.h),
                  width: double.infinity,
                  height: 7.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(1.h),
                            child: TextField(
                              controller: senderController,
                              decoration: InputDecoration(
                                fillColor: Colors.transparent,
                                hintText: senderText,
                                filled: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          bloc.add(SendMessageEvent(senderController.text));
                          senderController.clear();
                        },
                        style: IconButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.all(1.5.h),
                            backgroundColor: Colors.green),
                        icon: const Icon(
                          Icons.send,
                          size: 25,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
