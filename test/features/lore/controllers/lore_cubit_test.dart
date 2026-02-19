import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/lore/controller/lore_cubit.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';

import '../../../core/analytics/mocks/mock_analytics_service.dart';
import '../mocks/mock_lore_repository.dart';

PlatesEntity createTestPlatesEntity({
  int id = 1,
  String name = 'Test',
  String title = 'Test Title',
  String? imageUrl = 'https://example.com/image.png',
  String? loreBody,
  int unlockLevel = 1,
  bool isLocked = false,
}) {
  return PlatesEntity(
    id: id,
    name: name,
    title: title,
    imageUrl: imageUrl,
    loreBody: loreBody,
    unlockLevel: unlockLevel,
    isLocked: isLocked,
  );
}

({List<PlatesEntity> items, int total, bool hasMore}) createTestPaginatedPlates({
  List<PlatesEntity>? items,
  int total = 1,
  bool hasMore = false,
}) {
  return (
    items: items ?? [createTestPlatesEntity()],
    total: total,
    hasMore: hasMore,
  );
}

void main() {
  late MockLoreRepository mockRepository;
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockRepository = MockLoreRepository();
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(any())).thenAnswer((_) async {});
  });

  group('LoreCubit', () {
    group('loadLore', () {
      test('Success emits items, totalCount, hasMore, isLoading false', () async {
        final data = createTestPaginatedPlates(
          items: [createTestPlatesEntity()],
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(data));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.items, data.items);
        expect(cubit.state.totalCount, 1);
        expect(cubit.state.hasMore, false);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNull);
      });

      test('Error emits error, restores items, isLoading false', () async {
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.error(Exception('Network error')));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.error, isNotNull);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.items, isEmpty);
      });
    });

    group('loadMore', () {
      test('Success appends items and updates hasMore', () async {
        final page1 = createTestPaginatedPlates(
          items: [createTestPlatesEntity()],
          total: 2,
          hasMore: true,
        );
        final page2 = createTestPaginatedPlates(
          items: [createTestPlatesEntity(id: 2)],
          total: 2,
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(page1));
        when(() => mockRepository.getPlates(page: 2))
            .thenAnswer((_) async => Result.success(page2));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.loadMore();

        expect(cubit.state.items.length, 2);
        expect(cubit.state.items[0].id, 1);
        expect(cubit.state.items[1].id, 2);
        expect(cubit.state.hasMore, false);
        expect(cubit.state.isLoadingMore, false);
      });

      test('Error decrements page and emits error', () async {
        final page1 = createTestPaginatedPlates(
          items: [createTestPlatesEntity()],
          total: 2,
          hasMore: true,
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(page1));
        when(() => mockRepository.getPlates(page: 2))
            .thenAnswer((_) async => Result.error(Exception('Load more failed')));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.loadMore();

        expect(cubit.state.error, isNotNull);
        expect(cubit.state.isLoadingMore, false);
        expect(cubit.state.items.length, 1);
      });

      test('when hasMore false does not call repository', () async {
        final page1 = createTestPaginatedPlates(
          items: [createTestPlatesEntity()],
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(page1));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.loadMore();

        verifyNever(() => mockRepository.getPlates(page: 2));
      });

      test('when isLoadingMore does not call repository', () async {
        final page1 = createTestPaginatedPlates(
          items: [createTestPlatesEntity()],
          total: 2,
          hasMore: true,
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(page1));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        cubit.emit(cubit.state.copyWith(isLoadingMore: true));
        await cubit.loadMore();

        verifyNever(() => mockRepository.getPlates(page: 2));
      });
    });

    group('loadPlateDetail', () {
      test('Success updates item in list', () async {
        final itemWithoutBody = createTestPlatesEntity();
        final itemWithBody = createTestPlatesEntity(
          loreBody: 'Full lore content',
        );
        final page1 = createTestPaginatedPlates(
          items: [itemWithoutBody],
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(page1));
        when(() => mockRepository.getPlateById(1))
            .thenAnswer((_) async => Result.success(itemWithBody));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.loadPlateDetail(1);

        expect(cubit.state.items.first.loreBody, 'Full lore content');
      });

      test('Error emits error', () async {
        final itemWithoutBody = createTestPlatesEntity();
        final page1 = createTestPaginatedPlates(
          items: [itemWithoutBody],
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(page1));
        when(() => mockRepository.getPlateById(1))
            .thenAnswer((_) async => Result.error(Exception('Detail load failed')));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.loadPlateDetail(1);

        expect(cubit.state.error, isNotNull);
      });

      test('when loreBody already set does not call repository', () async {
        final itemWithBody = createTestPlatesEntity(
          loreBody: 'Already loaded',
        );
        final page1 = createTestPaginatedPlates(
          items: [itemWithBody],
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(page1));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.loadPlateDetail(1);

        verifyNever(() => mockRepository.getPlateById(1));
      });

      test('when id not in items does not call repository', () async {
        final page1 = createTestPaginatedPlates(
          items: [createTestPlatesEntity()],
        );
        when(() => mockRepository.getPlates())
            .thenAnswer((_) async => Result.success(page1));

        final cubit = LoreCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.loadPlateDetail(999);

        verifyNever(() => mockRepository.getPlateById(999));
      });
    });
  });
}
