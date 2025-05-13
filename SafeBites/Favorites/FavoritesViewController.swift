import UIKit

protocol FavoritesViewProtocol: AnyObject {
    func didFetchFavorites(_ products: [Product])
    func didAddProductToFavorites(_ product: Product)
    func didRemoveProductFromFavorites(_ product: Product)
    func showFavoritesErrorAlert(with message: String)
}

final class FavoritesViewController: UIViewController {
    private var presenter: FavoritesPresenter!
    
    private var products: [Product] = []
    
    // MARK: - UI elements
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .sbBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .sbSilver
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "Вы еще не добавили продукты в избранное"
        label.textColor = .sbSilver
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FavoritesPresenter(favoritesVC: self)
        presenter?.getFavorites()
        
        setupUI()
        setupBackwardButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: - Private functions
    
    private func setupUI() {
        view.backgroundColor = .sbBackground

        view.addSubview(collectionView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private func setupBackwardButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_button_black")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_button_black")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .sbSilver
    }
}

// MARK: - FavoritesViewProtocol

extension FavoritesViewController: FavoritesViewProtocol {
    func didFetchFavorites(_ products: [Product]) {
        self.products = products
        collectionView.reloadData()
        emptyStateView.isHidden = !products.isEmpty
        print("[INFO] Favorites fetched, data reloaded, empty state hidden: \(products.isEmpty)")
    }
    
    func didAddProductToFavorites(_ product: Product) {
        if !products.contains(where: { $0.barcode == product.barcode }) {
            products.append(product)
            collectionView.reloadData()
        }
    }
    
    func didRemoveProductFromFavorites(_ product: Product) {
        if let index = products.firstIndex(where: { $0.barcode == product.barcode }) {
            products.remove(at: index)
            collectionView.reloadData()
            emptyStateView.isHidden = !products.isEmpty
        }
    }
    
    func showFavoritesErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CollectionView DataSource
extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        cell.configure(with: products[indexPath.item])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        let productVC = ProductViewController()
        productVC.barcode = product.barcode
        navigationController?.pushViewController(productVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12) / 2
        return CGSize(width: width, height: 180)
    }
}

extension FavoritesViewController: ProductCellDelegate {
    func didTapFavoriteButton(on cell: ProductCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let product = presenter.favoriteProducts[indexPath.item]
        presenter.deleteFromFavorites(product)
    }
}
