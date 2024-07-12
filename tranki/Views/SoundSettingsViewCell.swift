import UIKit

class SoundSettingsViewCell: UITableViewCell {
    struct Configuration {
        let isActive: Bool
        let sound: Sound
        let volume: Float
    }
    
    var delegate: SoundSettingsViewCellDelegate?
    private var settings: SoundSettings?

    private lazy var iconButton: UIButton = {
        let button = UIButton()
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(
            self,
            action: #selector(handleIconButtonPress),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .init(hex: Theme.current.foreground)
        
        return label
    }()
    
    private lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.isContinuous = false
        slider.addTarget(self, action: #selector(handleVolumeSliderChange), for: .valueChanged)

        
        return slider
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            nameLabel,
            volumeSlider,
        ])
        
        stack.axis = .vertical
        stack.spacing = 8
        
        return stack
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            iconButton,
            vStack,
        ])
        
        stack.axis = .horizontal
        stack.spacing = 16
        
        return stack
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .init(hex: Theme.current.background)
        
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(configuration: SoundSettings) {
        self.settings = configuration
        nameLabel.text = configuration.sound.props.name
        
        let tint = UIColor(hex: configuration.isActive ? Theme.current.accent : Theme.current.foregroundDim)
        let image = UIImage(systemName: configuration.sound.props.image) ?? UIImage(systemName: "questionmark")!
        
        iconButton.setImage(image, for: .normal)
        iconButton.tintColor = tint
        
        volumeSlider.isEnabled = configuration.isActive
        volumeSlider.value = configuration.volume
        volumeSlider.tintColor = tint
        volumeSlider.thumbTintColor = tint
    }

    private func layout() {
        backgroundColor = .init(hex: Theme.current.background)
        selectedBackgroundView = bgView
        
        contentView.addSubview(hStack)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        
        // icon constraints
        iconButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        iconButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        // hStack constraints
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
        ])
    }

    @objc
    private func handleIconButtonPress(_ sender: UIButton) {
        guard let sound = settings?.sound else {
            return
        }

        delegate?.soundSettingsViewCellDidTapIconButton(sound: sound)
    }
    
    @objc
    private func handleVolumeSliderChange(_ sender: UISlider) {
        guard let sound = settings?.sound else {
            return
        }
        
        delegate?.soundSettingsViewCellDidChangeVolume(
            sound: sound,
            volume: sender.value
        )
    }
}

protocol SoundSettingsViewCellDelegate {
    func soundSettingsViewCellDidTapIconButton(sound: Sound)
    func soundSettingsViewCellDidChangeVolume(sound: Sound, volume: Float)
}
