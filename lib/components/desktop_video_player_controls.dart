import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stronz_video_player/components/controls/exit_button.dart';
import 'package:stronz_video_player/components/controls/full_screen_button.dart';
import 'package:stronz_video_player/components/controls/media_title.dart';
import 'package:stronz_video_player/components/controls/next_button.dart';
import 'package:stronz_video_player/components/controls/playpause_button.dart';
import 'package:stronz_video_player/components/controls/position_indicator.dart';
import 'package:stronz_video_player/components/controls/seek_bar.dart';
import 'package:stronz_video_player/components/controls/settings_button.dart';
import 'package:stronz_video_player/components/controls/stronz_control.dart';
import 'package:stronz_video_player/components/controls/volume_button.dart';
import 'package:stronz_video_player/components/video_player_controls.dart';
import 'package:stronz_video_player/utils/fullscreen.dart';

class DesktopVideoPlayerControls extends VideoPlayerControls {

    const DesktopVideoPlayerControls({
        super.key,
        super.additionalControlsBuilder
    });

    @override
    VideoPlayerControlsState<DesktopVideoPlayerControls> createState() => _DesktopVideoControlsState();
}

class _DesktopVideoControlsState extends VideoPlayerControlsState<DesktopVideoPlayerControls> with StronzControl {

    DateTime _lastTap = DateTime.now();
    bool _hoveringControls = false;
    double _savedVolume = 0.0;
    bool _seeking = false;

    @override
    Widget buildTopBar(BuildContext context) {
        return MouseRegion(
            onHover: (_) => this._onEnterControls(),
            onExit: (_) => this._onExitControls(),
            onEnter: (_) => this._onEnterControls(),
            child: Container(
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                    children: [
                        const ExitButton(),
                        const SizedBox(width: 8.0),
                        const MediaTitle(),
                        if(super.widget.additionalControlsBuilder != null) ...[
                            const SizedBox(width: 8.0),
                            ...super.widget.additionalControlsBuilder!(context)
                        ]
                    ],
                )
            )
        );
    }

    @override
    Widget buildPrimaryBar(BuildContext context) {
        return MouseRegion(
            cursor: super.visible ? SystemMouseCursors.basic : SystemMouseCursors.none,
            child: GestureDetector(
                onTapUp: (e) {
                    DateTime now = DateTime.now();
                    Duration  difference = now.difference(this._lastTap);
                    this._lastTap = now;
                    if (difference < const Duration(milliseconds: 400))
                        FullScreen.toggle();
                },
                onTap: super.controller(context).playOrPause,
                child: Container(
                    color: Colors.transparent,
                )
            )
        );
    }

    @override
    Widget buildBottomBar(BuildContext context) {
        return MouseRegion(
            onHover: (_) => this._onEnterControls(),
            onExit: (_) => this._onExitControls(),
            onEnter: (_) => this._onEnterControls(),
            child: Container(
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                    children: [
                        const PlayPauseButton(),
                        const NextButton(),
                        const VolumeButton(),
                        const PositionIndicator(),
                        const Spacer(),
                        SettingsButton(
                            onOpened: super.onMenuOpened,
                            onClosed: super.onMenuClosed,
                        ),
                        const FullScreenButton()
                    ]
                )
            )
        );
    }

    @override
    Widget buildSeekBar(BuildContext context) {
        return MouseRegion(
            onHover: (_) => this._onEnterControls(),
            onExit: (_) => this._onExitControls(),
            onEnter: (_) => this._onEnterControls(),
            child: Transform.translate(
                offset: const Offset(0.0, 16.0),
                child: SeekBar(
                    onSeekStart: () {
                        super.cancelTimer();
                        super.setState(() => this._seeking = true);
                    },
                    onSeekEnd: () {
                        super.restartTimer();
                        super.setState(() => this._seeking = false);
                    }
                ),
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        return CallbackShortcuts(
            bindings: {
                const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
                    super.controller(context).play(),
                const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
                    super.controller(context).pause(),
                const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
                    super.controller(context).playOrPause(),
                const SingleActivator(LogicalKeyboardKey.space): () =>
                    super.controller(context).playOrPause(),
                const SingleActivator(LogicalKeyboardKey.keyJ): () {
                    final rate = super.controller(context).position - const Duration(seconds: 10);
                    super.controller(context).seekTo(rate);
                },
                const SingleActivator(LogicalKeyboardKey.keyI): () {
                    final rate = super.controller(context).position + const Duration(seconds: 10);
                    super.controller(context).seekTo(rate);
                },
                const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                    final rate = super.controller(context).position - const Duration(seconds: 5);
                    super.controller(context).seekTo(rate);
                },
                const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                    final rate = super.controller(context).position + const Duration(seconds: 5);
                   super.controller(context).seekTo(rate);
                },
                const SingleActivator(LogicalKeyboardKey.arrowUp): () {
                    final volume = super.controller(context).volume + 5.0;
                    super.controller(context).setVolume(volume.clamp(0.0, 100.0));
                },
                const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                    final volume = super.controller(context).volume - 5.0;
                    super.controller(context).setVolume(volume.clamp(0.0, 100.0));
                },
                const SingleActivator(LogicalKeyboardKey.keyM): () {
                    if(super.controller(context).volume > 0.0) {
                        this._savedVolume = super.controller(context).volume;
                        super.controller(context).setVolume(0.0);
                    } else
                        super.controller(context).setVolume(this._savedVolume);
                },
                const SingleActivator(LogicalKeyboardKey.keyF): () => FullScreen.toggle(),
                const SingleActivator(LogicalKeyboardKey.escape): () => FullScreen.set(false),
            },
            child: Focus(
                autofocus: true,
                child: MouseRegion(
                    onHover: (_) => this._onHover(),
                    onEnter: (_) => this._onEnter(),
                    onExit: (_) => this._onExit(),
                    child: super.buildControls(context),
                )
            )
        );
    }

    void _onHover() {
        super.setState(() {
            super.mount = true;
            super.visible = true;
        });
        if(!this._hoveringControls)
            super.restartTimer();
    }

    void _onEnter() {
        super.setState(() {
            super.mount = true;
            super.visible = true;
        });
        super.restartTimer();
    }

    void _onExit() {
        if(super.menuOpened || this._seeking)
            return;
        super.setState(() {
            super.mount = false;
            super.visible = false;
        });
        super.cancelTimer();
    }

    void _onEnterControls() {
        super.setState(() {
            super.mount = true;
            super.visible = true;
            this._hoveringControls = true;
        });
        super.cancelTimer();
    }

    void _onExitControls() {
        this._hoveringControls = false;
    }
}