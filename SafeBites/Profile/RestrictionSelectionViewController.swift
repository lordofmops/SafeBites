import UIKit

protocol RestrictionSelectionDelegate: AnyObject {
    func didSelectRestrictions(type: String, selected: Set<UUID>)
}

final class RestrictionSelectionViewController: UITableViewController {
    private let type: String
    private var allRestrictions: [Restriction] = []
    private var selectedIDs: Set<UUID>
    weak var delegate: RestrictionSelectionDelegate?

    init(type: String, selectedIDs: Set<UUID>) {
        self.type = type
        self.selectedIDs = selectedIDs
        super.init(style: .insetGrouped)
        self.title = type == "allergen" ? "Аллергены" : "Диеты"
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = .init(title: "Сохранить", style: .done, target: self, action: #selector(save))
        
        allRestrictions = StaticRestrictions.all.filter { $0.type == type }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allRestrictions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let restriction = allRestrictions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = restriction.name
        cell.accessoryType = selectedIDs.contains(restriction.id) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restriction = allRestrictions[indexPath.row]
        if selectedIDs.contains(restriction.id) {
            selectedIDs.remove(restriction.id)
        } else {
            selectedIDs.insert(restriction.id)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    @objc
    private func save() {
        delegate?.didSelectRestrictions(type: type, selected: selectedIDs)
        dismiss(animated: true)
    }
}

