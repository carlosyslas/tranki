import Foundation
import XCTest
@testable import tranki

final class PlayerViewModelTests: XCTestCase {
    func testAlgo() {
        let vm = makePlayerViewModel()
        
//        vm.
        
    }
    
    func makePlayerViewModel() -> PlayerViewModel {
        let settingsVM = PlayerSettingsViewModel(
            persistenceManager: UserDefaultsPersistenceManager()
        )
        
        return PlayerViewModel(settingsVM: settingsVM)
    }
}
