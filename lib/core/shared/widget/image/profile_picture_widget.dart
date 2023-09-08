import 'dart:developer' as logger;

import 'package:flutter/material.dart';
// import 'package:kreasi/core/config/global.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../loading/shimmer_widget.dart';
import '../../../config/extensions.dart';
import '../../../../features/home/presentation/provider/profile_picture_provider.dart';

enum ProfileType { rectangle, rounded, circle, leaderboard }

enum Gender { male, female }

/// [ProfilePictureWidget] Custom Widget untuk menampilkan Photo Profile.
/// Avatar Docs: https://www.dicebear.com/styles/bottts
/// Default value dari url adalah
/// EX:
/// https://api.dicebear.com/5.x/bottts/svg?seed=Felix&mouthProbability=100&size=100
class ProfilePictureWidget extends StatefulWidget {
  final String name;
  // final String userType;
  final String noRegistrasi;
  final bool? isUserLogin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;
  final ProfileType profileType;
  final String? photoUrl;

  const ProfilePictureWidget({
    Key? key,
    required this.name,
    this.width,
    this.height,
    this.borderRadius,
    required this.profileType,
    this.alignment = Alignment.topCenter,
    this.padding,
    // required this.userType,
    required this.noRegistrasi,
    this.isUserLogin,
    this.photoUrl,
  }) : super(key: key);

  const ProfilePictureWidget.rectangle({
    Key? key,
    required this.name,
    // required this.userType,
    required this.noRegistrasi,
    this.isUserLogin,
    this.width,
    this.height,
    this.borderRadius,
    this.profileType = ProfileType.rectangle,
    this.alignment = Alignment.topCenter,
    this.padding,
    this.photoUrl,
  }) : super(key: key);

  const ProfilePictureWidget.rounded({
    Key? key,
    required this.name,
    required this.borderRadius,
    // required this.userType,
    required this.noRegistrasi,
    this.isUserLogin,
    this.width,
    this.height,
    this.profileType = ProfileType.rounded,
    this.alignment = Alignment.topCenter,
    this.padding,
    this.photoUrl,
  }) : super(key: key);

  const ProfilePictureWidget.circle({
    Key? key,
    required this.name,
    // required this.userType,
    required this.noRegistrasi,
    this.isUserLogin,
    this.width,
    this.height,
    this.borderRadius,
    this.profileType = ProfileType.circle,
    this.alignment = Alignment.topCenter,
    this.padding,
    this.photoUrl,
  }) : super(key: key);

  const ProfilePictureWidget.leaderboard({
    Key? key,
    required this.name,
    // required this.userType,
    required this.noRegistrasi,
    this.isUserLogin,
    this.width,
    this.height,
    this.borderRadius,
    this.profileType = ProfileType.leaderboard,
    this.alignment = Alignment.topCenter,
    this.padding,
    this.photoUrl,
  }) : super(key: key);

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  late final Future<String?> _photoUrl =
      context.read<ProfilePictureProvider>().getProfilePicture(
            namaLengkap: widget.name,
            noRegistrasi: widget.noRegistrasi,
            isLogin: (widget.name != 'GOmin') || (widget.isUserLogin ?? true),
          );

  double getRadius(BuildContext context) {
    if (widget.width != null && widget.height != null) {
      return ((widget.width! > widget.height!)
              ? widget.width!
              : widget.height!) /
          2;
    }
    if (widget.width != null && widget.height == null) {
      return widget.width! / 2;
    }
    if (widget.width == null && widget.height != null) {
      return widget.height! / 2;
    }
    return context.dp(30);
  }

  @override
  Widget build(BuildContext context) {
    // ?rnd=${Random().nextInt(999999).toString()}
    String? photoUrl =
        (widget.photoUrl != null && (widget.photoUrl?.isNotEmpty ?? false))
            ? widget.photoUrl!
            : null;

    if (widget.name == '......') {
      final defaultImage = Image.asset(
        'assets/img/default_avatar.webp',
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        fit: BoxFit.cover,
      );

      if (widget.profileType == ProfileType.rounded) {
        return ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: defaultImage,
        );
      }
      return defaultImage;
    }

