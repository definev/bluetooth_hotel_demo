import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:smarthotel/in_room_demo.dart';
import 'package:smarthotel/slide_from_top_animated.dart';

enum _AniProps { width, height, color, position }

class CheckInDemo extends HookWidget {
  const CheckInDemo({Key? key}) : super(key: key);

  TimelineTween<_AniProps> _buildRoomBannerTween() => TimelineTween<_AniProps>()
    ..addScene(
      begin: const Duration(milliseconds: 0),
      duration: const Duration(microseconds: 800),
    )
        .animate(_AniProps.position, tween: Tween<double>(begin: -120, end: 0))
        .animate(_AniProps.width, tween: Tween<double>(begin: 0.3, end: 0.5))
        .animate(_AniProps.height, tween: Tween<double>(begin: 0.0, end: 150.0))
        .animate(_AniProps.color,
            tween: ColorTween(
                begin: Colors.yellow.shade50.withOpacity(0.1),
                end: Colors.yellow.shade50))
    ..addScene(
            begin: const Duration(milliseconds: 800),
            end: const Duration(milliseconds: 1000))
        .animate(_AniProps.width, tween: Tween<double>(begin: 0.5, end: 1));

  @override
  Widget build(BuildContext context) {
    final _roomBannerTween = useMemoized(() => _buildRoomBannerTween());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildRoomNumberHeader(_roomBannerTween, context),
            _buildNeededTextField(),
            SlideFromTopAnimated(
              delay: 1200,
              duration: 1200 + 300,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CheckBluetoothStateScreen()),
                    );
                  },
                  child: const Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Check in'),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeededTextField() {
    return PlayAnimation<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, child, value) {
          return Center(
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SlideFromTopAnimated(
                      duration: 300,
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text('Số giấy tờ'),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SlideFromTopAnimated(
                      delay: 300,
                      duration: 300 * 2,
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text('Họ và tên'),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SlideFromTopAnimated(
                      delay: 600,
                      duration: 600 + 300,
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text('Ngày hết hạn'),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: SlideFromTopAnimated(
                            delay: 900,
                            duration: 900 + 300,
                            child: TextField(
                              decoration: InputDecoration(
                                label: Text('Ngày sinh'),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SlideFromTopAnimated(
                          delay: 1200,
                          duration: 1200 + 300,
                          child: ToggleButtons(
                            children: [
                              const SizedBox(
                                height: 56,
                                width: 56,
                                child: Icon(Icons.male),
                              ),
                              const SizedBox(
                                height: 56,
                                width: 56,
                                child: Icon(Icons.female),
                              ),
                            ],
                            isSelected: [true, false],
                            onPressed: (index) {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildRoomNumberHeader(
      TimelineTween<_AniProps> _roomBannerTween, BuildContext context) {
    return SizedBox(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Icon(Icons.help_center),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Phòng',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1701',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}