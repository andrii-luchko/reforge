import 'package:reforge/features/lore/controller/lore_cubit.dart';

bool canStartPlateOfKeraguraGuide({
  required LoreState state,
  required int? userId,
}) {
  return userId != null && !state.isLoading && state.error == null && state.items.isNotEmpty;
}
