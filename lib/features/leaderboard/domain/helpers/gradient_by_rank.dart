import 'package:flutter/material.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forge_rank.dart';

Gradient getGradientByRank(int rank, BuildContext context) => rank.immortalForgeGradient(context);
