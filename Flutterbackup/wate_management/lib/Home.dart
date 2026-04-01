import 'package:flutter/material.dart';
import 'package:wate_management/login.dart';
import 'package:wate_management/profile_edit.dart';
import 'package:wate_management/publicoffence.dart';
import 'package:wate_management/send%20complaint.dart';
import 'package:wate_management/sendfeedback.dart';
import 'package:wate_management/view%20cart%20and%20pay.dart';
import 'package:wate_management/view%20profile.dart';
import 'package:wate_management/view%20status.dart';
import 'package:wate_management/view%20type.dart';
import 'package:wate_management/view_public_offence.dart';
import 'package:wate_management/viewproduct.dart';
import 'package:wate_management/viewreply.dart';
import 'package:wate_management/viewrequeststatus.dart';
import 'package:wate_management/viewrewards.dart';
import 'package:wate_management/viewwastetype.dart';
import 'change password user.dart';

void main() {
  runApp(home());
}

class home extends StatelessWidget {
  const home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: homesub(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
    );
  }
}

class homesub extends StatefulWidget {
  const homesub({Key? key}) : super(key: key);

  @override
  State<homesub> createState() => _homesubState();
}

class _homesubState extends State<homesub> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Eco Manager",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.green[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[700],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[800]!, Colors.green[600]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Welcome, User!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Waste Management Portal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              Icons.home_filled,
              'Home',
              Colors.green[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => home())),
            ),
            Divider(color: Colors.green[200], height: 1),
            _buildDrawerItem(
              Icons.report_problem,
              'Complaint',
              Colors.orange[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewreply())),
            ),
            _buildDrawerItem(
              Icons.gavel,
              'Public Offence',
              Colors.red[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPublicOffence())),
            ),
            _buildDrawerItem(
              Icons.feedback,
              'Send Feedback',
              Colors.blue[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => sendfeedback())),
            ),
            _buildDrawerItem(
              Icons.delete,
              'View Waste Type',
              Colors.brown[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewwastetype())),
            ),
            _buildDrawerItem(
              Icons.track_changes,
              'Request Status & Rewards',
              Colors.purple[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewstatus1())),
            ),
            _buildDrawerItem(
              Icons.shopping_bag,
              'View Products',
              Colors.indigo[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewproduct())),
            ),
            _buildDrawerItem(
              Icons.shopping_cart,
              'View Cart',
              Colors.teal[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewcartandpay())),
            ),
            _buildDrawerItem(
              Icons.payment,
              'Status & Payment',
              Colors.cyan[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewStatusApp())),
            ),
            _buildDrawerItem(
              Icons.lock,
              'Change Password',
              Colors.grey[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => changepassword())),
            ),
            _buildDrawerItem(
              Icons.card_giftcard,
              'View Rewards',
              Colors.amber[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewrewards())),
            ),
            _buildDrawerItem(
              Icons.person_pin,
              'View Profile',
              Colors.deepOrange[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewprofile())),
            ),
            _buildDrawerItem(
              Icons.logout,
              'Logout',
              Colors.deepOrange[700]!,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => login())),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.green[200], height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'v1.0.0 • Eco Management System',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green[700]!, Colors.green[500]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Eco Manager',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Manage waste efficiently, earn rewards, and contribute to a cleaner environment.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildActionCard(
                      Icons.report_problem,
                      'File Complaint',
                      Colors.red[100]!,
                      Colors.red[700]!,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewreply())),
                    ),
                    _buildActionCard(
                      Icons.delete,
                      'Waste Types',
                      Colors.brown[100]!,
                      Colors.brown[700]!,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewwastetype())),
                    ),
                    _buildActionCard(
                      Icons.shopping_cart,
                      'My Cart',
                      Colors.teal[100]!,
                      Colors.teal[700]!,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewcartandpay())),
                    ),
                    _buildActionCard(
                      Icons.card_giftcard,
                      'Rewards',
                      Colors.amber[100]!,
                      Colors.amber[700]!,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => viewrewards())),
                    ),
                    // _buildActionCard(
                    //   Icons.logout,
                    //   'Logout',
                    //   Colors.amber[100]!,
                    //   Colors.amber[700]!,
                    //       () => Navigator.push(context, MaterialPageRoute(builder: (context) => login())),
                    // ),
                  ],
                ),
                SizedBox(height: 30),

                // Statistics Section
                Text(
                  'Your Impact',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 15),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem('Complaints', '12', Icons.report_problem, Colors.orange),
                            _buildStatItem('Recycled', '45 kg', Icons.recycling, Colors.green),
                            _buildStatItem('Rewards', '850 pts', Icons.star, Colors.amber),
                          ],
                        ),
                        SizedBox(height: 15),
                        LinearProgressIndicator(
                          value: 0.7,
                          backgroundColor: Colors.green[100],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Monthly Goal: 70% completed',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Recent Activities
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 15),
                _buildActivityItem(
                  Icons.check_circle,
                  'Complaint resolved',
                  'Your waste pickup request has been completed',
                  Colors.green,
                ),
                _buildActivityItem(
                  Icons.local_offer,
                  'New reward earned',
                  'You earned 50 points for recycling plastic',
                  Colors.amber,
                ),
                _buildActivityItem(
                  Icons.schedule,
                  'Pickup scheduled',
                  'Next pickup scheduled for tomorrow at 10 AM',
                  Colors.blue,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => sendfeedback())),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(Icons.feedback),
        label: Text('Send Feedback'),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
      onTap: onTap,
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
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

  Widget _buildActivityItem(IconData icon, String title, String subtitle, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }
}
















