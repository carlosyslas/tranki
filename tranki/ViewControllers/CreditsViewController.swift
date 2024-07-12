import UIKit

class CreditsViewController: UITableViewController {
    static let cellIdentifier = "creditsCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        decorate()
        registerViewCell()
    }
    
    private func decorate() {
        title = "Sound credits"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(hex: Theme.current.foreground)]
        tableView.backgroundColor = UIColor(hex: Theme.current.background)
        tableView.separatorColor = .clear
    }
    
    private func registerViewCell() {
        tableView.register(CreditsView.self, forCellReuseIdentifier: CreditsViewController.cellIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Sound.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CreditsViewController.cellIdentifier, for: indexPath) as? CreditsView else {
            return UITableViewCell()
        }
        
        let sound = Sound.allCases[indexPath.row]
        cell.configure(sound: sound)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let credits = Sound.allCases[indexPath.row].props.credits else { return }
        guard let url = URL(string: credits.url) else { return }
        
        UIApplication.shared.open(url)
    }
}
