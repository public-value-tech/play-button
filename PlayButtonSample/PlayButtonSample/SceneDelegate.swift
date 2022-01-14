import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.windowScene = windowScene
    
    let tabController = UITabBarController()
    tabController.tabBar.backgroundColor = .white
    
    let uikitCode = UIKitViewController()
    let uikitStoryboard = UIStoryboard(name: "UIKitStoryboard", bundle: nil).instantiateInitialViewController()!
    let swiftUIHostingVC = UIHostingController(rootView: SwiftUIWrapper())
    swiftUIHostingVC.tabBarItem = UITabBarItem(title: "SwiftUI", image: UIImage(systemName: "1.circle"), tag: 3)
    
    tabController.setViewControllers([swiftUIHostingVC, uikitCode, uikitStoryboard], animated: false)
    
    window?.rootViewController = tabController
    window?.makeKeyAndVisible()
  }
}
