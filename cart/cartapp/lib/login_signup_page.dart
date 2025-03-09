import 'package:firebase_auth/firebase_auth.dart'; import 'package:flutter/material.dart'; 
import 'package:google_sign_in/google_sign_in.dart'; import 'home_screen.dart'; 
import 'package:fluttertoast/fluttertoast.dart'; 
 
class LoginSignupScreen extends StatefulWidget {   const LoginSignupScreen({super.key}); 
 
  @override 
  _LoginSignupScreenState createState() => _LoginSignupScreenState(); } 
 
class _LoginSignupScreenState extends State<LoginSignupScreen> { 
  final _emailController = TextEditingController();   final _passwordController = TextEditingController();   bool isSignUp = false; 
  bool isLoading = false; // Add loading state 
login_signup_page.dart 
 
 
final FirebaseAuth _auth = FirebaseAuth.instance; 
// Handle Google Sign In 
Future<User?> signInWithGoogle() async {   setState(() { 
      isLoading = true; // Show loading indicator 
    }); 
 
    final GoogleSignIn googleSignIn = GoogleSignIn(); 
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();     if (googleUser == null) { 
      setState(() { 
        isLoading = false; // Hide loading indicator 
      }); 
      return null; 
    } 
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication; 
 
    final OAuthCredential credential = GoogleAuthProvider.credential(       accessToken: googleAuth.accessToken,       idToken: googleAuth.idToken, 
    ); 
 
    final UserCredential userCredential = await _auth.signInWithCredential(credential); 
 
    setState(() { 
      isLoading = false; // Hide loading indicator 
    }); 
 
    return userCredential.user; 
  } 
 