    if (widget.noRegistrasi == '-' || widget.noRegistrasi.isEmpty) {
      return _getChild(context, widget.noRegistrasi, null, widget.profileType);
    }
    return (photoUrl != null)
        ? _getChild(context, widget.noRegistrasi, photoUrl, widget.profileType)
        : FutureBuilder<String?>(
            future: _photoUrl,
            builder: (_, snapshot) =>
                (snapshot.connectionState == ConnectionState.waiting &&
                        widget.profileType == ProfileType.circle)
                    ? ShimmerWidget.circle(
                        width: widget.width ?? double.infinity,
                        height: widget.height ?? double.infinity,
                      )
                    : (snapshot.connectionState == ConnectionState.waiting)
                        ? ShimmerWidget.rounded(
                            width: widget.width ?? double.infinity,
                            height: widget.height ?? double.infinity,
                            borderRadius: widget.borderRadius,
                          )
                        : _getChild(context, widget.noRegistrasi, snapshot.data,
                            widget.profileType),
          );
  }

  Widget _getChild(
    BuildContext context,
    String noRegistrasi,
    String? photoUrl,
    ProfileType type,
  ) {
    bool isExist = (photoUrl != null) ||
        context.read<ProfilePictureProvider>().isPhotoProfileExist(
              noRegistrasi: noRegistrasi,
            );
    String extentionUrl = (widget.name == 'GOmin') ? '&baseColor=DB1931' : '';
    String diceBearUrl = 'https://api.dicebear.com/5.x/bottts/svg?'
        'seed=${widget.name}'
        '&mouthProbability=100'
        '&sidesProbability=100'
        '&eyes=bulging,eva,frame1,frame2,glow,happy,robocop,round,roundFrame01,roundFrame02,sensor,shade01'
        '&size=100$extentionUrl';

    final diceBearImage =
        SvgPicture.network(diceBearUrl, semanticsLabel: 'user profile picture');

    final errorWidget = Container(
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      padding: widget.padding ??
          EdgeInsets.only(
              top: context.dp(20), left: context.dp(4), right: context.dp(4)),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/img/default_avatar.webp'),
            fit: BoxFit.cover),
      ),
      child: SvgPicture.network(
        diceBearUrl,
        width: widget.width,
        fit: BoxFit.fitWidth,
      ),
    );
    final CachedNetworkImage? imageRectangle = (!isExist)
        ? null
        : CachedNetworkImage(
            imageUrl: photoUrl!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            alignment: widget.alignment,
            placeholder: (_, url) {
              // if (kDebugMode) logger.log('Placeholder Photo Profile >> $url');
              return Shimmer.fromColors(
                baseColor: context.onSurface.withOpacity(0.4),
                highlightColor: context.onSurface.withOpacity(0.2),
                child: Image.asset('assets/img/default_avatar.webp',
                    fit: BoxFit.cover),
              );
            },
            errorWidget: (_, url, error) {
              if (kDebugMode) {
                logger.log('PROFILE PICTURE WIDGET URL: $url');
                logger.log('PROFILE PICTURE WIDGET ERROR: $error');
              }
              return errorWidget;
            },
          );

    switch (widget.profileType) {
      case ProfileType.rounded:
        return ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: (!isExist)
              ? errorWidget
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    image: const DecorationImage(
                        image: AssetImage('assets/img/default_avatar.webp'),
                        fit: BoxFit.cover),
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, 2),
                    child: imageRectangle,
                  ),
                ),
        );
      case ProfileType.circle:
        return CircleAvatar(
          radius: getRadius(context),
          backgroundColor: Colors.white70,
          // backgroundImage: const AssetImage('assets/img/default_pp.webp'),
          child: (!isExist)
              ? diceBearImage
              : ClipRRect(
                  borderRadius: BorderRadius.circular(3000),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl!,
                    placeholder: (context, url) => const CircleAvatar(
                        radius: double.infinity,
                        backgroundColor: Colors.black12),
                    errorWidget: (context, url, error) => Image.asset(
                        'assets/img/default_pp.webp',
                        fit: BoxFit.cover),
                  ),
                ),
        );
      case ProfileType.leaderboard:
        return CircleAvatar(
          radius: getRadius(context),
          backgroundColor: Colors.white54,
          child: (!isExist)
              ? diceBearImage
              : ClipRRect(
                  borderRadius: BorderRadius.circular(3000),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl!,
                    placeholder: (context, url) => const CircleAvatar(
                        radius: double.infinity,
                        backgroundColor: Colors.black12),
                    errorWidget: (context, url, error) => Image.asset(
                        'assets/img/default_pp.webp',
                        fit: BoxFit.cover),
                  ),
                ),
        );
      default:
        return (!isExist) ? errorWidget : imageRectangle!;
    }
  }
}
