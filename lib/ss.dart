// lib/features/social/domain/services/social_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spaceverse/exceptions.dart';
// import 'package:spaceverse/features/social/domain/entities/user_profile.dart';
// import 'package:spaceverse/features/social/domain/entities/discovery_post.dart';
// import 'package:spaceverse/features/social/domain/entities/habitat_share.dart';
// import 'package:spaceverse/core/errors/exceptions.dart';

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<UserProfile> createUserProfile({
    required String username,
    required String email,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }
      
      final profile = UserProfile(
        id: user.uid,
        username: username,
        email: email,
        bio: bio ?? '',
        avatarUrl: avatarUrl ?? '',
        createdAt: DateTime.now(),
        discoveries: 0,
        designs: 0,
        followers: 0,
        following: 0,
        badges: [],
      );
      
      await _firestore.collection('users').doc(user.uid).set(profile.toJson());
      
      return profile;
    } catch (e) {
      throw SocialException('Failed to create user profile', details: e);
    }
  }

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        throw SocialException('User profile not found');
      }
      
      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      throw SocialException('Failed to get user profile', details: e);
    }
  }

  Future<List<DiscoveryPost>> getDiscoveryPosts({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('discoveries')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => DiscoveryPost.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw SocialException('Failed to get discovery posts', details: e);
    }
  }

  Future<DiscoveryPost> shareDiscovery({
    required String exoplanetId,
    required String exoplanetName,
    required String description,
    required List<String> imageUrls,
    required Map<String, dynamic> exoplanetData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }
      
      final post = DiscoveryPost(
        id: _firestore.collection('discoveries').doc().id,
        userId: user.uid,
        exoplanetId: exoplanetId,
        exoplanetName: exoplanetName,
        description: description,
        imageUrls: imageUrls,
        exoplanetData: exoplanetData,
        createdAt: DateTime.now(),
        likes: 0,
        comments: 0,
        shares: 0,
      );
      
      await _firestore.collection('discoveries').doc(post.id).set(post.toJson());
      
      // Update user's discovery count
      await _firestore.collection('users').doc(user.uid).update({
        'discoveries': FieldValue.increment(1),
      });
      
      return post;
    } catch (e) {
      throw SocialException('Failed to share discovery', details: e);
    }
  }

  Future<HabitatShare> shareHabitatDesign({
    required String habitatId,
    required String habitatName,
    required String description,
    required List<String> imageUrls,
    required Map<String, dynamic> habitatData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }
      
      final share = HabitatShare(
        id: _firestore.collection('habitats').doc().id,
        userId: user.uid,
        habitatId: habitatId,
        habitatName: habitatName,
        description: description,
        imageUrls: imageUrls,
        habitatData: habitatData,
        createdAt: DateTime.now(),
        likes: 0,
        comments: 0,
        shares: 0,
        downloads: 0,
      );
      
      await _firestore.collection('habitats').doc(share.id).set(share.toJson());
      
      // Update user's design count
      await _firestore.collection('users').doc(user.uid).update({
        'designs': FieldValue.increment(1),
      });
      
      return share;
    } catch (e) {
      throw SocialException('Failed to share habitat design', details: e);
    }
  }

  Future<void> likeDiscovery(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }
      
      // Add like
      await _firestore.collection('discoveries').doc(postId).update({
        'likes': FieldValue.increment(1),
      });
      
      // Add to user's likes
      await _firestore.collection('users').doc(user.uid)
          .collection('likedDiscoveries')
          .doc(postId)
          .set({'likedAt': DateTime.now()});
    } catch (e) {
      throw SocialException('Failed to like discovery', details: e);
    }
  }

  Future<void> followUser(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }
      
      // Add to following
      await _firestore.collection('users').doc(user.uid)
          .collection('following')
          .doc(userId)
          .set({'followedAt': DateTime.now()});
      
      // Add to followers
      await _firestore.collection('users').doc(userId)
          .collection('followers')
          .doc(user.uid)
          .set({'followedAt': DateTime.now()});
      
      // Update counts
      await _firestore.collection('users').doc(user.uid).update({
        'following': FieldValue.increment(1),
      });
      
      await _firestore.collection('users').doc(userId).update({
        'followers': FieldValue.increment(1),
      });
    } catch (e) {
      throw SocialException('Failed to follow user', details: e);
    }
  }

  Future<List<UserProfile>> getFollowers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .get();
      
      final followerIds = snapshot.docs.map((doc) => doc.id).toList();
      
      if (followerIds.isEmpty) return [];
      
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: followerIds)
          .get();
      
      return usersSnapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw SocialException('Failed to get followers', details: e);
    }
  }

  Future<List<DiscoveryPost>> getUserDiscoveries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('discoveries')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => DiscoveryPost.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw SocialException('Failed to get user discoveries', details: e);
    }
  }

  Future<List<HabitatShare>> getUserHabitats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('habitats')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => HabitatShare.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw SocialException('Failed to get user habitats', details: e);
    }
  }

  Future<void> addComment({
    required String postId,
    required String comment,
    required PostType postType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }
      
      final userProfile = await getUserProfile(user.uid);
      
      final commentData = {
        'id': _firestore.collection('comments').doc().id,
        'userId': user.uid,
        'username': userProfile.username,
        'avatarUrl': userProfile.avatarUrl,
        'comment': comment,
        'createdAt': DateTime.now(),
      };
      
      // Add comment to post
      final collection = postType == PostType.discovery ? 'discoveries' : 'habitats';
      await _firestore.collection(collection).doc(postId)
          .collection('comments')
          .add(commentData);
      
      // Update comment count
      await _firestore.collection(collection).doc(postId).update({
        'comments': FieldValue.increment(1),
      });
    } catch (e) {
      throw SocialException('Failed to add comment', details: e);
    }
  }

  Future<List<Comment>> getComments(String postId, PostType postType) async {
    try {
      final collection = postType == PostType.discovery ? 'discoveries' : 'habitats';
      final snapshot = await _firestore
          .collection(collection)
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Comment.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw SocialException('Failed to get comments', details: e);
    }
  }

  Future<void> awardBadge(String userId, Badge badge) async {
    try {
      await _firestore.collection('users').doc(userId)
          .collection('badges')
          .add({
        'badge': badge.name,
        'description': badge.description,
        'iconUrl': badge.iconUrl,
        'awardedAt': DateTime.now(),
      });
      
      // Update user's badges list
      await _firestore.collection('users').doc(userId).update({
        'badges': FieldValue.arrayUnion([badge.name]),
      });
    } catch (e) {
      throw SocialException('Failed to award badge', details: e);
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard(LeaderboardType type) async {
    try {
      String field;
      switch (type) {
        case LeaderboardType.discoveries:
          field = 'discoveries';
          break;
        case LeaderboardType.designs:
          field = 'designs';
          break;
        case LeaderboardType.followers:
          field = 'followers';
          break;
      }
      
      final snapshot = await _firestore
          .collection('users')
          .orderBy(field, descending: true)
          .limit(100)
          .get();
      
      return snapshot.docs
          .map((doc) => LeaderboardEntry(
            user: UserProfile.fromJson(doc.data()),
            score: doc.data()[field] ?? 0,
          ))
          .toList();
    } catch (e) {
      throw SocialException('Failed to get leaderboard', details: e);
    }
  }
}

// Additional classes for social features
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String avatarUrl;
  final DateTime createdAt;
  final int discoveries;
  final int designs;
  final int followers;
  final int following;
  final List<String> badges;
  
  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.avatarUrl,
    required this.createdAt,
    required this.discoveries,
    required this.designs,
    required this.followers,
    required this.following,
    required this.badges,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      discoveries: json['discoveries'] ?? 0,
      designs: json['designs'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'discoveries': discoveries,
      'designs': designs,
      'followers': followers,
      'following': following,
      'badges': badges,
    };
  }
}