  // Show alert dialog for errors   void showAlert(String message) {     showDialog(       context: context, 
      builder: (context) => AlertDialog( 
        title: const Text('Error'),         content: Text(message), 
        actions: [ 
          TextButton(            onPressed: () { 
             Navigator.pop(context); 
        }, 
      child: const Text('OK'), 
    ), 
], 
), 
); 
} 
// Show Toast message for authentication failure   void showToast(String message) { 
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT); 
  } 
 
  // Email validation 
  bool isValidEmail(String email) { 
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');     return regex.hasMatch(email); 
  } 
 
  // Handle email/password sign-up 
  Future<void> signUpWithEmailPassword() async {     setState(() { 
      isLoading = true; // Show loading indicator 
    }); 
 
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {       showAlert('Please fill in both email and password');       setState(() { 
        isLoading = false; // Hide loading indicator 
      });       return; 
    } 
 
    if (!isValidEmail(_emailController.text)) {       showAlert('Please enter a valid email address');       setState(() { 
        isLoading = false; // Hide loading indicator 
      });       return; 
    } 
 
    if (_passwordController.text.length < 6) {       showAlert('Password must be at least 6 characters');       setState(() {         isLoading = false; // Hide loading indicator 
     });      return;   } try { await _auth.createUserWithEmailAndPassword(   email: _emailController.text.trim(),   password: _passwordController.text.trim(), 
  );     setState(() { 
    isLoading = false; // Hide loading indicator 
      }); 
      Navigator.pushReplacement( 
        context, 
        MaterialPageRoute(builder: (context) => const HomeScreen()), 
      ); 
    } on FirebaseAuthException catch (e) {       setState(() { 
        isLoading = false; // Hide loading indicator 
      }); 
      if (e.code == 'weak-password') {         showToast('The password is too weak.');       } else if (e.code == 'email-already-in-use') { 
        showToast('An account already exists for that email.'); 
      } else { 
        showToast('Authentication failed! Please try again.'); 
      } 
    } catch (e) {       setState(() { 
        isLoading = false; // Hide loading indicator 
      }); 
      showToast('Something went wrong. Please try again.'); 
    } 
  } 
 
  // Handle email/password login 
  Future<void> logInWithEmailPassword() async {     setState(() { 
      isLoading = true; // Show loading indicator 
    }); 
 
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {       showAlert('Please fill in both email and password');       setState(() { 
        isLoading = false; // Hide loading indicator 
      });       return; } 
if (!isValidEmail(_emailController.text)) { 
showAlert('Please enter a valid email address'); setState(() { 
isLoading = false; // Hide loading indicator 
}); return; } 
if (_passwordController.text.length < 6) { 
      showAlert('Password must be at least 6 characters');       setState(() { 
        isLoading = false; // Hide loading indicator 
      });       return; 
    } 
     try { 
      await _auth.signInWithEmailAndPassword(         email: _emailController.text.trim(),         password: _passwordController.text.trim(), 
      );       setState(() { 
        isLoading = false; // Hide loading indicator 
      }); 
      Navigator.pushReplacement( 
        context, 
        MaterialPageRoute(builder: (context) => const HomeScreen()), 
      ); 
    } on FirebaseAuthException catch (e) {       setState(() { 
        isLoading = false; // Hide loading indicator 
      }); 
      if (e.code == 'user-not-found') { 
        showToast('No user found for that email.');       } else if (e.code == 'wrong-password') {         showToast('Incorrect password.'); 
      } else { 
        showToast('Invalid email or password. Please try again.'); 
      } 
    } catch (e) {       setState(() { 
        isLoading = false; // Hide loading indicator 
      }); 
      showToast('Something went wrong. Please try again.'); 
    } 
} 
@override 
Widget build(BuildContext context) { return Scaffold( 
appBar: AppBar(   backgroundColor: Colors.deepPurple,   title: const Text('E-Commerce App'), 
    centerTitle: true, 
      elevation: 0, 
  ), 
      body: isLoading           ? Center( 
              child: CircularProgressIndicator( 
                color: Colors.deepPurple, // Customize the color if needed 
              ), 
            ) 
          : SingleChildScrollView(               padding: const EdgeInsets.all(16.0),               child: Column(                 children: <Widget>[                   // Branding Image or Logo 
                  Center( 
                    child: Image.asset( 
                      'assets/images/logo.png', // Replace with your logo                       height: 250,                       width: 350, 
                    ), 
                  ), 
                  const SizedBox(height: 20), 
 
                  // AnimatedSwitcher for flip animation between Login and Signup                   AnimatedSwitcher( 
                    duration: const Duration(milliseconds: 600),                     transitionBuilder: (Widget child, Animation<double> animation) {                       final rotate = Tween(begin: 0.0, end: 1.0).animate(animation);                       return RotationTransition( 
                        turns: rotate,                         child: child, 
                      ); 
                    }, 
                    child: isSignUp ? buildSignUpForm() : buildLoginForm(), 
                  ), 
                  const SizedBox(height: 20), 
 
                  // Toggle between Sign Up and Login with more spacing 
                  TextButton(         onPressed: () { 
  	          setState(() {             isSignUp = !isSignUp; // Toggle between SignUp and Login 
          }); 
        }, 
            child: Text( 
                isSignUp 
                    ? 'Already have an account? Login' 
                      : 'Don\'t have an account? Sign Up',                     style: const TextStyle(fontSize: 16), 
                ), 
                  ), 
                  const SizedBox(height: 20), 
 
                  // Google Sign-In Button                   ElevatedButton.icon(                     onPressed: () async { 
                      User? user = await signInWithGoogle(); 
                      if (user != null) { 
                        Navigator.pushReplacement(                           context, 
                          MaterialPageRoute(builder: (context) => const HomeScreen()), 
                        ); 
                      } else { 
                        showToast('Google sign-in failed.'); 
                      } 
                    }, 
                    style: ElevatedButton.styleFrom(                       backgroundColor: Colors.deepPurple, // Google blue color                       padding: const EdgeInsets.symmetric(vertical: 15),                       minimumSize: const Size(double.infinity, 50),                       shape: RoundedRectangleBorder(                         borderRadius: BorderRadius.circular(15), 
                      ), 
                    ), 
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),                     label: const Text(                       'Continue with Google', 
                      style: TextStyle(fontSize: 18, color: Colors.white), 
                    ), 
                  ), 
                  const SizedBox(height: 30), 
 
                  // Optional: Add Footer or Disclaimer with more padding                   const Divider(),                   const Text( 
                    'By signing up, you agree to our Terms and Conditions',           style: TextStyle(fontSize: 12, color: Colors.grey), 
  	      ), 
  	    ], 
  	  ), ), 
 
);
} 
Widget buildLoginForm() {   return Column(     key: const ValueKey('login'), 
      children: [         TextField(           controller: _emailController,           decoration: InputDecoration( 
            prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),             labelText: 'Email Address',             hintText: 'Enter your email',             border: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(15), 
            ),             filled: true, 
            fillColor: Colors.white, 
          ), 
        ), 
        const SizedBox(height: 15), 
 
        TextField( 
          controller: _passwordController,           obscureText: true,           decoration: InputDecoration( 
            prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),             labelText: 'Password',             hintText: 'Enter your password',             border: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(15), 
            ),             filled: true, 
            fillColor: Colors.white, 
          ), 
        ), 
        const SizedBox(height: 25), 
 
        ElevatedButton(           style: ElevatedButton.styleFrom(             backgroundColor: Colors.deepPurple, 
            foregroundColor: Colors.white, shape: RoundedRectangleBorder( 
	  	  borderRadius: BorderRadius.circular(15), 
), 
padding: const EdgeInsets.symmetric(vertical: 15), minimumSize: const Size(double.infinity, 50), 
    ), 
      onPressed: logInWithEmailPassword, 
      child: const Text( 
        'Login',           style: TextStyle(fontSize: 18), 
        ), 
        ), 
      ], 
    ); 
  } 
 
  Widget buildSignUpForm() {     return Column( 
      key: const ValueKey('signup'), 
      children: [         TextField(           controller: _emailController,           decoration: InputDecoration( 
            prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),             labelText: 'Email Address',             hintText: 'Enter your email',             border: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(15), 
            ),             filled: true, 
            fillColor: Colors.white, 
          ), 
        ), 
        const SizedBox(height: 15), 
 
        TextField( 
          controller: _passwordController,           obscureText: true,           decoration: InputDecoration( 
            prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),             labelText: 'Password',             hintText: 'Enter your password',             border: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(15), 
            ),             filled: true, 
            fillColor: Colors.white, 
  ), 
), 
const SizedBox(height: 25), 
ElevatedButton( 
          style: ElevatedButton.styleFrom(             backgroundColor: Colors.deepPurple,             foregroundColor: Colors.white,             shape: RoundedRectangleBorder( 
              borderRadius: BorderRadius.circular(15), 
            ), 
            padding: const EdgeInsets.symmetric(vertical: 15),             minimumSize: const Size(double.infinity, 50), 
          ), 
          onPressed: signUpWithEmailPassword,           child: const Text( 
            'Sign Up', 
            style: TextStyle(fontSize: 18), 
          ), 
        ), 
      ], 
    ); 
  } 
} 
 
 
