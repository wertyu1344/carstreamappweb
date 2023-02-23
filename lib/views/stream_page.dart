//
//  quick_start_page.dart
//  zego-express-example-topics-flutter
//
//  Created by Patrick Fu on 2020/12/04.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_looknowstream_web/model.dart';
import 'package:get/get.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../keycenter.dart';
import '../utils/token_helper.dart';
import '../utils/user_id_helper.dart';
import '../utils/zego_config.dart';
import '../utils/zego_log_view.dart';
import 'car_list_page.dart';

class QuickStartPage extends StatefulWidget {
  @override
  _QuickStartPageState createState() => _QuickStartPageState();
}

class _QuickStartPageState extends State<QuickStartPage> {
  final String _roomID = '34bb34';
  final String _roomID2 = '0002';

  late int _previewViewID;
  late int _playViewID;
  List plateList = [];
  Widget? _previewViewWidget;
  List<CarModel?> carList = [];
  Widget? _playViewWidget;
  Widget? _playViewWidget2;
  Widget? _playViewWidget3;
  Widget? _playViewWidget4;
  Widget? _playViewWidget5;
  Widget? _playViewWidget6;
  Widget? _playViewWidget7;
  Widget? _playViewWidget8;

  bool _isEngineActive = false;
  ZegoRoomState _roomState = ZegoRoomState.Disconnected;
  ZegoPublisherState _publisherState = ZegoPublisherState.NoPublish;
  ZegoPlayerState _playerState = ZegoPlayerState.NoPlay;

  final TextEditingController _publishingStreamIDController =
      TextEditingController();
  TextEditingController _playingStreamIDController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _previewViewID = -1;
    _playViewID = -1;
    _publishingStreamIDController.text = '0001';
    _playingStreamIDController.text = '0001';
    ZegoExpressEngine.destroyEngine();

