import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hexLength = hex.count
        if !(hexLength == 7) {
            // A hex must be either 7 or 9 characters (#RRGGBBAA)
            print("improper call to 'colorFromHex', hex length must be 7 or 9 chars (#GGRRBBAA)")
            self.init(white: 0, alpha: 1)
            return
        }
        
        // Establishing the rgb color
        var rgb: UInt64 = 0
        let s: Scanner = Scanner(string: hex)
        // Setting the scan location to ignore the leading `#`
        let _ = s.scanCharacter()
        // Scanning the int into the rgb colors
        s.scanHexInt64(&rgb)
        
        // Creating the UIColor from hex int
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1
        )
    }
}
