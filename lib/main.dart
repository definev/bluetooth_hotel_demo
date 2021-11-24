import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_animations/simple_animations.dart';

void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Smart Hotel Demo',
      // theme: ThemeData.dark(),
      home: CheckBluetoothStateScreen(),
    );
  }
}

class CheckBluetoothStateScreen extends StatelessWidget {
  const CheckBluetoothStateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BluetoothState>(
        future: FlutterBluetoothSerial.instance.state,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<BluetoothState>(
              stream: FlutterBluetoothSerial.instance.onStateChanged(),
              initialData: snapshot.data,
              builder: (c, snapshot) {
                final state = snapshot.data;
                Future(() {
                  ScaffoldMessenger.of(c).removeCurrentSnackBar();
                  ScaffoldMessenger.of(c).showSnackBar(
                      SnackBar(content: Text('Trạng thái: $state')));
                });
                if (state == BluetoothState.STATE_ON) {
                  return const HomePage();
                }
                return const Scaffold(
                  body: Center(
                      child: Text(
                          'Bluetooth đang không hoạt động, vui lòng bật bluetooth')),
                );
              });
        });
  }
}

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lockState = useState(true);
    final _connection = useState<BluetoothConnection?>(null);

    final _scanning = useCallback(() async {
      final device = await showModalBottomSheet(
        context: context,
        builder: (context) => const ScanDeviceScreen(),
      );
      if (device != null) {
        showDialog(
          context: context,
          builder: (context) => const Center(
              child: SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(),
          )),
        );
        BluetoothConnection.toAddress(device.address).then((connection) {
          _connection.value = connection;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kết nối thành công')));
          lockState.value = false;
        }).catchError((error) {
          _connection.value = null;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Kết nối thất bại')));
        });
      }
    }, []);

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
              child: Column(
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
                    IconButton(
                      onPressed: () => _connection.value = null,
                      icon: const Icon(Icons.wifi_off),
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
                GestureDetector(
                  onTap: () {
                    if (_connection.value == null) {
                      _scanning();
                      return;
                    }
                    if (lockState.value) {
                      _connection.value!.output.add(ascii.encode('open'));
                    } else {
                      _connection.value!.output.add(ascii.encode('lock'));
                    }
                    lockState.value = !lockState.value;
                  },
                  child: PulseAnimationIcon(
                    color: _connection.value == null
                        ? Colors.yellow.shade600
                        : lockState.value == false
                            ? Colors.green
                            : Colors.red,
                    icon: _connection.value == null
                        ? const Icon(Icons.wifi, size: 50, color: Colors.blue)
                        : lockState.value == false
                            ? const Icon(Icons.lock_open,
                                size: 50, color: Colors.white)
                            : const Icon(Icons.lock,
                                size: 50, color: Colors.white),
                    label: _connection.value == null
                        ? 'Kết nối'
                        : lockState.value == false
                            ? 'Đã mở'
                            : 'Khóa',
                    size: 250,
                  ),
                ),
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
              Timer timer = Timer(
                const Duration(milliseconds: 500),
                () => pulse.value = !pulse.value,
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

class ScanDeviceScreen extends StatelessWidget {
  const ScanDeviceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm thiết bị')),
      body: FutureBuilder<List<BluetoothDevice>>(
        future: FlutterBluetoothSerial.instance.getBondedDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final devices = snapshot.data!;
            return ListView.builder(
              itemBuilder: (context, index) {
                final BluetoothDevice device = devices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device.name ?? 'Không tên'),
                  subtitle: Text(device.address),
                  onTap: () => Navigator.of(context).pop(device),
                );
              },
              itemCount: devices.length,
            );
          }
          return const Center(child: Text('Lỗi không tìm thấy thiết bị'));
        },
      ),
    );
  }
}
