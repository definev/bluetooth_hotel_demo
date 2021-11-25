import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:smarthotel/bluetooth_module.dart';

class CheckBluetoothStateScreen extends StatefulWidget {
  const CheckBluetoothStateScreen({Key? key}) : super(key: key);

  @override
  State<CheckBluetoothStateScreen> createState() =>
      _CheckBluetoothStateScreenState();
}

class _CheckBluetoothStateScreenState extends State<CheckBluetoothStateScreen> {
  @override
  void initState() {
    super.initState();
    [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: BluetoothModule.instance.state,
        initialData: BluetoothState.on,
        builder: (c, snapshot) {
          final state = snapshot.data;

          if (state == BluetoothState.on) {
            return const FindDeviceScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        });
  }
}

class FindDeviceScreen extends StatefulWidget {
  const FindDeviceScreen({Key? key}) : super(key: key);

  @override
  State<FindDeviceScreen> createState() => _FindDeviceScreenState();
}

class _FindDeviceScreenState extends State<FindDeviceScreen> {
  List<BluetoothDevice> _bluetoothDevice = [];

  FlutterBlue get flutterBlue => FlutterBlue.instance;

  @override
  void initState() {
    super.initState();
    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!_bluetoothDevice.contains(device)) {
      setState(() {
        _bluetoothDevice.add(device);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm thiết bị')),
      body: ListView.builder(
        itemCount: _bluetoothDevice.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_bluetoothDevice[index].name),
            subtitle: Text(_bluetoothDevice[index].id.toString()),
            onTap: () {
              final device = _bluetoothDevice[index];
              List<BluetoothService> services = [];

              setState(() async {
                flutterBlue.stopScan();
                try {
                  await device.connect();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                } finally {
                  services = await device.discoverServices();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        device: device,
                        services: services,
                      ),
                    ),
                  );
                }
              });
            },
          );
        },
      ),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({
    Key? key,
    required this.device,
    required this.services,
  }) : super(key: key);

  final BluetoothDevice device;
  final List<BluetoothService> services;

  @override
  Widget build(BuildContext context) {
    final lockState = useState(true);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 83 + MediaQuery.of(context).padding.top,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(12.0),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                      Text(
                        'Mr. Huy Nguyen',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 83,
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phòng',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          '1710',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(builder: (context) {
                  return GestureDetector(
                    onTap: () async {
                      lockState.value = !lockState.value;
                      if (lockState.value) {
                        for (final service in services) {
                          for (final chr in service.characteristics) {
                            if (chr.properties.write) {
                              chr.write(utf8.encode('lock'));
                            }
                          }
                        }
                      } else {
                        for (final service in services) {
                          for (final chr in service.characteristics) {
                            if (chr.properties.write) {
                              chr.write(utf8.encode('open'));
                            }
                          }
                        }
                      }
                    },
                    child: PulseAnimationIcon(
                      color:
                          lockState.value == false ? Colors.green : Colors.red,
                      icon: lockState.value == false
                          ? const Icon(Icons.lock_open,
                              size: 50, color: Colors.white)
                          : const Icon(Icons.lock,
                              size: 50, color: Colors.white),
                      label: lockState.value == false ? 'Đã mở' : 'Khóa',
                      size: 250,
                    ),
                  );
                }),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Nhấn để mở khóa',
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PulseAnimationIcon extends StatelessWidget {
  final Color color;
  final Icon icon;
  final String label;
  final double size;

  const PulseAnimationIcon({
    Key? key,
    required this.color,
    required this.icon,
    required this.label,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          HookBuilder(
            builder: (context) {
              final pulse = useState(false);
              Timer timer = Timer(
                const Duration(milliseconds: 500),
                () => pulse.value = !pulse.value,
              );
              useEffect(() => () => timer.cancel(), []);

              return MirrorAnimation<double>(
                builder: (context, child, value) {
                  return SizedBox(
                    height: size * 0.8 + size * 0.2 * value,
                    width: size * 0.8 + size * 0.2 * value,
                    child: child,
                  );
                },
                child: TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: ColorTween(
                      begin: color.withOpacity(0.2),
                      end: color.withOpacity(0.2)),
                  builder: (context, color, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                tween: Tween<double>(begin: 0, end: 1),
              );
            },
          ),
          HookBuilder(
            builder: (context) {
              final pulse = useState(false);
              final isMouted = useIsMounted();
              Timer timer = Timer(
                const Duration(milliseconds: 500),
                () {
                  if (isMouted()) pulse.value = !pulse.value;
                },
              );
              useEffect(() => () => timer.cancel(), []);

              return MirrorAnimation<double>(
                builder: (context, child, value) {
                  return SizedBox(
                    height: size * 0.7 + size * 0.1 * value,
                    width: size * 0.7 + size * 0.1 * value,
                    child: child,
                  );
                },
                child: TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: ColorTween(
                      begin: color.withOpacity(0.2),
                      end: color.withOpacity(0.2)),
                  builder: (context, color, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                tween: Tween<double>(begin: 0, end: 1),
              );
            },
          ),
          AnimatedContainer(
            height: size * 0.6,
            width: size * 0.6,
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(fontSize: 16, color: icon.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
