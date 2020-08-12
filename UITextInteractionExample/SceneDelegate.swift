// Licensed under the MIT License.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
		
		let window = UIWindow(windowScene: scene)
		window.backgroundColor = .systemBlue
		window.rootViewController = ViewController()
		self.window = window
		window.makeKeyAndVisible()
	}

}

