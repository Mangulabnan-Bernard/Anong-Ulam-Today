import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/recipe.dart';
import '../providers/recipe_provider.dart';

class AddUlamScreen extends ConsumerStatefulWidget {
  const AddUlamScreen({super.key});

  @override
  ConsumerState<AddUlamScreen> createState() => _AddUlamScreenState();
}

class _AddUlamScreenState extends ConsumerState<AddUlamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<TextEditingController> _ingredients = [TextEditingController()];
  final List<TextEditingController> _steps = [TextEditingController()];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _ingredients) {
      c.dispose();
    }
    for (final c in _steps) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ingredients = _ingredients
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => RecipeIngredient(name: t, quantity: ''))
        .toList();
    final steps = _steps
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final recipe = Recipe(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      mealTypes: const [MealType.any],
      difficulty: Difficulty.easy,
      cookingTimeMins: 30,
      ingredients: ingredients,
      instructions: steps,
      region: 'Sariling luto',
    );

    ref.read(userRecipesProvider.notifier).addRecipe(recipe);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${context.l10n.submitThanks} 🙏'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    _resetForm();
  }

  /// Clears the form back to a single empty ingredient/step so the user can
  /// immediately add another dish (this screen is a tab, not a pushed route).
  void _resetForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    for (final c in _ingredients) {
      c.dispose();
    }
    for (final c in _steps) {
      c.dispose();
    }
    setState(() {
      _ingredients
        ..clear()
        ..add(TextEditingController());
      _steps
        ..clear()
        ..add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.imageUploadSoon)),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, size: 36, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(l.addPhoto,
                          style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l.dishName,
                hintText: l.dishNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? l.dishNameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l.shortDescription,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _DynamicSection(
              title: l.ingredients,
              controllers: _ingredients,
              hint: l.ingredientHint,
              onAdd: () => setState(() => _ingredients.add(TextEditingController())),
              onRemove: (i) => setState(() => _ingredients.removeAt(i).dispose()),
            ),
            const SizedBox(height: 24),
            _DynamicSection(
              title: l.stepsLabel,
              controllers: _steps,
              hint: l.stepHint,
              numbered: true,
              onAdd: () => setState(() => _steps.add(TextEditingController())),
              onRemove: (i) => setState(() => _steps.removeAt(i).dispose()),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: Text(l.submitUlam),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicSection extends StatelessWidget {
  const _DynamicSection({
    required this.title,
    required this.controllers,
    required this.hint,
    required this.onAdd,
    required this.onRemove,
    this.numbered = false,
  });

  final String title;
  final List<TextEditingController> controllers;
  final String hint;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.l10n.add),
            ),
          ],
        ),
        ...controllers.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (numbered)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary,
                          child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(
                          hintText: hint,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (controllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: AppColors.error),
                        onPressed: () => onRemove(e.key),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
