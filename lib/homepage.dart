import 'package:flutter/material.dart';
import 'patient/login&signUP/login.dart'; // Import the LoginSignupPage
import 'Doctors/DoctorLoginPage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/back.jpg'), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Transparent overlay
          Container(
            color:
            Colors.black.withOpacity(0.1), // Semi-transparent black overlay
          ),
          // SafeArea for content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular logo image at the top of the column
                const Center(
                  child: CircleAvatar(
                    radius: 70, // Adjust size as needed
                    backgroundImage: AssetImage(
                        'images/logo.png'), // Replace with your logo image path
                  ),
                ),
                const SizedBox(height: 20), // Spacing below the logo
                const SizedBox(height: 20),
                SlideTransition(
                  position: _offsetAnimation!,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.lightBlue,
                            Colors.lightGreen
                          ], // Use light blue and light green for the gradient
                          tileMode: TileMode.clamp,
                        ).createShader(bounds),
                        child: const Text(
                          'Welcome to HealUp',
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'Hello Valentina',
                            fontWeight: FontWeight
                                .bold, // Optional: to make the text bold
                            color: Colors
                                .lightBlue, // Use light blue and light green for the gradient
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 8), // Space between the two sentences
                      Text(
                        'Please select your role to get started.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SlideTransition(
                  position: _offsetAnimation!,
                  child: buildSignUpButton(
                      context, 'Doctor', Icons.local_hospital),
                ),
                SlideTransition(
                  position: _offsetAnimation!,
                  child: buildSignUpButton(context, 'Patient', Icons.person),
                ),
                SlideTransition(
                  position: _offsetAnimation!,
                  child: buildSignUpButton(
                      context, 'Management', Icons.admin_panel_settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSignUpButton(BuildContext context, String role, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        onPressed: () {
          if (role == 'Patient') {
            Navigator.of(context).pushReplacementNamed("login");

          }  else if (role == 'Doctor') {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DoctorLoginPage(), // Navigates to DoctorLoginPage
            ));}

        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          "I'm $role",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff6be4d7),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                30), // Increased borderRadius for a rounded shape
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'patient/login&signUP/login.dart'; // Import the LoginSignupPage
// import 'Doctors/DoctorLoginPage.dart';
//
// class WelcomePage extends StatefulWidget {
//   const WelcomePage({super.key});
//
//   @override
//   _WelcomePageState createState() => _WelcomePageState();
// }
//
// class _WelcomePageState extends State<WelcomePage>
//     with TickerProviderStateMixin {
//   AnimationController? _controller;
//   Animation<Offset>? _offsetAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     )..forward();
//
//     _offsetAnimation = Tween<Offset>(
//       begin: const Offset(0.0, 1.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller!,
//       curve: Curves.easeInOut,
//     ));
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(
//                     'images/back.jpg'), // Replace with your background image path
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Transparent overlay
//           Container(
//             color:
//                 Colors.black.withOpacity(0.1), // Semi-transparent black overlay
//           ),
//           // SafeArea for content
//           SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Circular logo image at the top of the column
//                 const Center(
//                   child: CircleAvatar(
//                     radius: 70, // Adjust size as needed
//                     backgroundImage: AssetImage(
//                         'images/logo.png'), // Replace with your logo image path
//                   ),
//                 ),
//                 const SizedBox(height: 20), // Spacing below the logo
//                 const SizedBox(height: 20),
//                 SlideTransition(
//                   position: _offsetAnimation!,
//                   child: Column(
//                     children: [
//                       ShaderMask(
//                         shaderCallback: (bounds) => const LinearGradient(
//                           colors: [
//                             Colors.lightBlue,
//                             Colors.lightGreen
//                           ], // Use light blue and light green for the gradient
//                           tileMode: TileMode.clamp,
//                         ).createShader(bounds),
//                         child: const Text(
//                           'Welcome to HealUp',
//                           style: TextStyle(
//                             fontSize: 40,
//                             fontFamily: 'Hello Valentina',
//                             fontWeight: FontWeight
//                                 .bold, // Optional: to make the text bold
//                             color: Colors
//                                 .lightBlue, // Use light blue and light green for the gradient
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                           height: 8), // Space between the two sentences
//                       Text(
//                         'Please select your role to get started.',
//                         style: TextStyle(fontSize: 18, color: Colors.grey[700]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 SlideTransition(
//                   position: _offsetAnimation!,
//                   child: buildSignUpButton(
//                       context, 'Doctor', Icons.local_hospital),
//                 ),
//                 SlideTransition(
//                   position: _offsetAnimation!,
//                   child: buildSignUpButton(context, 'Patient', Icons.person),
//                 ),
//                 SlideTransition(
//                   position: _offsetAnimation!,
//                   child: buildSignUpButton(
//                       context, 'Management', Icons.admin_panel_settings),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildSignUpButton(BuildContext context, String role, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: ElevatedButton.icon(
//         onPressed: () {
//           if (role == 'Patient') {
//             Navigator.of(context).pushReplacementNamed("login");
//
//           }  else if (role == 'Doctor') {
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => DoctorLoginPage(), // Navigates to DoctorLoginPage
//             ));}
//
//         },
//         icon: Icon(icon, color: Colors.white),
//         label: Text(
//           "I'm $role",
//           style: const TextStyle(
//             fontSize: 18,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xff6be4d7),
//           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(
//                 30), // Increased borderRadius for a rounded shape
//           ),
//         ),
//       ),
//     );
//   }
// }