class DiscoveryPost {
  final String id;
  final String userId;
  final String exoplanetId;
  final String exoplanetName;
  final String description;
  final List<String> imageUrls;
  final Map<String, dynamic> exoplanetData;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int shares;
  
  DiscoveryPost({
    required this.id,
    required this.userId,
    required this.exoplanetId,
    required this.exoplanetName,
    required this.description,
    required this.imageUrls,
    required this.exoplanetData,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.shares,
  });
  
  factory DiscoveryPost.fromJson(Map<String, dynamic> json) {
    return DiscoveryPost(
      id: json['id'],
      userId: json['userId'],
      exoplanetId: json['exoplanetId'],
      exoplanetName: json['exoplanetName'],
      description: json['description'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      exoplanetData: json['exoplanetData'] ?? {},
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exoplanetId': exoplanetId,
      'exoplanetName': exoplanetName,
      'description': description,
      'imageUrls': imageUrls,
      'exoplanetData': exoplanetData,
      'createdAt': createdAt,
      'likes': likes,
      'comments': comments,
      'shares': shares,
    };
  }
}

class HabitatShare {
  final String id;
  final String userId;
  final String habitatId;
  final String habitatName;
  final String description;
  final List<String> imageUrls;
  final Map<String, dynamic> habitatData;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int shares;
  final int downloads;
  
  HabitatShare({
    required this.id,
    required this.userId,
    required this.habitatId,
    required this.habitatName,
    required this.description,
    required this.imageUrls,
    required this.habitatData,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.downloads,
  });
  
  factory HabitatShare.fromJson(Map<String, dynamic> json) {
    return HabitatShare(
      id: json['id'],
      userId: json['userId'],
      habitatId: json['habitatId'],
      habitatName: json['habitatName'],
      description: json['description'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      habitatData: json['habitatData'] ?? {},
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      downloads: json['downloads'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'habitatId': habitatId,
      'habitatName': habitatName,
      'description': description,
      'imageUrls': imageUrls,
      'habitatData': habitatData,
      'createdAt': createdAt,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'downloads': downloads,
    };
  }
}

class Comment {
  final String id;
  final String userId;
  final String username;
  final String avatarUrl;
  final String comment;
  final DateTime createdAt;
  
  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.comment,
    required this.createdAt,
  });
  
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'] ?? '',
      comment: json['comment'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}

class Badge {
  final String name;
  final String description;
  final String iconUrl;
  
  Badge({
    required this.name,
    required this.description,
    required this.iconUrl,
  });
}

class LeaderboardEntry {
  final UserProfile user;
  final int score;
  
  LeaderboardEntry({
    required this.user,
    required this.score,
  });
}

enum PostType {
  discovery,
  habitat,
}

enum LeaderboardType {
  discoveries,
  designs,
  followers,
}