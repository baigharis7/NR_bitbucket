import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import '../../infrastructure/utils/dimens.dart';

class DataBottomSheetWidget extends StatefulWidget {
  final Widget? icon;
  final String title;
  final String? description;
  final String? successButtonText;
  final Function? successButtonClick;
  final String? cancelButtonText;
  final Function? cancelButtonClick;

  const DataBottomSheetWidget({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.successButtonText,
    this.successButtonClick,
    this.cancelButtonText,
    this.cancelButtonClick,
  });

  @override
  State<DataBottomSheetWidget> createState() => _DataBottomSheetWidgetState();
}

class _DataBottomSheetWidgetState extends State<DataBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
   return Container(
     margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXXLarge, vertical: Dimens.marginXLarge),
     child: Column(children: [
       if (widget.icon != null) widget.icon!,
       const SizedBox(height: Dimens.heightXSmall,),
       Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: Dimens.fontSizeXLarge)),
       const SizedBox(height: Dimens.heightXSmall,),
       if (widget.description.isNotEmptyOrNull()) Text(widget.description!, style: TextStyle(color: Colors.grey.shade700,), textAlign: TextAlign.center),
       if (widget.successButtonClick != null) RoundedCustomButton(buttonText: widget.successButtonText, onPressed: () => widget.successButtonClick?.call()),
       if (widget.cancelButtonClick != null) InkWell(onTap: () => widget.cancelButtonClick?.call(), child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontWeight: FontWeight.w700),)),
     ],),
   );
  }
}