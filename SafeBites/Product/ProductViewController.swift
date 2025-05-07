import UIKit
import Kingfisher

protocol ProductViewProtocol: AnyObject {
    func didFetchProductInfo(_ product: Product)
    func showErrorAlert(message: String)
}

final class ProductViewController: UIViewController {
    var barcode: String?
    {
        didSet {
            guard let barcode else { return }
            self.presenter = ProductPresenter(productVC: self)
            presenter?.getProductInfo(with: barcode)
        }
    }
    
    private var presenter: ProductPresenterProtocol?
    
    // MARK: - UI elements
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.backgroundColor = .sbBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.backgroundColor = .sbBackground
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemRed
        button.setTitle("Добавить в избранное", for: .normal)
        button.setTitleColor(.sbRed, for: .normal)
        button.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        return button
    }()
    
    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.image = UIImage(named: "image_placeholder")
        
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Неизвестное название"
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .sbWhite
        return label
    }()
    
    private lazy var brandAndQuantityLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .sbGray.withAlphaComponent(0.2)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.text = "Бренд неизвестен"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .sbWhite
        return label
    }()
    
    private lazy var restrictionReportLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Невозможно составить персональный отчет"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .sbWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var restrictionReportView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .sbRed
        
        let label = restrictionReportLabel
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .sbBackground
        setupLayout()
    }
    
    // MARK: - Layout
        
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
        
        contentView.addArrangedSubview(nameLabel)
        contentView.addArrangedSubview(brandAndQuantityLabel)
        contentView.addArrangedSubview(productImageView)
        contentView.addArrangedSubview(favoriteButton)
        contentView.addArrangedSubview(restrictionReportView)
    }
    
    // MARK: - Actions
    
    @objc private func didTapFavorite() {
        // TODO: избранное
    }
    
    // MARK: - Helpers
    
    private func makeInfoBlock(title: String, value: String?) -> UIView {
        let view = UIView()
        view.backgroundColor = .sbGray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .sbWhite

        let valueLabel = UILabel()
        valueLabel.numberOfLines = 0
        valueLabel.text = value ?? "Нет данных"
        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.textColor = .sbWhite

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        return view
    }

    private func nutrientsDescription(for nutriments: Nutriments) -> String {
        var returnString = ""
        if let energy = nutriments.energy {
            returnString += "Энергетическая ценность: \(energy) ккал"
        }
        if let fat = nutriments.fat {
            returnString += "\nЖиры: \(fat) г"
        }
        if let saturatedFat = nutriments.saturatedFat {
            returnString += "\nНасыщ. жиры: \(saturatedFat) г"
        }
        if let carbohydrates = nutriments.carbohydrates {
            returnString += "\nУглеводы: \(carbohydrates) г"
        }
        if let sugars = nutriments.sugars {
            returnString += "\nСахара: \(sugars) г"
        }
        if let fiber = nutriments.fiber {
            returnString += "\nКлетчатка: \(fiber) г"
        }
        if let proteins = nutriments.proteins {
            returnString += "\nБелки: \(proteins) г"
        }
        if let salt = nutriments.salt {
            returnString += "\nСоль: \(salt) г"
        }
        
        return returnString
        
    }

    private func formattedStores(_ stores: String) -> String {
        return stores.split(separator: ",").map { "\($0) — найти в доставке" }.joined(separator: "\n")
    }
}

extension ProductViewController: ProductViewProtocol {
    func didFetchProductInfo(_ product: Product) {
        if let isFavorite = product.isFavorite {
            let imageName = isFavorite ? "heart.fill" : "heart"
            self.favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
        
        if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
            let processor = RoundCornerImageProcessor(cornerRadius: 20)
            productImageView.kf.setImage(with: url,
                                         placeholder: UIImage(named: "placeholder"),
                                         options: [
                                            .processor(processor)
                                         ])
        } else {
            productImageView.image = UIImage(named: "placeholder")
        }
        
        if let name = product.name {
            nameLabel.text = "\(name)"
        }
        
        var brandAndQuantityLabelText = ""
        if let brand = product.brand {
            brandAndQuantityLabelText += "Бренд: \(brand)"
        }
        if let quantity = product.quantity {
            brandAndQuantityLabelText += "\n\(quantity)"
        }
        if !brandAndQuantityLabelText.isEmpty {
            brandAndQuantityLabel.text = brandAndQuantityLabelText
        }
        
        if let doesMatchRestrictions = product.doesMatchRestrictions {
            restrictionReportView.backgroundColor = doesMatchRestrictions ? .sbGreen : .sbRed
            restrictionReportLabel.text = product.unmatchedTags == nil || product.unmatchedTags!.isEmpty
                ? "Продукт подходит по всем вашим ограничениям"
                : "Продукт не соответствует следующим ограничениям:\n- " + product.unmatchedTags!.joined(separator: "\n- ")
        }
        
        if let ingredientsText = product.ingredientsText {
            let ingredientsLabel = makeInfoBlock(title: "Состав", value: ingredientsText)
            contentView.addArrangedSubview(ingredientsLabel)
        }
        
        let nutrients = product.nutrients
        let nutrientsDesc = nutrientsDescription(for: nutrients)
        if !nutrientsDesc.isEmpty {
            let nutrientsLabel = makeInfoBlock(title: "Нутриенты", value: nutrientsDescription(for: nutrients))
            contentView.addArrangedSubview(nutrientsLabel)
        }
        
        if let allergens = product.allergens {
            let allergensLabel = makeInfoBlock(title: "Аллергены", value: allergens.joined(separator: ", "))
            contentView.addArrangedSubview(allergensLabel)
        }
        
        if let stores = product.stores, !stores.isEmpty {
            let storesLabel = makeInfoBlock(title: "Магазины", value: formattedStores(stores))
            contentView.addArrangedSubview(storesLabel)
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка :(", message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "Попробовать еще раз", style: .default)))
        present(alert, animated: true)
    }
}
