part of 'feature_posts_cubit.dart';

class FeaturePostsState extends Equatable {
  final Set<String> featurePostIds;

  const FeaturePostsState({
    @required this.featurePostIds,
  });

  factory FeaturePostsState.initial() {
    return FeaturePostsState(
      featurePostIds: {},
    );
  }

  @override
  List<Object> get props => [featurePostIds];

  FeaturePostsState copyWith({
    Set<String> featurePostIds,
  }) {
    return FeaturePostsState(
      featurePostIds: featurePostIds ?? this.featurePostIds,
    );
  }
}
