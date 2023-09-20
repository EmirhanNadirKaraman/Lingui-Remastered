import 'package:flutter/material.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:provider/provider.dart';

class BaseView<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext context) createModel;
  final Widget Function(BuildContext context, T model, Size size,
      EdgeInsets padding, Localized language) builder;
  final bool static;

  const BaseView({
    Key? key,
    required this.createModel,
    required this.builder,
    this.static = false,
  }) : super(key: key);

  @override
  State<BaseView<T>> createState() => _BaseView<T>();
}

class _BaseView<T extends ChangeNotifier> extends State<BaseView<T>>
    with AutomaticKeepAliveClientMixin {
  late final T _model;
  late EdgeInsets _devicePadding;
  late Size _deviceSize;
  late Localized _language;
  bool _initted = false;

  @override
  void didChangeDependencies() {
    if (!_initted) {
      if (widget.static) {
        _model = widget.createModel(context);
      }
      _language = Localized.of(context);
      _devicePadding = MediaQuery.of(context).padding;
      _deviceSize = MediaQuery.of(context).size;
      _initted = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: !widget.static
          ? ChangeNotifierProvider(
              create: (context) => widget.createModel(context),
              child: Consumer<T>(
                builder: (context, model, _) => widget.builder(
                    context, model, _deviceSize, _devicePadding, _language),
              ),
            )
          : widget.builder(
              context, _model, _deviceSize, _devicePadding, _language),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
