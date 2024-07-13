import Foundation
import UIKit
import SwiftUI

class SettingsViewController: UITableViewController {
    var reloadDataTimer: Timer?
    weak var settingsVM: PlayerSettingsViewModel?

    static private let soundSettingsCellIdentifier = "soundSettingsCell"
    static private let durationSettingsCellIdentifier = "durationSettingsCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SoundSettingsViewCell.self, forCellReuseIdentifier: SettingsViewController.soundSettingsCellIdentifier)
        tableView.register(DurationSettingsViewCell.self, forCellReuseIdentifier: SettingsViewController.durationSettingsCellIdentifier)
        
        layout()
        decorate()
    }

    private func decorate() {
        view.backgroundColor = .init(hex: Theme.current.background)
    }
    
    private func layout() {
        let rightNavButton = UIBarButtonItem(title: "Credits", style: .done, target: self, action: #selector(creditsButtonTapped))
        rightNavButton.tintColor = .init(hex: Theme.current.foregroundDim)
        navigationItem.rightBarButtonItem = rightNavButton
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (settingsVM?.soundSettings.values.count ?? 0) + 1
    }
    
    private func dequeueSoundSettingsCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsViewController.soundSettingsCellIdentifier, for: indexPath) as? SoundSettingsViewCell else {
            return UITableViewCell()
        }
        let sound = Sound.allCases[indexPath.row - 1]
        if let soundSettings = settingsVM?.soundSettings[sound.rawValue] {
            cell.configure(configuration: soundSettings)
        }
        cell.delegate = self
        
        return cell
    }
    
    private func dequeueDurationSettingsCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsViewController.durationSettingsCellIdentifier) as? DurationSettingsViewCell else {
            return UITableViewCell()
        }

        if let duration = settingsVM?.duration {
            cell.configure(duration: duration)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > 0 {
            return dequeueSoundSettingsCell(indexPath: indexPath)
        }
        
        return dequeueDurationSettingsCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = DurationSettingsViewController()
            vc.settingsVM = settingsVM
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            
            present(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    private func debouncedReloadData() {
        reloadDataTimer?.invalidate()
        
        reloadDataTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    @objc private func creditsButtonTapped() {
        let creditsVC = CreditsViewController()

        navigationController?.pushViewController(creditsVC, animated: true)
    }
}

extension SettingsViewController: SoundSettingsViewCellDelegate {
    func soundSettingsViewCellDidChangeVolume(sound: Sound, volume: Float) {
        settingsVM?.setVolume(sound: sound, volume: volume)
        debouncedReloadData()
    }
    
    func soundSettingsViewCellDidTapIconButton(sound: Sound) {
        settingsVM?.toggleActive(sound: sound)
        tableView.reloadData()
    }
}

extension SettingsViewController: PlayerSettingsViewModelDelegate {
    func playerSettingsViewModelDurationUpdated(duration: Duration) {
        tableView.reloadData()
    }
}
