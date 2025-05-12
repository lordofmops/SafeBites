import UIKit

final class ProductCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .sbWhite
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .sbWhite
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .sbWhite

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with product: Product) {
        if let url = URL(string: product.imageUrl ?? "") {
            imageView.kf.setImage(with: url)
        }
        titleLabel.text = product.name ?? "Без названия"
        subtitleLabel.text = "\(product.brand ?? "")"
    }
}
