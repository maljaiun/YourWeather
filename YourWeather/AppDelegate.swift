
import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
   var window: UIWindow?
   var deviceOrientation = UIInterfaceOrientationMask.portrait
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
      FirebaseApp.configure()
      return true
   }
   
   func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
      return deviceOrientation
   }
   
}

