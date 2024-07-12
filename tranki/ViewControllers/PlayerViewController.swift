import UIKit
import SwiftUI
import AVFoundation

class PlayerViewController: UIViewController {
    let soundService = SoundManager.shared
    private let settingsVM: PlayerSettingsViewModel
    lazy var playerVM = PlayerViewModel(
        settingsVM: settingsVM
    )
    
    private lazy var settingsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: .init(systemName: "slider.horizontal.3"),
            style: .done,
            target: self,
            action: #selector(settingsButtonPressed)
        )
        
        button.tintColor = .init(hex: Theme.current.foregroundDim)
        
        return button
    }()
    
    private lazy var togglePlayButton: UIButton = {
        let button = UIButton()
        
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .init(hex: Theme.current.foregroundDim)
        button.addTarget(self, action: #selector(togglePlayButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var progressBar: CircularProgressBarView = {
       let bar = CircularProgressBarView()
        
        return bar
    }()
    
    init(settingsVM: PlayerSettingsViewModel) {
        self.settingsVM = settingsVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerVM.delegate = self
        
        layout()
        configureTogglePlayButton(isPlaying: false)
        subscribe()
    }
    
    deinit {
        unsubscribe()
    }

    private func layout() {
        navigationController?.navigationBar.tintColor = .init(hex: Theme.current.foregroundDim)
        navigationController?.navigationBar.barTintColor = .init(hex: Theme.current.background)
        
        view.backgroundColor = .init(hex: Theme.current.background)
        
        navigationItem.rightBarButtonItem = settingsButton
        
        view.addSubview(togglePlayButton)
        view.addSubview(progressBar)
        
        togglePlayButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            togglePlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            togglePlayButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            togglePlayButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            togglePlayButton.heightAnchor.constraint(equalTo: togglePlayButton.widthAnchor),
        ])
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressBar.widthAnchor.constraint(equalTo: togglePlayButton.widthAnchor, constant: 4),
            progressBar.heightAnchor.constraint(equalTo: progressBar.widthAnchor),
        ])
        
        if let buttonImageView = togglePlayButton.imageView {
            buttonImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buttonImageView.heightAnchor.constraint(equalTo: togglePlayButton.heightAnchor),
                buttonImageView.widthAnchor.constraint(equalTo: togglePlayButton.widthAnchor),
            ])
        }
    }

    private func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(soundMutted), name: .muteSound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(soundUnmutted), name: .unmuteSound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(soundVolumeSet), name: .setSoundVolume, object: nil)
    }
    
    private func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func settingsButtonPressed(_ sender: UIBarButtonItem) {
        let settingsVC = SettingsViewController()
        settingsVC.settingsVM = settingsVM
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func togglePlayButtonPressed(_ sender: UIButton) {
        if playerVM.isPlaying {
            playerVM.stop()
            configureTogglePlayButton(isPlaying: false)
            stopSounds()
        } else {
            playerVM.play()
            configureTogglePlayButton(isPlaying: true)
            playSounds()
        }
    }
    
    @objc private func soundMutted(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let sound = userInfo["sound"] as? Sound else { return }
        
        SoundManager.shared.muteSound(sound: sound)
    }
    
    @objc private func soundUnmutted(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let sound = userInfo["sound"] as? Sound else { return }
        let volume = settingsVM.getVolume(sound: sound)
        
        SoundManager.shared.unmuteSound(sound: sound, previousVolume: volume)
    }
    
    @objc private func soundVolumeSet(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let sound = userInfo["sound"] as? Sound else { return }
        guard let volume = userInfo["volume"] as? Float else { return }
        
        SoundManager.shared.updateSoundVolume(sound: sound, volume: volume)
    }

    private func configureTogglePlayButton(isPlaying: Bool) {
        let image = UIImage(named: isPlaying ? "stop-button" : "start-button")
        togglePlayButton.setImage(image, for: .normal)
    }

    private func playSounds() {
        DispatchQueue.global(qos: .background).async { [weak settingsVM] in
            guard let settings = settingsVM?.soundSettings else { return }
            SoundManager.shared.playAllSounds(soundSettings: Array(settings.values))
        }
    }
    
    private func stopSounds() {
        DispatchQueue.global(qos: .background).async {
            SoundManager.shared.stopAllSounds()
        }
    }
    
    static func instantiate() -> PlayerViewController {
        let playerSettingsViewModel = PlayerSettingsViewModel(
            persistenceManager: UserDefaultsPersistenceManager()
        )
        return PlayerViewController(
            settingsVM: playerSettingsViewModel
        )
    }
}

struct PlayerViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = PlayerViewController
    
    func makeUIViewController(context: Context) -> PlayerViewController {
        return PlayerViewController.instantiate()
    }
    
    func updateUIViewController(_ uiViewController: PlayerViewController, context: Context) {
    }
}

#Preview {
    PlayerViewControllerRepresentable()
}

extension PlayerViewController: PlayerViewModelDelegate {
    func playerViewModelTotalDurationElapsed() {
        SoundManager.shared.stopAllSounds()
    }
    
    func playerViewModelProgressUpdated(progress: Float, isPlaying: Bool) {
        progressBar.configure(progress: CGFloat(progress))
        if !isPlaying {
            configureTogglePlayButton(isPlaying: isPlaying)
        }
    }
}
