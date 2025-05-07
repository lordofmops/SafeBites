import UIKit

protocol RegistrationViewProtocol: AnyObject {
    func showRegistrationErrorAlert(message: String)
    func didRegister(user: User, token: String)
}

final class RegistrationViewController: UIViewController {
    private var presenter: RegistrationPresenterProtocol?
    
    // MARK: UI elements
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SourceSansPro-Regular", size: 24)
        label.text = "SafeBites"
        label.textColor = .sbWhite
        label.backgroundColor = .sbBackground
        return label
    }()
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        label.text = "Создайте новый аккаунт"
        label.textColor = .sbWhite
        label.textAlignment = .center
        return label
    }()
    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Имя (опционально)",
            attributes: [.foregroundColor: UIColor.sbSilver.withAlphaComponent(0.5)]
        )
        textField.textColor = .sbSilver
        
        textField.layer.cornerRadius = 24
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.sbSilver.cgColor
        textField.layer.masksToBounds = true
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        
        textField.textContentType = .nickname
        textField.autocorrectionType = .no
        
        return textField
    }()
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Электронная почта",
            attributes: [.foregroundColor: UIColor.sbSilver.withAlphaComponent(0.5)]
        )
        textField.textColor = .sbSilver
        
        textField.layer.cornerRadius = 24
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.sbSilver.cgColor
        textField.layer.masksToBounds = true
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Пароль",
            attributes: [.foregroundColor: UIColor.sbSilver.withAlphaComponent(0.5)]
        )
        textField.textColor = .sbSilver
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.sbSilver.cgColor
        textField.layer.cornerRadius = 24
        textField.layer.masksToBounds = true
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите пароль повторно",
            attributes: [.foregroundColor: UIColor.sbSilver.withAlphaComponent(0.5)]
        )
        textField.textColor = .sbSilver
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.sbSilver.cgColor
        textField.layer.cornerRadius = 24
        textField.layer.masksToBounds = true
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Зарегистрироваться", for: .normal)
        button.setTitleColor(.sbBackground, for: .normal)
        button.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        button.titleLabel?.textAlignment = .center
        
        button.backgroundColor = .sbSilver
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RegistrationPresenter(registrationVC: self)
        
        view.backgroundColor = .sbBackground
        setupLabels()
        setupRegisterForm()
        setupRegisterButton()
    }
    
    // MARK: Button actions
    @objc
    private func didTapRegisterButton() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
              let name = nicknameTextField.text else {
            showRegistrationErrorAlert(message: "Заполните все обязательные поля")
            print("[ERROR] [RegistrationViewController/didTapRegisterButton] Empty fields in registration form")
            return
        }
        
        if confirmPassword != password {
            showRegistrationErrorAlert(message: "Пароли не совпадают")
            print("[ERROR] [RegistrationViewController/didTapRegisterButton] Passwords do not match")
            return
        }
        
        presenter?.register(email: email, password: password, name: name)
    }
    
    // MARK: UI setup
    private func setupLabels() {
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoLabel)
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.heightAnchor.constraint(equalToConstant: 32),
            
            instructionLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            instructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            instructionLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupRegisterForm() {
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nicknameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        
        NSLayoutConstraint.activate([
            nicknameTextField.heightAnchor.constraint(equalToConstant: 48),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            nicknameTextField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 30),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            emailTextField.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 16),
            
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 48),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupRegisterButton() {
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(registerButton)
        
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            registerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            registerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

extension RegistrationViewController: RegistrationViewProtocol {
    func didRegister(user: User, token: String) {
        guard let window = UIApplication.shared.windows.first else {
            print("[ERROR] [RegistrationViewController/didRegister]: Invalid window configuration")
            return
        }
        window.rootViewController = UINavigationController(rootViewController: ScanningViewController())
    }
    // TODO: при нажатии на кнопку вообще ничего не происходит
    func showRegistrationErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка :(", message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "Попробовать еще раз", style: .default)))
        present(alert, animated: true)
    }
}
