import UIKit

protocol ProductCellDelegate: AnyObject {
    func didTapFavoriteButton(on cell: ProductCell)
}

final class ProductCell: UICollectionViewCell {
    weak var delegate: ProductCellDelegate?
    
    private let imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .sbWhite
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .sbWhite
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .sbWhite
        return label
    }()
    
    private let favoriteButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .sbRed
        button.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 42),
            favoriteButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    func configure(with product: Product) {
        if let url = URL(string: product.imageUrl ?? "") {
            imageView.kf.setImage(with: url)
        }
        titleLabel.text = product.name ?? "Без названия"
        subtitleLabel.text = "\(product.brand ?? "")"
    }
    
    @objc
    private func didTapFavoriteButton() {
        delegate?.didTapFavoriteButton(on: self)
    }
}
