import UIKit

class CreditsView: UITableViewCell {
    private lazy var soundNameLabel: UILabel = {
       let label = UILabel()
        
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: Theme.current.foreground)
        
        return label
    }()
    
    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hex: Theme.current.foregroundDim)
        
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            soundNameLabel,
            authorNameLabel,
        ])
        
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        decorate()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func decorate() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor(hex: Theme.current.backgroundDark)
    }
    
    private func layout() {
        addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
    
    func configure(sound: Sound) {
        soundNameLabel.text = sound.props.name
        authorNameLabel.text = "Author: \(sound.props.credits?.authorName ?? "-")"
    }
}
