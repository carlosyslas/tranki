import Foundation

class PlayerViewModel {
    weak var delegate: PlayerViewModelDelegate?
    
    private var timer: Timer?
    private var elapsedTime: Duration = .zero
    private var totalDuration: Duration
    private(set) var isPlaying: Bool = false
    
    var remainingTimeText: String {
        let remaining = totalDuration - elapsedTime
        
        return remaining.formatted(.time(pattern: .minuteSecond))
    }

    init(totalDuration: Duration) {
        self.totalDuration = totalDuration
        subscribe()
    }
    
    deinit {
        unsubscribe()
    }
    
    func play() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateElapsedTime),
            userInfo: nil,
            repeats: true
        )
        RunLoop.current.add(timer!, forMode: .common)
        isPlaying = true
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        elapsedTime = .zero
        isPlaying = false
        delegate?.playerViewModelProgressUpdated(progress: 0, isPlaying: false)
    }
    
    func configure(totalDuration: Duration) {
        self.totalDuration = totalDuration
        stop()
    }

    @objc
    private func updateElapsedTime() {
        elapsedTime += Duration.seconds(1)
        if elapsedTime >= totalDuration {
            stop()
            delegate?.playerViewModelTotalDurationElapsed()
            // TODO: Ease out and play a bell sound
            return
        }
        
        let progress: Float = Float(elapsedTime.components.seconds) / Float(totalDuration.components.seconds)

        delegate?.playerViewModelProgressUpdated(progress: progress, isPlaying: isPlaying)
    }

    private func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(durationChanged), name: .setDuration, object: nil)
    }
    
    private func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func durationChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let duration = userInfo["duration"] as? Duration else { return }
        
        elapsedTime = .zero
        totalDuration = duration
    }
}

protocol PlayerViewModelDelegate: AnyObject {
    func playerViewModelProgressUpdated(progress: Float, isPlaying: Bool)
    func playerViewModelTotalDurationElapsed()
}
