import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoinsta/config/paths.dart';
import 'package:demoinsta/enums/enums.dart';

import 'package:demoinsta/models/comment_model.dart';
import 'package:demoinsta/models/models.dart';
import 'package:demoinsta/models/post_model.dart';
import 'package:demoinsta/repositories/repositories.dart';
import 'package:meta/meta.dart';

class PostRepository extends BasePostRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostRepository({FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost({@required Post post}) async {
    await _firebaseFirestore.collection(Paths.posts).add(post.toDocument());
  }

  @override
  Future<void> featurePost({Post post}) async {
    await _firebaseFirestore
        .collection(Paths.features)
        .doc(post.id)
        .set(post.toDocument());
  }

  // @override
  // void deleteFeaturePost(
  //     {@required String postId, @required String userId}) async {
  //   await _firebaseFirestore.collection(Paths.features).doc(postId).delete();
  // }

  @override
  Future<void> createComment(
      {@required Post post, @required Comment comment}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postId)
        .collection(Paths.postComments)
        .add(comment.toDocument());

    if (comment.author.id != post.author.id) {
      final notification = Notif(
        type: NotifType.comment,
        fromUser: comment.author,
        post: post,
        date: DateTime.now(),
      );

      _firebaseFirestore
          .collection(Paths.notifications)
          .doc(post.author.id)
          .collection(Paths.userNotifications)
          .add(notification.toDocument());
    }
  }

  @override
  void createLike({
    @required Post post,
    @required String userId,
  }) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(post.id)
        .update({'likes': FieldValue.increment(1)});

    _firebaseFirestore
        .collection(Paths.likes)
        .doc(post.id)
        .collection(Paths.postLikes)
        .doc(userId)
        .set({});

    if (userId != post.author.id) {
      final notification = Notif(
        type: NotifType.like,
        fromUser: User.empty.copyWith(id: userId),
        post: post,
        date: DateTime.now(),
      );

      _firebaseFirestore
          .collection(Paths.notifications)
          .doc(post.author.id)
          .collection(Paths.userNotifications)
          .add(notification.toDocument());
    }
  }

  @override
  Stream<List<Future<Post>>> getUserPosts({@required String userId}) {
    final authorRef = _firebaseFirestore.collection(Paths.users).doc(userId);

    return _firebaseFirestore
        .collection(Paths.posts)
        .where('author', isEqualTo: authorRef)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromDocument(doc)).toList());
  }

  @override
  Stream<List<Future<Comment>>> getPostComments({@required String postId}) {
    return _firebaseFirestore
        .collection(Paths.comments)
        .doc(postId)
        .collection(Paths.postComments)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Comment.fromDocument(doc)).toList());
  }

  @override
  Future<List<Post>> getUserFeed({
    @required String userId,
    String lastPostId,
  }) async {
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .limit(5)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .doc(lastPostId)
          .get();

      if (!lastPostDoc.exists) {
        return [];
      }
      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(5)
          .get();
    }

    final posts = Future.wait(
      postsSnap.docs.map((doc) => Post.fromDocument(doc)).toList(),
    );

    return posts;
  }

  @override
  Future<Set<String>> getLikedPostsIds({
    @required String userId,
    @required List<Post> posts,
  }) async {
    final postIds = <String>{};

    for (final post in posts) {
      final likeDoc = await _firebaseFirestore
          .collection(Paths.likes)
          .doc(post.id)
          .collection(Paths.postLikes)
          .doc(userId)
          .get();

      if (likeDoc.exists) {
        postIds.add(post.id);
      }
    }
    return postIds;
  }

  @override
  void deleteLike({@required String postId, @required String userId}) async {
    await _firebaseFirestore
        .collection(Paths.posts)
        .doc(postId)
        .update({'likes': FieldValue.increment(-1)});

    await _firebaseFirestore
        .collection(Paths.likes)
        .doc(postId)
        .collection(Paths.postLikes)
        .doc(userId)
        .delete();
  }

  @override
  Future<List<Post>> getFeatureFeed({String lastPostId}) async {
    QuerySnapshot featurePostsSnap;
    if (lastPostId == null) {
      featurePostsSnap = await _firebaseFirestore
          .collection(Paths.features)
          .orderBy('date', descending: true)
          .limit(10)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.features)
          .doc(lastPostId)
          .get();

      if (!lastPostDoc.exists) {
        return [];
      }
      featurePostsSnap = await _firebaseFirestore
          .collection(Paths.features)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(10)
          .get();
    }

    final featurePosts = Future.wait(
      featurePostsSnap.docs.map((doc) => Post.fromDocument(doc)).toList(),
    );

    return featurePosts;
  }
}
