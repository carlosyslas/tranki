import UIKit
import SwiftUI

class DurationSettingsViewCell: UITableViewCell {
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        
        imageView.tintColor = .init(hex: Theme.current.accentSecondary)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "clock")
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 12)
        label.text = "Duration:"
        label.textColor = .init(hex: Theme.current.foregroundDim)
        
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        
        label.font = .boldSystemFont(ofSize: 20)
        label.text = "00:00"
        label.textColor = .init(hex: Theme.current.foreground)
        
        return label
    }()
    
    private lazy var disclosure: UIImageView = {
       let imageView = UIImageView()
        
        imageView.image = .init(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .init(hex: Theme.current.foregroundDim)
        
        return imageView
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .init(hex: Theme.current.backgroundDark)
        
        return view
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            durationLabel,
       ])
        
        stack.axis = .vertical
        
        return stack
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            icon,
            vStack,
            disclosure,
        ])
        
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        
    
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(duration: Duration) {
        let minutes = duration.components.seconds / 60
        let seconds = duration.components.seconds % 60
        
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func layout() {
        backgroundColor = .init(hex: Theme.current.background)
        selectedBackgroundView = bgView
        
        contentView.addSubview(hStack)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 42),
            icon.heightAnchor.constraint(equalToConstant: 42),
        ])
        
        NSLayoutConstraint.activate([
            disclosure.widthAnchor.constraint(equalToConstant: 20),
            disclosure.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
        ])
    }
}

#Preview {
    let cell = DurationSettingsViewCell(style: .default, reuseIdentifier: "preview")
    
    
    return cell
}