    ZegoExpressEngine.getVersion()
        .then((value) => ZegoLog().addLog('🌞 SDK Version: $value'));
    setZegoEventCallback();
    getVehicles();
  }

  @override
  void dispose() {
    clearPreviewView();
    clearPlayView();

    clearZegoEventCallback();
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    ZegoExpressEngine.destroyEngine();

    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');

    super.dispose();
  }

  // MARK: - Step 1: CreateEngine

  createEngine() {
    ZegoEngineProfile profile = ZegoEngineProfile(
        KeyCenter.instance.appID, ZegoConfig.instance.scenario,
        enablePlatformView: ZegoConfig.instance.enablePlatformView,
        appSign: kIsWeb ? null : KeyCenter.instance.appSign);
    ZegoExpressEngine.createEngineWithProfile(profile);

    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, userList) {
      userList.forEach((e) {
        var userID = e.userID;
        var userName = e.userName;
        ZegoLog().addLog(
            '🚩 🚪 Room user update, roomID: $roomID, updateType: $updateType userID: $userID userName: $userName');
      });
    };

    ZegoExpressEngine.onPlayerVideoSizeChanged = (streamID, width, height) {
      ZegoLog().addLog(
          'onPlayerVideoSizeChanged streamID: $streamID size:${width}x${height}');
    };
    ZegoExpressEngine.onRoomTokenWillExpire = (roomid, expiretime) async {
      var token = await TokenHelper.instance.getToken(roomid);
      ZegoExpressEngine.instance.renewToken(roomid, token);
      ZegoLog().addLog(
          '🚩 🚪 Room Token Will Expire, roomID: $roomid, expiretime: $expiretime');
    };
    // Notify View that engine state changed
    setState(() => _isEngineActive = true);

    ZegoLog().addLog('🚀 Create ZegoExpressEngine');
  }

  // MARK: - Step 2: LoginRoom

  loginRoom(String roomID) async {
    print("şu odaya girecem $roomID");
    // Instantiate a ZegoUser object
    ZegoUser user =
        ZegoUser(UserIdHelper.instance.userID, UserIdHelper.instance.userName);

    ZegoLog().addLog('🚪 Start login room, roomID: $roomID');
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    config.isUserStatusNotify = true;
    if (kIsWeb) {
      print("token alacam");
      config.token = await TokenHelper.instance.getToken(roomID);
    }
    // Login Room
    ZegoExpressEngine.instance.loginRoom(roomID, user, config: config);
  }

  loginRoom2() async {
    // Instantiate a ZegoUser object
    ZegoUser user = ZegoUser("flutter_user", "flutter_user");

    ZegoLog().addLog('🚪 Start login room, roomID: $_roomID');
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    config.isUserStatusNotify = true;
    if (kIsWeb) {
      config.token = await TokenHelper.instance.getToken(_roomID);
    }
    // Login Room
    ZegoExpressEngine.instance.loginRoom(_roomID, user, config: config);
  }

  void logoutRoom() {
    // Logout room will automatically stop publishing/playing stream.
    //
    // But directly logout room without destroying the [PlatformView]
    // or [TextureRenderer] may cause a memory leak.
    ZegoExpressEngine.instance.logoutRoom("admin");
    ZegoLog().addLog('🚪 logout room, roomID: admin');

    clearPreviewView();
    clearPlayView();
  }

  // MARK: - Step 3: StartPublishingStream

  startPublishingStream(String streamID) async {
    void _startPreview(int viewID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPreview(canvas: canvas);
      ZegoLog().addLog('🔌 Start preview, viewID: $viewID');
    }

    void _startPublishingStream(String streamID) {
      ZegoExpressEngine.instance.startPublishingStream(streamID);
      Future.delayed(const Duration(seconds: 1), () {
        ZegoExpressEngine.instance.setStreamExtraInfo('ceshi');
      });
    }

    if (_previewViewID == -1) {
      _previewViewWidget =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _previewViewID = viewID;
        _startPreview(viewID);
        _startPublishingStream(streamID);
      }, key: ValueKey(DateTime.now()));

      setState(() {});
    } else {
      _startPreview(_previewViewID);
      _startPublishingStream(streamID);
    }
  }

  void stopPublishingStream() {
    ZegoExpressEngine.instance.stopPublishingStream();
    ZegoExpressEngine.instance.stopPreview();
  }

  // MARK: - Step 4: StartPlayingStream

  startPlayingStream(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  startPlayingStream2(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget2 =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  startPlayingStream3(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget3 =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  startPlayingStream4(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget4 =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  startPlayingStream5(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget5 =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  startPlayingStream6(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget6 =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  startPlayingStream7(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget7 =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  startPlayingStream8(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget8 =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  void stopPlayingStream(String streamID) {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
  }

  // MARK: - Exit

  void destroyEngine() async {
    clearPreviewView();
    clearPlayView();
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    ZegoExpressEngine.destroyEngine();
    logoutRoom();
    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');

    // Notify View that engine state changed
    setState(() {
      _isEngineActive = false;
      _roomState = ZegoRoomState.Disconnected;
      _publisherState = ZegoPublisherState.NoPublish;
      _playerState = ZegoPlayerState.NoPlay;
    });
  }

  // MARK: - Zego Event

  void setZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 🚪 Room state update, state: $state, errorCode: $errorCode, roomID: $roomID');
      setState(() => _roomState = state);
    };

    ZegoExpressEngine.onPublisherStateUpdate = (String streamID,
        ZegoPublisherState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 📤 Publisher state update, state: $state, errorCode: $errorCode, streamID: $streamID');
      setState(() => _publisherState = state);
    };

    ZegoExpressEngine.onPlayerStateUpdate = (String streamID,
        ZegoPlayerState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 📥 Player state update, state: $state, errorCode: $errorCode, streamID: $streamID');
      setState(() => _playerState = state);
    };
  }

  void clearZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
  }

  void clearPreviewView() {
    // Developers should destroy the [CanvasView] after
    // [stopPublishingStream] or [stopPreview] to release resource and avoid memory leaks
    if (_previewViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_previewViewID);
      _previewViewID = -1;
    }
  }

  void clearPlayView() {
    // Developers should destroy the [CanvasView]
    // after [stopPlayingStream] to release resource and avoid memory leaks
    if (_playViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID);
      _playViewID = -1;
    }
  }

  // MARK: Widget
  int pageIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () async {
                    if (pageIndex != 1) {
                      destroyEngine();
                      pageIndex--;
                      await updatePlateList(pageIndex);
                    }

                    setState(() {});
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
              Text(pageIndex.toString()),
              IconButton(
                  onPressed: () async {
                    destroyEngine();

                    pageIndex++;
                    await updatePlateList(pageIndex);

                    setState(() {});
                  },
                  icon: const Icon(Icons.arrow_forward_ios))
            ],
          ),
          actions: [
            IconButton(
                onPressed: () => Get.to(() => CarListPage()),
                icon: const Icon(Icons.list))
          ]),
      body: SafeArea(
          child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: mainContent(),
      )),
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
        child: Column(children: [
      SizedBox(
        child: const ZegoLogView(),
        height: MediaQuery.of(context).size.height * 0.1,
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(children: [
          viewsWidget(),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton.filled(
                child: const Text(
                  'Clean',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: destroyEngine,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              ),
              const SizedBox(width: 20),
              CupertinoButton.filled(
                onPressed: () async {
                  createEngine();
                  // for (var i in plateList) {
                  //await loginRoom(i ?? "");
                  //}
                  await loginRoom("admin");
                },
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                child: const Text(
                  'Connect to Devices',
                  style: TextStyle(fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 20),
              CupertinoButton.filled(
                onPressed: () async {
                  print("başlıyor ${plateList.length}");
                  if (plateList.isNotEmpty) {
                    await startPlayingStream(plateList[0]);
                  }
                  if (plateList.length >= 2) {
                    await startPlayingStream2(plateList[1]);
                  }
                  if (plateList.length >= 3) {
                    await startPlayingStream3(plateList[2]);
                  }
                  if (plateList.length >= 4) {
                    await startPlayingStream4(plateList[3]);
                  }
                  if (plateList.length >= 5) {
                    await startPlayingStream5(plateList[4]);
                  }
                  if (plateList.length >= 6) {
                    await startPlayingStream6(plateList[5]);
                  }
                  if (plateList.length >= 7) {
                    await startPlayingStream7(plateList[6]);
                  }
                  if (plateList.length >= 8) {
                    print("stream 8 başlayacak");
                    await startPlayingStream8(plateList[7]);
                  }
                },
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                child: const Text(
                  'Start Broadcast',
                  style: TextStyle(fontSize: 14.0),
                ),
              ),
            ],
          ),
        ]),
      ),
    ]));
  }

  Future<bool> getVehicles() async {
    await FirebaseFirestore.instance
        .collection('cars')
        .where("groupNumber", isEqualTo: 1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        plateList.add(doc["carPlate"]);
      });
    });
    print("şu an platelist $plateList");
    setState(() {});
    return true;
  }

  Widget viewsWidget() {
    return SizedBox(
      height: 1000,
      child: Center(
        child: GridView(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4),
          children: [
            plateList.isNotEmpty
                ? carTile(_playViewWidget, plateList[0])
                : const SizedBox(),
            plateList.length >= 2
                ? carTile(_playViewWidget2, plateList[1])
                : const SizedBox(),
            plateList.length >= 3
                ? carTile(_playViewWidget3, plateList[2])
                : const SizedBox(),
            plateList.length >= 4
                ? carTile(_playViewWidget4, plateList[3])
                : const SizedBox(),
            plateList.length >= 5
                ? carTile(_playViewWidget5, plateList[4])
                : const SizedBox(),
            plateList.length >= 6
                ? carTile(_playViewWidget6, plateList[5])
                : const SizedBox(),
            plateList.length >= 7
                ? carTile(_playViewWidget7, plateList[6])
                : const SizedBox(),
            /*  plateList.length == 8
                ? carTile(_playViewWidget8, plateList[7])
                : const SizedBox(),
            plateList.length == 8
                ? carTile(_playViewWidget7, plateList[6])
                : const SizedBox(),*/
          ],
        ),
      ),
    );
  }

  Widget carTile(Widget? widget, String? plate) {
    return plate == null
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 4,
                  height: MediaQuery.of(context).size.height / 3,
                  color: Colors.grey,
                  child: widget ?? const SizedBox(),
                ),
                const SizedBox(height: 20),
                Text(plate ?? ""),
              ],
            ),
          );
  }

  Widget stepOneCreateEngineWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step1:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(children: [
          Column(
            children: [
              Text('AppID: ${KeyCenter.instance.appID}',
                  style: const TextStyle(fontSize: 10)),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.width / 2.5,
            child: CupertinoButton.filled(
              child: Text(
                _isEngineActive ? '✅ CreateEngine' : 'CreateEngine',
                style: const TextStyle(fontSize: 14.0),
              ),
              onPressed: createEngine,
              padding: const EdgeInsets.all(10.0),
            ),
          )
        ]),
        const Divider(),
      ],
    );
  }

  Widget stepTwoLoginRoomWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Step2:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Row(children: [
        Column(
          children: [
            Text('RoomID: $_roomID', style: const TextStyle(fontSize: 10)),
            Text('UserID: ${UserIdHelper.instance.userID}',
                style: const TextStyle(fontSize: 10)),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        const Spacer(),
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: CupertinoButton.filled(
            child: Text(
              _roomState == ZegoRoomState.Connected
                  ? '✅ LoginRoom'
                  : 'LoginRoom',
              style: const TextStyle(fontSize: 14.0),
            ),
            onPressed: () {
              if (_roomState == ZegoRoomState.Disconnected) {
                print("login olacağım");
                //loginRoom();
                loginRoom("34bb34");
              } else {
                logoutRoom();
              }
            },
            padding: const EdgeInsets.all(10.0),
          ),
        )
      ]),
      const Divider(),
    ]);
  }

  Widget stepFourStartPlayingStreamWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Step4:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: TextField(
            enabled: _playerState == ZegoPlayerState.NoPlay,
            controller: _playingStreamIDController,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                isDense: true,
                labelText: 'Play StreamID:',
                labelStyle: TextStyle(color: Colors.black54, fontSize: 14.0),
                hintText: 'Please enter streamID',
                hintStyle: TextStyle(color: Colors.black26, fontSize: 10.0),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0e88eb)))),
          ),
        ),
        const Spacer(),
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: CupertinoButton.filled(
            onPressed: _playerState == ZegoPlayerState.NoPlay
                ? () {
                    print("STREAM BAŞLIYOR");
                    // startPlayingStream(_playingStreamIDController.text.trim());
                    // startPlayingStream2("0002");
                    setState(() {});
                  }
                : () {
                    for (var i in plateList) {
                      stopPlayingStream(i);
                    }
                    ;
                  },
            padding: const EdgeInsets.all(10.0),
            child: Text(
              _playerState != ZegoPlayerState.NoPlay
                  ? (_playerState == ZegoPlayerState.Playing
                      ? '✅ StopPlaying'
                      : '❌ StopPlaying')
                  : 'StartPlaying',
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
        )
      ]),
      const Divider(),
    ]);
  }

  updatePlateList(int pageNumber) async {
    plateList.clear();
    await FirebaseFirestore.instance
        .collection('cars')
        .where("groupNumber", isEqualTo: pageNumber)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        plateList.add(doc["carPlate"]);
      });
    });
  }
}
