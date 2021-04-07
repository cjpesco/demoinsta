import 'package:bloc/bloc.dart';
import 'package:demoinsta/blocs/blocs.dart';
import 'package:demoinsta/models/models.dart';
import 'package:demoinsta/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'feature_posts_state.dart';

class FeaturePostsCubit extends Cubit<FeaturePostsState> {
  final PostRepository _postRepository;

  FeaturePostsCubit({
    PostRepository postRepository,
    AuthBloc authBloc,
  })  : _postRepository = postRepository,
        super(FeaturePostsState.initial());

  void updateFeaturedPosts({@required Set<String> postIds}) {
    emit(
      state.copyWith(
        featurePostIds: Set<String>.from(state.featurePostIds)..addAll(postIds),
      ),
    );
  }

  void featurePost({@required Post post}) {
    _postRepository.featurePost(post: post);

    emit(
      state.copyWith(
        featurePostIds: Set<String>.from(state.featurePostIds)..add(post.id),
      ),
    );
  }

  void clearAllLikedPosts() {
    emit(FeaturePostsState.initial());
  }
}
