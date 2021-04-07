import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:demoinsta/blocs/blocs.dart';
import 'package:demoinsta/cubits/cubits.dart';
import 'package:demoinsta/models/models.dart';
import 'package:demoinsta/repositories/repositories.dart';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository _postRepository;
  final AuthBloc _authBloc;
  final LikedPostsCubit _likedPostsCubit;
  final FeaturePostsCubit _featurePostsCubit;

  StreamSubscription<List<Future<Post>>> _featurePostsSubscription;

  FeedBloc({
    @required PostRepository postRepository,
    @required AuthBloc authBloc,
    @required LikedPostsCubit likedPostsCubit,
    @required FeaturePostsCubit featurePostsCubit,
  })  : _postRepository = postRepository,
        _authBloc = authBloc,
        _likedPostsCubit = likedPostsCubit,
        _featurePostsCubit = featurePostsCubit,
        super(FeedState.initial());

  @override
  Future<void> close() {
    _featurePostsSubscription.cancel();
    return super.close();
  }

  @override
  Stream<FeedState> mapEventToState(FeedEvent event) async* {
    if (event is FeedFetchPosts) {
      yield* _mapFeedFetchPostsToState();
    } else if (event is FeedPaginatePosts) {
      yield* _mapFeedPaginatePostsToState();
    } else if (event is FeedFetchFeaturePosts) {
      yield* _mapFeedFetchFeaturePostsToState();
    } else if (event is FeedPaginateFeaturePosts) {
      yield* _mapFeedPaginateFeaturePostsToState();
    }
  }

  Stream<FeedState> _mapFeedFetchPostsToState() async* {
    yield state.copyWith(posts: [], status: FeedStatus.loading);

    try {
      final posts =
          await _postRepository.getUserFeed(userId: _authBloc.state.user.uid);

      _likedPostsCubit.clearAllLikedPosts();

      final likedPostsIds = await _postRepository.getLikedPostsIds(
        userId: _authBloc.state.user.uid,
        posts: posts,
      );
      _likedPostsCubit.updateLikedPosts(postIds: likedPostsIds);

      yield state.copyWith(posts: posts, status: FeedStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: FeedStatus.error,
        failure: const Failure(message: 'We were unable to load your feed.'),
      );
    }
  }

  Stream<FeedState> _mapFeedPaginatePostsToState() async* {
    yield state.copyWith(status: FeedStatus.paginating);

    try {
      final lastPostId = state.posts.isNotEmpty ? state.posts.last.id : null;
      final posts = await _postRepository.getUserFeed(
        userId: _authBloc.state.user.uid,
        lastPostId: lastPostId,
      );

      final updatedPosts = List<Post>.from(state.posts)..addAll(posts);

      final likedPostsIds = await _postRepository.getLikedPostsIds(
        userId: _authBloc.state.user.uid,
        posts: posts,
      );
      _likedPostsCubit.updateLikedPosts(postIds: likedPostsIds);

      yield state.copyWith(posts: updatedPosts, status: FeedStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: FeedStatus.error,
        failure: const Failure(message: 'We were unable to load your feed.'),
      );
    }
  }

  Stream<FeedState> _mapFeedFetchFeaturePostsToState() async* {
    yield state.copyWith(featurePosts: [], status: FeedStatus.loading);

    try {
      final lastPostId =
          state.featurePosts.isNotEmpty ? state.featurePosts.last.id : null;
      final featurePosts = await _postRepository.getFeatureFeed(
        lastPostId: lastPostId,
      );

      final updatedFeaturePosts = List<Post>.from(state.featurePosts)
        ..addAll(featurePosts);

      yield state.copyWith(
          featurePosts: updatedFeaturePosts, status: FeedStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: FeedStatus.error,
        failure: const Failure(message: 'We were unable to load your feed.'),
      );
    }
  }

  Stream<FeedState> _mapFeedPaginateFeaturePostsToState() async* {
    yield state.copyWith(featurePosts: [], status: FeedStatus.paginating);

    try {
      final lastPostId =
          state.featurePosts.isNotEmpty ? state.featurePosts.last.id : null;
      final featurePosts = await _postRepository.getFeatureFeed(
        lastPostId: lastPostId,
      );

      final updatedFeaturePosts = List<Post>.from(state.featurePosts)
        ..addAll(featurePosts);

      yield state.copyWith(
          featurePosts: updatedFeaturePosts, status: FeedStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: FeedStatus.error,
        failure: const Failure(message: 'We were unable to load your feed.'),
      );
    }
  }
}
