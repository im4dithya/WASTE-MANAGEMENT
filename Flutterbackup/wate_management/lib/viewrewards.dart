import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'Home.dart';
void main(){
  runApp(viewrewards());
}
class viewrewards extends StatelessWidget {
  const viewrewards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: viewrewards_sub(),);
  }
}
class viewrewards_sub extends StatefulWidget {
  const viewrewards_sub({Key? key}) : super(key: key);

  @override
  State<viewrewards_sub> createState() => _viewrewards_subState();
}

class _viewrewards_subState extends State<viewrewards_sub> {
  late Future<Map<String, dynamic>> _rewardsData;

  @override
  void initState() {
    super.initState();
    _rewardsData = _getRewards();
  }
  List<Joke> jokes = [];

  Future<Map<String, dynamic>> _getRewards() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Debug: Check if values exist
      final ip = prefs.getString("ip");
      final uid = prefs.getString("uid");
      
      print("DEBUG: IP = $ip");
      print("DEBUG: UID = $uid");
      
      if (ip == null || uid == null) {
        print("ERROR: IP or UID not found in SharedPreferences");
        throw Exception("Missing IP or UID in preferences");
      }

      final url = ip.endsWith("/") ? "$ip" : "$ip/";
      final fullUrl = Uri.parse(url + "view_rewards");
      
      print("DEBUG: Making request to: $fullUrl");
      
      var response = await http.post(
        fullUrl,
        body: {"uid": uid},
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () => throw Exception("Request timeout"),
      );

      print("DEBUG: Response status: ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      var jsonData = json.decode(response.body);
      print("DEBUG: Parsed JSON: $jsonData");

      jokes.clear(); // Clear previous data
      
      // Handle both array and object responses
      List<dynamic> dataList = [];
      int totalReward = 0;
      
      if (jsonData is List) {
        // Response is directly an array
        dataList = jsonData;
        totalReward = 0; // Calculate from items or set to 0
      } else if (jsonData is Map) {
        // Response is an object with data and total_reward keys
        dataList = jsonData["data"] ?? [];
        totalReward = jsonData["total_reward"] ?? 0;
      }
      
      print("DEBUG: DataList length: ${dataList.length}, Total: $totalReward");
      
      for (var item in dataList) {
        try {
          // Handle pending rewards and dates
          String rewardVal = item["reward"]?.toString() ?? "0";
          String collectionDateVal = item["collectiondate"]?.toString() ?? "N/A";
          
          // Skip invalid entries
          if (rewardVal.isEmpty || item["id"] == null) {
            print("DEBUG: Skipping invalid item: $item");
            continue;
          }
          
          Joke newJoke = Joke(
            item["id"].toString(),
            rewardVal,
            item["status"]?.toString() ?? "unknown",
            collectionDateVal,
            item["username"]?.toString() ?? "Unknown",
            item["amount"]?.toString() ?? "0",
          );
          jokes.add(newJoke);
          print("DEBUG: Added joke: ${newJoke.id}, reward: ${newJoke.reward}, status: ${newJoke.status}");
        } catch (e) {
          print("DEBUG: Error processing item: $e");
        }
      }

      setState(() {
        jokes = jokes;
      });

      return {
        'rewards': jokes,
        'total': totalReward,
      };
    } catch (e) {
      print("ERROR in _getRewards: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Your Rewards",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green[700],
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _rewardsData,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading your rewards...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading rewards',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Loading..."));
          }

          final rewards = snapshot.data!['rewards'] as List<Joke>;
          final totalReward = snapshot.data!['total'] as int;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              final isLargeScreen = constraints.maxWidth > 900;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with total rewards
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green[700]!,
                          Colors.green[600]!,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Total Reward Points',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$totalReward',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 48 : 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'From ${rewards.length} collection${rewards.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Statistics row for larger screens
                  if (isLargeScreen && rewards.isNotEmpty)
                    Container(
                      margin: EdgeInsets.all(16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                Icons.check_circle,
                                'Collected',
                                rewards.where((r) => r.status == 'collected').length.toString(),
                                Colors.green,
                              ),
                              _buildStatItem(
                                Icons.pending_actions,
                                'Pending',
                                rewards.where((r) => r.status != 'collected').length.toString(),
                                Colors.orange,
                              ),
                              _buildStatItem(
                                Icons.calendar_today,
                                'Total Collections',
                                rewards.length.toString(),
                                Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Reward history section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.green[700],
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Reward History',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Spacer(),
                              if (rewards.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green[100]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${rewards.length} items',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Rewards list or empty state
                          if (rewards.isEmpty)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 72,
                                      color: Colors.grey[300],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No rewards yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Complete waste collections to earn rewards',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isSmallScreen ? 1 : (isLargeScreen ? 2 : 1),
                                  crossAxisSpacing: isSmallScreen ? 0 : 16,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: isSmallScreen ? 2.8 : 2.0,
                                ),
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: rewards.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var reward = rewards[index];
                                  final isCollected = reward.status == 'collected';

                                  return _buildRewardCard(reward, isCollected, isSmallScreen);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRewardCard(Joke reward, bool isCollected, bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCollected
                ? [Colors.green.shade50, Colors.green.shade100]
                : [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCollected ? Colors.green.shade200! : Colors.orange.shade200!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              Container(
                width: 8,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isCollected ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              SizedBox(width: 3),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCollected ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCollected ? 'COLLECTED' : 'PENDING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${reward.reward}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            Text(
                              'points',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // SizedBox(height: 1),

                    // Collection date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            reward.collectiondate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),

                    // User info
                    _buildInfoRow('User:', reward.username, Icons.person_outline),
                    SizedBox(height: 1),
                    _buildInfoRow('Amount:', reward.amount, Icons.monetization_on_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Colors.grey[600],
        ),
        SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Joke {
  final String id;
  final String reward;
  final String status;
  final String collectiondate;
  final String username;
  final String amount;

  Joke(
      this.id,
      this.reward,
      this.status,
      this.collectiondate,
      this.username,
      this.amount,
      );
}
