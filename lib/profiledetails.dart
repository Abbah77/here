import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey[700],
            size: 18,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Details',
                      style: GoogleFonts.lato(
                        color: Colors.grey[800],
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildEditButton(context),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      Container(
                        height: 108,
                        width: 101,
                        margin: const EdgeInsets.only(top: 25, bottom: 5),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user?.profileImage ?? 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
                          ),
                          onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 50),
                        ),
                      ),
                      Positioned(
                        bottom: 54,
                        right: 20,
                        child: Material(
                          color: Colors.blue[900],
                          elevation: 10,
                          shape: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.zoom_out_map,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Profile Info
                _buildInfoRow('Name', user?.name ?? 'Scott Hamilton'),
                const SizedBox(height: 20),
                _buildInfoRow('Role', 'Social Engineer Of Google'),
                const SizedBox(height: 20),
                _buildInfoRow('Company', 'Google Co Ltd'),
                const SizedBox(height: 20),
                _buildInfoRow('Location', 'Delhi, India'),
                
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 30),
                
                // Private Information
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Private Information',
                      style: GoogleFonts.lato(
                        color: Colors.grey[700],
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Contact Info
                _buildContactRow(
                  Icons.mail,
                  user?.email ?? 'mathewsteven92@gmail.com',
                ),
                const SizedBox(height: 20),
                _buildContactRow(
                  Icons.phone,
                  '+91 - 9560419114',
                ),
                const SizedBox(height: 20),
                _buildContactRow(
                  Icons.home_outlined,
                  'RZ- 5167, Hari Nagar, New Delhi',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit profile - Coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(40),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.white, size: 16),
                SizedBox(width: 3),
                Text(
                  'Edit',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.lato(
              color: Colors.grey[900],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lato(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Icon(icon, color: Colors.grey[500]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}