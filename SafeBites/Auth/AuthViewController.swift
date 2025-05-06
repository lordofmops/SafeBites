import UIKit

protocol AuthViewProtocol: AnyObject {
    func showAuthErrorAlert(message: String)
    func didAuthenticated(token: String)
}

final class AuthViewController: UIViewController {
    // MARK: UI elements
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SourceSansPro-Regular", size: 24)
        label.text = "SafeBites"
        label.textColor = .sbWhite
        label.backgroundColor = .sbBackground
        return label
    }()
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SourceSansPro-Regular", size: 24)
        label.text = "Привет!"
        label.textColor = .sbWhite
        label.textAlignment = .center
        return label
    }()
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        label.text = "Войдите в свой аккаунт"
        label.textColor = .sbWhite
        label.textAlignment = .center
        return label
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
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.sbWhite, for: .normal)
        button.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        button.titleLabel?.textAlignment = .center
        
        button.backgroundColor = .sbBlack
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    private lazy var registerInstructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        label.text = "или создайте новый:"
        label.textColor = .sbWhite
        label.textAlignment = .center
        return label
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
    
    private var presenter: AuthPresenterProtocol?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AuthPresenter(authVC: self)
        
        view.backgroundColor = .sbBackground
        setupLabels()
        setupLoginForm()
        setupButtons()
        setupBackwardButton()
    }
    
    // MARK: Button actions
    @objc
    private func didTapLoginButton() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            showAuthErrorAlert(message: "Заполните все поля")
            print("[ERROR] [AuthViewController/didTapLoginButton] Empty fields in login form")
            return
        }
        
        presenter?.login(email: email, password: password)
    }
    
    @objc
    private func didTapRegisterButton() {
        let registrationScreen = RegistrationViewController()
        
        navigationController?.pushViewController(registrationScreen, animated: true)
    }
    
    // MARK: UI setup
    private func setupBackwardButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_button_black")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_button_black")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .sbSilver
    }
    
    private func setupLabels() {
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoLabel)
        view.addSubview(welcomeLabel)
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.heightAnchor.constraint(equalToConstant: 32),
            
            welcomeLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 26),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            welcomeLabel.heightAnchor.constraint(equalToConstant: 32),
            
            instructionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            instructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            instructionLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupLoginForm() {
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            emailTextField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 30),
            
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupButtons() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        registerInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loginButton)
        view.addSubview(registerInstructionLabel)
        view.addSubview(registerButton)
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            
            registerInstructionLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            registerInstructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            registerInstructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            registerInstructionLabel.heightAnchor.constraint(equalToConstant: 21),
            
            registerButton.topAnchor.constraint(equalTo: registerInstructionLabel.bottomAnchor, constant: 16),
            registerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            registerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

extension AuthViewController: AuthViewProtocol {
    func showAuthErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка :(", message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "ОК", style: .default)))
        present(alert, animated: true)
    }
    
    func didAuthenticated(token: String) {
        let scanningView = ScanningViewController()
        
        navigationController?.pushViewController(scanningView, animated: true)
    }
}
