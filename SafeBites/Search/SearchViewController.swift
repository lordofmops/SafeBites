import UIKit

protocol SearchViewProtocol: AnyObject {
    func showProducts(_ products: [Product])
    func showError(_ message: String)
    func updatePaginationButtons(totalPages: Int)
}

final class SearchViewController: UIViewController {

    private var presenter: SearchPresenterProtocol?

    private var products: [Product] = []
    private var currentFilters: SearchFilters?
    private var currentQuery: String?
    
    private var currentPage: Int = 1
    private var totalPages: Int = 10

    // MARK: - UI

    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название продукта"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .sbWhite
        button.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        button.tintColor = .sbWhite
        button.addTarget(self, action: #selector(didTapFilter), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
    
    private lazy var paginationStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = SearchPresenter(view: self)
        presenter?.searchProducts(query: nil, filters: nil, page: 1)
        
        setupUI()
        setupBackwardButton()
    }

    // MARK: - Layout

    private func setupUI() {
        view.backgroundColor = .sbBackground

        let searchStack = UIStackView(arrangedSubviews: [searchTextField, searchButton, filterButton])
        searchStack.axis = .horizontal
        searchStack.spacing = 8
        searchStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchStack)
        view.addSubview(paginationStack)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            searchStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            searchButton.widthAnchor.constraint(equalToConstant: 44),
            filterButton.widthAnchor.constraint(equalToConstant: 44),
            
            paginationStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            paginationStack.heightAnchor.constraint(equalToConstant: 20),
            paginationStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: paginationStack.topAnchor, constant: -8),
        ])
    }

    // MARK: - Actions

    @objc
    private func didTapFilter() {
        let nav = UINavigationController(rootViewController: FilterModalViewController())
        if let filterVC = nav.viewControllers.first as? FilterModalViewController {
            filterVC.delegate = self
            filterVC.initialFilters = currentFilters
        }
        present(nav, animated: true)
    }

    @objc
    private func didTapSearch() {
        guard let query = searchTextField.text, currentQuery != query else { return }
        self.currentQuery = query
        presenter?.searchProducts(query: query, filters: currentFilters, page: 1)
    }
    
    @objc
    private func didTapPageButton(_ sender: UIButton) {
        let selectedPage = sender.tag
        currentPage = selectedPage
        presenter?.searchProducts(query: searchTextField.text, filters: currentFilters, page: selectedPage)
    }
    
    private func setupBackwardButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_button_black")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_button_black")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .sbSilver
    }
}

// MARK: - CollectionView DataSource

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }
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

extension SearchViewController: SearchViewProtocol {
    func showProducts(_ products: [Product]) {
        print("[INFO] Loaded \(products.count) products")
        self.products = products
        collectionView.reloadData()
        
        DispatchQueue.main.async {
            if !products.isEmpty {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    func updatePaginationButtons(totalPages: Int) {
        paginationStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if currentPage > 2 {
            let backButton = makePageButton(title: "←", tag: currentPage - 1)
            backButton.setTitleColor(.sbWhite, for: .normal)
            paginationStack.addArrangedSubview(backButton)
        }

        let visiblePages = max(1, totalPages)
        let start = max(currentPage - 2, 1)
        let end = min(currentPage + 2, visiblePages)

        for page in start...end {
            let button = makePageButton(title: "\(page)", tag: page)
            if page == currentPage {
                button.backgroundColor = .sbSilver
                button.setTitleColor(.sbGray, for: .normal)
            } else {
                button.setTitleColor(.sbWhite, for: .normal)
            }
            paginationStack.addArrangedSubview(button)
        }

        if currentPage + 1 < totalPages {
            let nextButton = makePageButton(title: "→", tag: currentPage + 1)
            nextButton.setTitleColor(.sbWhite, for: .normal)
            paginationStack.addArrangedSubview(nextButton)
        }
    }


    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    private func makePageButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        button.addTarget(self, action: #selector(didTapPageButton(_:)), for: .touchUpInside)
        return button
    }

}

extension SearchViewController: FilterSelectionDelegate {
    func didApplyFilters(_ filters: SearchFilters) {
        if currentFilters == filters { return }
        
        self.currentFilters = filters
        presenter?.searchProducts(query: currentQuery, filters: filters, page: 1)
    }
}
