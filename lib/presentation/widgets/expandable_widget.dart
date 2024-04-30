import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../domain/models/dashboard/nutrients_model.dart';
import '../../infrastructure/utils/constants.dart';
import '../../infrastructure/utils/num_constants.dart';
import 'nutrients_dashboard_widget.dart';

class ExpandableWidget extends StatefulWidget {
  final String title;
  final List<NutrientsModel> nutrientsList;
  final Function? titleClick;
  const ExpandableWidget({Key? key, required this.title, required this.nutrientsList, this.titleClick}): super(key: key);

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget> with SingleTickerProviderStateMixin {
  bool hide = false;
  late AnimationController _animationController;
  late Animation<Offset> _hideAnimation;
  late Animation<Offset> _visibleAnimation;
  @override
  void initState() {
    _animationController = AnimationController(duration: const Duration(seconds: NumConstants.delay_2), vsync: this);
    _hideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceIn,
      ),
    );
    _visibleAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceOut,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
          child: Row(children: [
            Expanded(child: InkWell(onTap: () => widget.titleClick?.call(), child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold),))),
            IconButton(onPressed: () {hide = hide ? false : true; setState(() {});}, icon: hide ? const Icon(Icons.keyboard_arrow_up_outlined) : const Icon(Icons.keyboard_arrow_down),),],),
        ),
        if (widget.nutrientsList.isNotEmpty) NutrientsDashboardWidget(
          title: '',
          nutrients: widget.nutrientsList.take(Constants.DASHBOARD_LIST_SIZE).toList(),
          isEmpty: false,
          ),
        if (widget.nutrientsList.length > Constants.DASHBOARD_LIST_SIZE) Visibility(
          visible: hide,
          child: NutrientsDashboardWidget(
            title: '',
            nutrients: widget.nutrientsList.sublist(Constants.DASHBOARD_LIST_SIZE).toList(),
            isEmpty: false,
            ),
        ),

      ],),
    );
  }
}