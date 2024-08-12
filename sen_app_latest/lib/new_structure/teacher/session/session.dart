import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sen_app_latest/new_structure/sen_group/sen_group.dart';

class SessionLanding extends StatefulWidget {
  const SessionLanding({super.key, required this.username, required this.email});
  final String username;
  final String email;

  @override
  SessionLandingState createState() => SessionLandingState();
}

class SessionLandingState extends State<SessionLanding> {
  final List<Map<String, dynamic>> sessions = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _joinController = TextEditingController();
  List<Map<String, dynamic>> filteredSessions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSessions);
    _fetchSessions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _joinController.dispose();
    super.dispose();
  }

  void _filterSessions() {
    setState(() {
      filteredSessions = sessions
          .where((session) => session['title']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _fetchSessions() {
    FirebaseFirestore.instance.collection('Sessions').snapshots().listen(
      (snapshot) async {
        final List<DocumentSnapshot> sessionDocs = snapshot.docs;

        sessions.clear();
        filteredSessions.clear();

        final List usernames = sessionDocs.map((doc) => doc['username']).toList();

        // Batch fetch profiles
        final QuerySnapshot profileQuery = await FirebaseFirestore.instance
            .collection('profile')
            .where('username', whereIn: usernames)
            .get();

        final Map<String, String?> profileImageMap = {};

        for (var profileDoc in profileQuery.docs) {
          profileImageMap[profileDoc['username']] = profileDoc['profile_image_url'];
        }

        for (var sessionDoc in sessionDocs) {
          String username = sessionDoc['username'];
          String? profileImageUrl = profileImageMap[username];
          List<dynamic> joinedUsers = sessionDoc['joinedUsers'] ?? [];

          sessions.add({
            'title': sessionDoc['sessionTitle'],
            'code': sessionDoc['code'],
            'username': username,
            'profile_image_url': profileImageUrl,
            'joinedUsers': joinedUsers,
          });
        }

        setState(() {
          filteredSessions = List.from(sessions);
        });

        print("Sessions and profiles retrieved successfully.");
      },
      onError: (e) {
        debugPrint('Error fetching sessions: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sessions: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );
  }

  Future<void> saveSession(
      String title, String code, String username, String email) async {
    try {
      // Fetch user's profile image URL from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('profile')
          .where('username', isEqualTo: username)
          .get();

      String? profileImageUrl;
      if (userDoc.docs.isNotEmpty) {
        profileImageUrl = userDoc.docs.first['profile_image_url'];
      }

      await FirebaseFirestore.instance.collection('Sessions').add({
        'sessionTitle': title,
        'code': code,
        'username': username,
        'email': email,
        'profile_image_url': profileImageUrl, // Save profile image URL
        'joinedUsers': [], // Initially, no users have joined
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Session saved successfully.");
    } catch (e) {
      debugPrint('Error saving session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save session: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> joinSession(String code, String username) async {
    try {
      final sessionQuery = await FirebaseFirestore.instance
          .collection('Sessions')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (sessionQuery.docs.isNotEmpty) {
        DocumentSnapshot sessionDoc = sessionQuery.docs.first;
        List<dynamic> joinedUsers = sessionDoc['joinedUsers'] ?? [];

        if (!joinedUsers.contains(username)) {
          joinedUsers.add(username);
          await sessionDoc.reference.update({
            'joinedUsers': joinedUsers,
          });
        }

        bool sessionExists = sessions.any((session) => session['code'] == code);
        if (!sessionExists) {
          setState(() {
            sessions.add({
              'title': sessionDoc['sessionTitle'],
              'code': sessionDoc['code'],
              'username': sessionDoc['username'],
              'profile_image_url': sessionDoc['profile_image_url'],
              'joinedUsers': joinedUsers,
            });
            filteredSessions = sessions;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session joined successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session not found'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining session: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _deleteSession(int index) async {
    try {
      String? sessionCode = sessions[index]['code'];
      String? sessionCreator = sessions[index]['username'];

      if (sessionCreator != widget.username) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only the creator can delete this session'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final sessionQuery = await FirebaseFirestore.instance
          .collection('Sessions')
          .where('code', isEqualTo: sessionCode)
          .limit(1)
          .get();

      if (sessionQuery.docs.isNotEmpty) {
        DocumentSnapshot sessionDoc = sessionQuery.docs.first;
        await sessionDoc.reference.delete();

        setState(() {
          sessions.removeAt(index);
          filteredSessions = sessions;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to find the session for deletion'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete session: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _generateCode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        String? title;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 25,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 25,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'New Session',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.teal),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          title = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          final random = Random();
                          String generatedCode = (random.nextInt(9000) + 1000)
                              .toString(); // Generate a 4-digit code

                          saveSession(title!, generatedCode, widget.username,
                              widget.email);

                          setState(() {
                            sessions.add({
                              'title': title,
                              'code': generatedCode,
                              'username': widget.username,
                              'profile_image_url': null, // Default to null, will update later
                              'joinedUsers': [],
                            });
                            filteredSessions = sessions; // Update filtered list
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showJoinSessionDialog(String sessionCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Join Session', style: TextStyle(color: Colors.teal)),
          content: TextField(
            controller: _joinController,
            decoration: InputDecoration(
              labelText: 'Enter Session Code',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_joinController.text == sessionCode) {
                  joinSession(sessionCode, widget.username);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid session code'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Join', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  void _showMembers(List<dynamic> members, String creator) async {
    final creatorDoc = await FirebaseFirestore.instance
        .collection('profile')
        .where('username', isEqualTo: creator)
        .get();

    String? creatorImageUrl;
    if (creatorDoc.docs.isNotEmpty) {
      creatorImageUrl = creatorDoc.docs.first['profile_image_url'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text('Session Members', style: TextStyle(color: Colors.teal)),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: members.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: creatorImageUrl != null
                            ? NetworkImage(creatorImageUrl)
                            : const AssetImage('assets/default_profile.png') as ImageProvider,
                        radius: 20.0,
                      ),
                      title: Text('@$creator', style: const TextStyle(color: Colors.black)),
                      subtitle: const Text('Creator', style: TextStyle(color: Colors.amber)),
                    ),
                  );
                }

                String username = members[index - 1];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('profile')
                      .where('username', isEqualTo: username)
                      .get()
                      .then((value) => value.docs.first),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      String? memberImageUrl = snapshot.data?['profile_image_url'];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: memberImageUrl != null
                                ? NetworkImage(memberImageUrl)
                                : const AssetImage('assets/default_profile.png') as ImageProvider,
                            radius: 20.0,
                          ),
                          title: Text('@$username', style: const TextStyle(color: Colors.black)),
                          subtitle: Text('Member', style: TextStyle(color: Colors.grey[700])),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBanner(Map<String, dynamic> session, int index) {
  bool isCreator = session['username'] == widget.username;
  bool isMember = session['joinedUsers'].contains(widget.username);

  return GestureDetector(
    onTap: () {
      // Only allow access if the user is a creator or a member
      if (isCreator || isMember) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SenGroupPage(
              sessionTitle: session['title'],
              sessionCode: session['code'],
              username: widget.username,
            ),
          ),
        );
      } else {
        // Show a message if the user is not authorized
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not a member of this session. Please join first.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    },
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[850]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: session['profile_image_url'] != null
                ? NetworkImage(session['profile_image_url']!)
                : const AssetImage('assets/default_profile.png') as ImageProvider,
            radius: 20.0,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session['title'] != null && session['title']!.isNotEmpty)
                  Text(
                    session['title']!,
                    style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 5),
                if (isCreator && session['code'] != null)
                  Text(
                    'Sen Code: ${session['code']}',
                    style: const TextStyle(color: Colors.teal, fontSize: 16.0),
                  ),
                if (!isMember && !isCreator)
                    const Text(
                        'Enter Sen Code to join',
                        style: TextStyle(color: Colors.white, fontSize: 14.0),
                    ),
              ],
            ),
          ),
          if (!isMember && !isCreator)
            IconButton(
              icon: const Icon(Icons.group_add, color: Colors.greenAccent),
              onPressed: () {
                _showJoinSessionDialog(session['code']);
              },
            ),
          IconButton(
            icon: const Icon(Icons.group, color: Colors.blueAccent),
            onPressed: () async {
              final sessionQuery = await FirebaseFirestore.instance
                  .collection('Sessions')
                  .where('code', isEqualTo: session['code'])
                  .limit(1)
                  .get();
              if (sessionQuery.docs.isNotEmpty) {
                List<dynamic> members = sessionQuery.docs.first['joinedUsers'];
                _showMembers(members, session['username']!);
              }
            },
          ),
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                _deleteSession(index);
              },
            ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Lottie.network(
              'https://lottie.host/0a0023ec-5f54-413c-a606-379c31b96aa3/mlPolAAUBJ.json',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.72,
              height: MediaQuery.of(context).size.height * 0.72,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    hintText: 'Search sessions...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredSessions.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredSessions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: _buildBanner(filteredSessions[index], index),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No sessions found',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.teal, Colors.greenAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _generateCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 30.0),
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.teal, Colors.greenAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _showJoinSessionDialog(""); // Empty code means open the general dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 30.0),
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
