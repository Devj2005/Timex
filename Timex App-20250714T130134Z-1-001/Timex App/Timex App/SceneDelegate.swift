import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(windowScene: windowScene)

        let isRegistered = UserDefaults.standard.bool(forKey: "isRegistered")
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")

        if isRegistered {
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarVC") as? UITabBarController {
                window?.rootViewController = tabBarController
            } else {
                fatalError("❌ Error: MainTabBarController not found in storyboard! Check Storyboard ID.")
            }
        } else {
            if let registrationVC = storyboard.instantiateViewController(withIdentifier: "UserRegistrationVC") as? UserRegistrationVC {
                window?.rootViewController = registrationVC
            }
        }

        window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        window?.makeKeyAndVisible()
    }
}
