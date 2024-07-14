import Foundation
import XCTest
@testable import tranki

final class PlayerViewModelTests: XCTestCase {
    func test_whenPlaying_progressGetsUpdatedEachSecond() {
        let vm = makePlayerViewModel(totalDuration: .seconds(3))
        let delegate = PlayerViewModelDelegateSpy()
        vm.delegate = delegate
        let progressUpdated = expectation(description: "Progress got updated")
        delegate.onProgressUpdated = { progress, isPlaying in
            XCTAssertTrue(isPlaying)
            XCTAssertEqual(progress, 0.33333334)
            progressUpdated.fulfill()
        }
       
        vm.play()
        
        waitForExpectations(timeout: 3)
    }
    
    func test_afterTotalTimeHasElapsed_timerGetsStopped() {
        let vm = makePlayerViewModel()
        let delegate = PlayerViewModelDelegateSpy()
        vm.delegate = delegate
        let timerStopped = expectation(description: "Timer gets stopped")
        delegate.onTotalDurationElapsed = {
            timerStopped.fulfill()
        }
        
        vm.play()
        
        waitForExpectations(timeout: 3)
    }
    
    func makePlayerViewModel(totalDuration: Duration = .seconds(1)) -> PlayerViewModel {
        return PlayerViewModel(totalDuration: totalDuration)
    }
    
    final class PlayerViewModelDelegateSpy: NSObject, PlayerViewModelDelegate {
        var onProgressUpdated: ((Float, Bool) -> Void)?
        var onTotalDurationElapsed: (() -> Void)?
        
        func playerViewModelProgressUpdated(progress: Float, isPlaying: Bool) {
            onProgressUpdated?(progress, isPlaying)
        }
        
        func playerViewModelTotalDurationElapsed() {
            onTotalDurationElapsed?()
        }
    }
}
