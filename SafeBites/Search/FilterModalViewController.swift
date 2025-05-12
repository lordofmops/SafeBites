import UIKit

protocol FilterSelectionDelegate: AnyObject {
    func didApplyFilters(_ filters: SearchFilters)
}

final class FilterModalViewController: UIViewController {
    weak var delegate: FilterSelectionDelegate?
    var initialFilters: SearchFilters?

    private let allergens = ["milk", "nuts", "gluten", "soybeans"]
    private var selectedAllergens: Set<String> = []
    private var onlyVegan = false
    private var onlyVegetarian = false

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.dataSource = self
        tv.delegate = self
        tv.allowsMultipleSelection = true
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var veganSwitch = UISwitch()
    private lazy var vegetarianSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Фильтры"
        
        if let filters = initialFilters {
            self.selectedAllergens = Set(filters.excludedAllergens)
            self.veganSwitch.isOn = filters.onlyVegan
            self.vegetarianSwitch.isOn = filters.onlyVegetarian
        }

        setupNavigationBar()
        setupLayout()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Применить", style: .done, target: self, action: #selector(applyFilters))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(dismissSelf))
    }

    private func setupLayout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc
    private func dismissSelf() {
        dismiss(animated: true)
    }

    @objc
    private func applyFilters() {
        let filters = SearchFilters(
            excludedAllergens: Array(selectedAllergens),
            onlyVegan: veganSwitch.isOn,
            onlyVegetarian: vegetarianSwitch.isOn
        )
        delegate?.didApplyFilters(filters)
        dismiss(animated: true)
    }
}

// MARK: - TableView

extension FilterModalViewController: UITableViewDataSource, UITableViewDelegate {
    enum Section: Int, CaseIterable {
        case vegan
        case vegetarian
        case allergens
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .vegan, .vegetarian: return 1
        case .allergens: return allergens.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .vegan: return "Только веганские"
        case .vegetarian: return "Только вегетарианские"
        case .allergens: return "Исключить аллергены"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        switch Section(rawValue: indexPath.section)! {
        case .vegan:
            cell.textLabel?.text = "Подходит веганам"
            cell.accessoryView = veganSwitch
        case .vegetarian:
            cell.textLabel?.text = "Подходит вегетарианцам"
            cell.accessoryView = vegetarianSwitch
        case .allergens:
            let allergen = allergens[indexPath.row]
            cell.textLabel?.text = localizedAllergenName(tag: allergen)
            cell.accessoryType = selectedAllergens.contains(allergen) ? .checkmark : .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .allergens else { return }
        let tag = allergens[indexPath.row]
        if selectedAllergens.contains(tag) {
            selectedAllergens.remove(tag)
        } else {
            selectedAllergens.insert(tag)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func localizedAllergenName(tag: String) -> String {
        switch tag {
        case "milk": return "Молоко"
        case "nuts": return "Орехи"
        case "gluten": return "Глютен"
        case "soybeans": return "Соя"
        default: return tag
        }
    }
}



