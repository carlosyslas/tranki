import UIKit
import SwiftUI
import AVFoundation

class PlayerViewController: UIViewController {
    private let settingsVM: PlayerSettingsViewModel
    private let soundManager: SoundManager
    
    lazy var playerVM = PlayerViewModel(
        totalDuration: settingsVM.duration
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
    
    init(settingsVM: PlayerSettingsViewModel, soundManager: SoundManager) {
        self.settingsVM = settingsVM
        self.soundManager = soundManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerVM.delegate = self
        
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(hex: Theme.current.foregroundDim)]
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
        settingsVM.delegate = settingsVC
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func togglePlayButtonPressed(_ sender: UIButton) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium, view: togglePlayButton)
        feedbackGenerator.impactOccurred()
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
        
        soundManager.muteSound(sound: sound)
    }
    
    @objc private func soundUnmutted(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let sound = userInfo["sound"] as? Sound else { return }
        let volume = settingsVM.getVolume(sound: sound)
        
        soundManager.unmuteSound(sound: sound, previousVolume: volume)
    }
    
    @objc private func soundVolumeSet(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let sound = userInfo["sound"] as? Sound else { return }
        guard let volume = userInfo["volume"] as? Float else { return }
        
        soundManager.updateSoundVolume(sound: sound, volume: volume)
    }

    private func configureTogglePlayButton(isPlaying: Bool) {
        let image = UIImage(named: isPlaying ? "stop-button" : "start-button")
        togglePlayButton.setImage(image, for: .normal)
    }

    private func playSounds() {
        do {
            try soundManager.playAllSounds(sounds: Sound.allCases)
        }
        catch {
            // TODO: Show an error to the user
            print("There was an error playing sounds: \(error)")
        }
    }
    
    private func stopSounds() {
        soundManager.stopAllSounds()
    }
    
    static func instantiate() -> PlayerViewController {
        let playerSettingsViewModel = PlayerSettingsViewModel(
            persistenceManager: UserDefaultsPersistenceManager()
        )
        return PlayerViewController(
            settingsVM: playerSettingsViewModel,
            soundManager: AVAudioSoundManager(
                settingsVM: playerSettingsViewModel
            )
        )
    }
}

extension PlayerViewController: PlayerViewModelDelegate {
    func playerViewModelTotalDurationElapsed() {
        soundManager.stopAllSounds()
    }
    
    func playerViewModelProgressUpdated(progress: Float, isPlaying: Bool) {
        progressBar.configure(progress: CGFloat(progress))
        
        if isPlaying {
            navigationItem.title = playerVM.remainingTimeText
        } else {
            navigationItem.title = ""
        }
        
        if !isPlaying {
            configureTogglePlayButton(isPlaying: isPlaying)
        }
    }
}
