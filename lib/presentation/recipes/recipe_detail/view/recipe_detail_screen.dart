import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/ingredients_detail/recipe_ingredients.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/steps_detail/recipe_steps.dart';
import '../../../../infrastructure/utils/dimens.dart';

class RecipeDetailScreen extends StatefulWidget {
  static const routeName = 'recipe_detail';

  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  //Country List
  List<String> countryList = [
    'PAKISTAN',
    'INDIA',
    'JAPAN',
    'AUSTRALIA',
    'RUSSIA',
    'BELIZE',
  ];
  int _current = 0;
  CarouselController controller = CarouselController();
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // _selectedTab = _tabController.index;
        // _manageTabChange(context);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, size: 24),
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.recipes,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: Dimens.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(Dimens.heightXXLarge),
            child: Column(children: [
              CarouselSlider(
                carouselController: controller,
                items: countryList.map((e) {
                  return Container(
                    width: double.infinity,
                    color: AppColors.light_cyan,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                                onTap: () { ToastHelper().showToast(text: 'recipe_image$_current.png'); },
                                child: Image.asset('assets/images/recipe_image$_current.png', fit: BoxFit.fill),
                            ),
                        ),
                        SizedBox(
                          height: 50,
                          child: Container(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              onPressed: () { ToastHelper().showToast(text: e); },
                              icon: const Icon(Icons.favorite_border, size: 32, color: AppColors.errorRed),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 0.9,
                  enlargeCenterPage: true,
                  onPageChanged: (val, _) {
                    setState(() {
                      _current = val;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: countryList.map((image) {
                    int index = countryList.indexOf(image); //are changed
                    return Container(
                      width: Dimens.widthXXXXSmall - 4,
                      height: Dimens.heightXXSmall - 4,
                      margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal, horizontal: Dimens.marginXSmall - 2),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _current == index ? AppColors.mountainMeadow : AppColors.cardGreen_200),
                    );
                  },
                ).toList(),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.ingredients.toUpperCase()),
                  Tab(text: AppLocalizations.of(context)!.steps.toUpperCase()),
                ],
              ),
            ],),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  RecipeIngredients(),
                  RecipeSteps(),
                ],),
            ),
          ],
        ),
      ),
    );
  }
}