// import 'package:flutter/material.dart';
// import 'package:wate_management/profile_edit.dart';
// import 'package:wate_management/publicoffence.dart';
// import 'package:wate_management/send%20complaint.dart';
// import 'package:wate_management/sendfeedback.dart';
// import 'package:wate_management/view%20cart%20and%20pay.dart';
// import 'package:wate_management/view%20profile.dart';
// import 'package:wate_management/view%20status.dart';
// import 'package:wate_management/view%20type.dart';
// import 'package:wate_management/view_public_offence.dart';
// import 'package:wate_management/viewproduct.dart';
// import 'package:wate_management/viewreply.dart';
// import 'package:wate_management/viewrequeststatus.dart';
// import 'package:wate_management/viewrewards.dart';
// import 'package:wate_management/viewwastetype.dart';
//
//
// import 'change password user.dart';
// void main(){
//   runApp(home());
// }
//
// class home extends StatelessWidget {
//   const home({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: homesub(),);
//   }
// }
// class homesub extends StatefulWidget {
//   const homesub({Key? key}) : super(key: key);
//
//   @override
//   State<homesub> createState() => _homesubState();
// }
//
// class _homesubState extends State<homesub> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home"),),
//       drawer: Drawer(
//         child: Column(
//           children: [
//             ListTile(title: Text("Home"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//             },),
//
//             ListTile(title: Text("Complaint"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewreply()));
//
//             },),
//             ListTile(title: Text("Public offence"),leading: Icon(Icons.home),onTap: (){
//               // Navigator.push(context, MaterialPageRoute(builder: (context)=>publicoffence()));
//               Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPublicOffence()));
//
//             },),
//             ListTile(title: Text("Send feedback"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>sendfeedback()));
//
//             },),
//             ListTile(title: Text("view waste type"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewwastetype()));
//
//             },),
//             ListTile(title: Text("view request status&rewards"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewstatus1()));
//
//             },),
//             ListTile(title: Text("view product"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewproduct()));
//
//             },),
//             ListTile(title: Text("view cart"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewcartandpay()));
//
//             },),
//             ListTile(title: Text("view status&payment"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewStatusApp()));
//
//             },),
//             ListTile(title: Text("Change password"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>changepassword()));
//
//             },),
//             ListTile(title: Text("view reward"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewrewards()));
//
//             },),
//             ListTile(title: Text("view profile"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewprofile()));
//
//             },),
//
//
//
//
//           ],
//         ),
//       ),
//       body: Text("Welcome"),
//     );
//   }
// }
