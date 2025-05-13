import UIKit
 
final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
            
        let scanningViewController = ScanningViewController()
        let scanningNavigationController = UINavigationController(rootViewController: scanningViewController)
        scanningViewController.tabBarItem = UITabBarItem(
            title: "Сканер",
            image: UIImage(systemName: "barcode.viewfinder"),
            selectedImage: UIImage(systemName: "barcode.viewfinder")
        )
        
        let searchViewController = SearchViewController()
        let searchNavigationController = UINavigationController(rootViewController: searchViewController)
        searchViewController.tabBarItem = UITabBarItem(
            title: "Поиск",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        
        let favoritesViewController = FavoritesViewController()
        let favoritesNavigationController = UINavigationController(rootViewController: favoritesViewController)
        favoritesViewController.tabBarItem = UITabBarItem(
            title: "Избранное",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart")
        )
        
        let profileViewController = ProfileViewController()
        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
        profileViewController.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle")
        )
           
        self.viewControllers = [scanningNavigationController, searchNavigationController, favoritesNavigationController, profileNavigationController]
    }
    
    private func setupUI() {
        self.tabBar.backgroundColor = .sbBackground
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = UIColor.sbGray.cgColor
        self.tabBar.tintColor = .sbWhite
        self.tabBar.unselectedItemTintColor = .sbSilver
    }
}
