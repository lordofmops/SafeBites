import UIKit

protocol ProfileViewProtocol: AnyObject {
    func didFetchProfile(user: User, restrictions: [Restriction])
    func didUpdateRestrictions(_ restrictions: [Restriction])
    func didDeleteProfile()
    func updateUsername(updatedUsername: String)
    func showProfileErrorAlert(message: String)
    func showLogoutAlert()
}

final class ProfileViewController: UIViewController {
    private var presenter: ProfilePresenter!
    private var restrictions: [Restriction] = []
    private var allergens: [Restriction] = []
    private var diets: [Restriction] = []
    
    private lazy var avatarPlaceholderImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .sbWhite.withAlphaComponent(0.4)
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    private lazy var editNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Изменить имя", for: .normal)
        button.setTitleColor(.sbWhite, for: .normal)
        button.addTarget(self, action: #selector(editName), for: .touchUpInside)
        return button
    }()

    private lazy var nameLabel = makeLabel(fontSize: 18, weight: .bold, color: .sbWhite)
    private lazy var emailLabel = makeLabel(fontSize: 18, weight: .light, color: .sbWhite)
    
    private lazy var allergensValueLabel = makeLabel(fontSize: 14, weight: .light, color: .sbWhite)
    private lazy var dietsValueLabel = makeLabel(fontSize: 14, weight: .light, color: .sbWhite)
    
    private lazy var allergensRow = makeRestrictionRow(title: "Аллергены", valueLabel: allergensValueLabel, action: #selector(editAllergens))
    private lazy var dietsRow = makeRestrictionRow(title: "Типы питания", valueLabel: dietsValueLabel, action: #selector(editDiets))

    private lazy var logoutButton = makeActionButton(title: "Выйти", action: #selector(logout), color: .sbSilver)
    private lazy var deleteButton = makeActionButton(title: "Удалить аккаунт", action: #selector(deleteAccount), color: .sbRed)

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfilePresenter(profileVC: self)
        view.backgroundColor = .sbBackground
        layoutUI()
        presenter.fetchProfile()
    }

    private func layoutUI() {
        let nameRow = UIStackView(arrangedSubviews: [nameLabel, editNameButton])
        nameRow.axis = .horizontal
        nameRow.distribution = .equalSpacing
        
        let stack = UIStackView(arrangedSubviews: [
            nameRow, emailLabel, allergensRow, dietsRow, logoutButton, deleteButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarPlaceholderImageView)
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            avatarPlaceholderImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            avatarPlaceholderImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            stack.topAnchor.constraint(equalTo: avatarPlaceholderImageView.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func makeLabel(fontSize: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.textColor = color
        return label
    }

    private func makeActionButton(title: String, action: Selector, color: UIColor = .systemBlue) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func makeRestrictionRow(title: String, valueLabel: UILabel, action: Selector) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .sbWhite

        let editButton = UIButton(type: .system)
        editButton.setTitle("Изменить", for: .normal)
        editButton.setTitleColor(.sbWhite, for: .normal)
        editButton.addTarget(self, action: action, for: .touchUpInside)

        let topRow = UIStackView(arrangedSubviews: [titleLabel, editButton])
        topRow.axis = .horizontal
        topRow.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [topRow, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4

        return stack
    }

    private func displayRestrictions(_ restrictions: [Restriction]) {
        print("[INFO] User restrictions: \(restrictions)")
        self.allergens = restrictions.filter { $0.type == "allergen" }
        self.diets = restrictions.filter { $0.type == "diet" }
        
        allergensValueLabel.text = allergens.map(\.name).joined(separator: ", ")
        dietsValueLabel.text = diets.map(\.name).joined(separator: ", ")
    }
    
    private func displayProfile(_ user: User) {
        nameLabel.text = user.name
    }
    
    private func presentRestrictionSelection(type: String, selected: Set<UUID>) {
        let vc = RestrictionSelectionViewController(type: type, selectedIDs: selected)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    // MARK: - Actions
    @objc
    private func editName() {
        let alert = UIAlertController(title: "Изменить имя", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.nameLabel.text
            textField.placeholder = "Введите новое имя"
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self, let newName = alert.textFields?.first?.text, !newName.isEmpty else { return }
            self.presenter?.updateName(updatedName: newName)
        })
        present(alert, animated: true)
    }

    @objc
    private func editAllergens() {
        presentRestrictionSelection(type: "allergen", selected: Set(allergens.map(\.id)))
    }

    @objc
    private func editDiets() {
        presentRestrictionSelection(type: "diet", selected: Set(diets.map(\.id)))
    }

    @objc
    private func logout() {
        presenter?.logout()
    }

    @objc
    private func deleteAccount() {
        presenter.deleteProfile()
    }
}

extension ProfileViewController: ProfileViewProtocol {
    func didFetchProfile(user: User, restrictions: [Restriction]) {
        self.nameLabel.text = user.name
        self.emailLabel.text = user.email
        self.restrictions = restrictions
        displayRestrictions(restrictions)
    }
    
    func didUpdateRestrictions(_ restrictions: [Restriction]) {
        self.restrictions = restrictions
        displayRestrictions(restrictions)
    }
    
    func didDeleteProfile() {
//            presenter?.deleteProfileHandler()
        guard let window = UIApplication.shared.windows.first else {
            print("[ERROR] [ProfileViewController/showLogoutAlert]: Unable to get window")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
    func updateUsername(updatedUsername: String) {
        self.nameLabel.text = updatedUsername
    }
    
    func showProfileErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка :(", message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "Попробовать еще раз", style: .default)))
        present(alert, animated: true)
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока-пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let exitAction = UIAlertAction(title: "Да", style: .default){ [weak self] _ in
            guard let self else { return }
//            presenter?.logoutHandler()
            guard let window = UIApplication.shared.windows.first else {
                print("[ERROR] [ProfileViewController/showLogoutAlert]: Unable to get window")
                return
            }
            window.rootViewController = SplashViewController()
            window.makeKeyAndVisible()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(exitAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

extension ProfileViewController: RestrictionSelectionDelegate {
    func didSelectRestrictions(type: String, selected: Set<UUID>) {
        let current = type == "allergen" ? Set(allergens.map(\.id)) : Set(diets.map(\.id))

        let toAdd = selected.subtracting(current)
        toAdd.forEach { presenter.addRestriction(id: $0) }

        let toRemove = current.subtracting(selected)
        toRemove.forEach { presenter.removeRestriction(id: $0) }
    }
}

extension UILabel {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { layer.render(in: $0.cgContext) }
    }
}
