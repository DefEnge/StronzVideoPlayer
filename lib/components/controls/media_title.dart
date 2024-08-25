import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/controls/stronz_control.dart';
import 'package:stronz_video_player/logic/stream_listener.dart';

class MediaTitle extends StatefulWidget with StronzControl {
    const MediaTitle({super.key});

    @override
    State<MediaTitle> createState() => _MediaTitleState();
}

class _MediaTitleState extends State<MediaTitle> with StreamListener, StronzControl{

    late String _title = super.controller(super.context).title;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        super.updateSubscriptions([
            super.controller(context).stream.title.listen(
                (event) => this.setState(() => this._title = event)
            )
        ]);
    }

    @override
    void setState(VoidCallback fn) {
        if(super.mounted)
            super.setState(fn);
    }

    @override
    Widget build(BuildContext context) {
        return Expanded(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                    this._title,
                    style: const TextStyle(
                        fontSize: 21.0
                    ),
                ),
            ),
        );
    }
}