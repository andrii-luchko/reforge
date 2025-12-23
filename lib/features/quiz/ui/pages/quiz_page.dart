import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/ui/widgets/date_piker.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/shaders/particles_shader.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/step_proggress_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppAppBar(onPressed: () {}),
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: ParticlesShaderWidget()),
            Positioned.fill(
              child: Image.asset(
                Assets.images.png.smoke.path,
                fit: .fill,
                opacity: const AlwaysStoppedAnimation<double>(0.5),
              ),
            ),

            Positioned.fill(
              child: Image.asset(
                Assets.images.png.noiseAndTexture.path,
                fit: .fill,
              ),
            ),

            Positioned.fill(
              child: SunRaysShaderWidget(
                color: appTheme.orange500,
                alignment: const Alignment(0, -1.2),
                intensity: 1,
                density: 5,
                rayLength: 0.6,
              ),
            ),

            Positioned.fill(
              child: Padding(
                padding: const .symmetric(horizontal: 16),
                child: SafeArea(child: QuizForm()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizForm extends StatefulWidget {
  const QuizForm({super.key});

  @override
  State<QuizForm> createState() => _QuizFormState();
}

class _QuizFormState extends State<QuizForm> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getIndicatorDotWidth(BoxConstraints constraints) => (constraints.maxWidth - (6 * 7)) / 7;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: const StepProgressIndicator(
            currentStep: 1,
            totalSteps: 7,
          ),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [Expanded(child: DateBirthStep())],
          ),
        ),

        Row(
          children: [
            Expanded(child: SecondaryButton(text: 'Back')),
            SizedBox(
              width: 16,
            ),
            Expanded(child: PrimaryButton(text: 'Next')),
          ],
        ),
      ],
    );
  }
}

class DateBirthStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabeledAppTextField(
          label: 'Select date of birth',
          field: FieldDatePicker(
            onDateSelected: (value) {},
          ),
        ),
      ],
    );
  }
}
