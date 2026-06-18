import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Cricket Match',
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: controller.logout,
              ),
            ],
          ),
          body: const Center(
            child: Text('Home Screen'),
          ),
        );
      },
    );
  }
}
