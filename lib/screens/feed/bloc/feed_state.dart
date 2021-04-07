part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, paginating, error }

class FeedState extends Equatable {
  final List<Post> posts;
  final List<Post> featurePosts;
  final FeedStatus status;
  final Failure failure;

  const FeedState({
    @required this.posts,
    @required this.featurePosts,
    @required this.status,
    @required this.failure,
  });

  factory FeedState.initial() {
    return const FeedState(
      posts: [],
      featurePosts: [],
      status: FeedStatus.initial,
      failure: Failure(),
    );
  }
  @override
  List<Object> get props => [posts, featurePosts, status, failure];

  FeedState copyWith({
    List<Post> posts,
    List<Post> featurePosts,
    FeedStatus status,
    Failure failure,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      featurePosts: featurePosts ?? this.featurePosts,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
