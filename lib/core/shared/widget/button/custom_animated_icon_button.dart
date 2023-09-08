// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomAnimatedIconButton extends StatefulWidget {
  final bool? initialState;
  final void Function(bool state)? onTap;
  final IconData icondata;
  final double? size;
  final bool? isLike;

  const CustomAnimatedIconButton(
      {Key? key,
      this.initialState,
      this.onTap,
      required this.icondata,
      this.isLike = false,
      this.size})
      : super(key: key);

  @override
  _CustomAnimatedIconButtonState createState() =>
      _CustomAnimatedIconButtonState();
}

class _CustomAnimatedIconButtonState extends State<CustomAnimatedIconButton>
    with TickerProviderStateMixin {
  bool? _state;
  AnimationController? _animationController;
  Animation<Color?>? _coloranimation;
  Animation<double>? _sizeanimation;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState ?? false;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _coloranimation = ColorTween(begin: Colors.grey.shade400, end: Colors.red)
        .animate(_animationController!);
    _sizeanimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 25, end: 30),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 30, end: 25),
          weight: 50,
        ),
      ],
    ).animate(_animationController!);
    if (_state!) _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _state = !_state!;
          });
          _state!
              ? _animationController!.forward()
              : _animationController!.reverse();
          widget.onTap!(_state!);
        },
        child: AnimatedBuilder(
          animation: _coloranimation!,
          builder: (context, child) {
            return Icon(
              widget.icondata,
              color: (!widget.isLike!) ? Colors.black : Colors.red,
              size: widget.size ?? _sizeanimation!.value,
            );
          },
        ));
  }
}
