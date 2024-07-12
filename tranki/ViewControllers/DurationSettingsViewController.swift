import UIKit
import SwiftUI

class DurationSettingsViewController: UIViewController {
    weak var settingsVM: PlayerSettingsViewModel?
    private var timeSteps: [Int] = []
    private lazy var duration: Duration = settingsVM?.duration ?? .zero

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Duration:"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .init(hex: Theme.current.foreground)
        
        return label
    }()
    
    private lazy var picker: UIPickerView = {
       let picker = UIPickerView()
        
        picker.delegate = self
        picker.dataSource = self

        return picker
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        
        button.setTitle("Done", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .init(hex: Theme.current.accent)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var vStack: UIStackView = {
       let stack = UIStackView(arrangedSubviews: [
        titleLabel,
        picker,
        UIView(),
        doneButton,
       ])
        
        stack.axis = .vertical
        
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<12 {
            timeSteps.append(i * 5)
        }
        
        layout()
        bind()
    }

    private func layout() {
        view.backgroundColor = .init(hex: Theme.current.background)
        
        view.addSubview(vStack)
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            picker.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func bind() {
        let duration = settingsVM?.duration ?? .zero
        let minutes = duration.components.seconds / 60
        let seconds = duration.components.seconds % 60
        
        let minutesIndex = Int(minutes / 5)
        let secondsIndex = Int(seconds / 5)
        
        picker.selectRow(minutesIndex, inComponent: 0, animated: true)
        picker.selectRow(secondsIndex, inComponent: 1, animated: true)
    }

    @objc
    private func doneButtonPressed(_ sender: UIButton) {
        settingsVM?.duration = duration
        dismiss(animated: true)
    }
}

extension DurationSettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        timeSteps.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let step = timeSteps[row]
        let unit = component == 0 ? "min" : "sec"
        
        let title = NSAttributedString(string: String(format: "%02d \(unit)", step), attributes: [
            NSAttributedString.Key.foregroundColor: UIColor(hex: Theme.current.foreground)
        ])
        
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currentMinutes = duration.components.seconds / 60
        let currentSeconds = duration.components.seconds % 60
        
        if component == 0 {
            let newMinutes = Int64(row * 5)
            duration = .seconds(newMinutes * 60 + currentSeconds)
        } else {
            let newSeconds = Int64(row * 5)
            duration = .seconds(currentMinutes * 60 + newSeconds)
        }
    }
}

struct DurationSettingsViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = DurationSettingsViewController
    
    func makeUIViewController(context: Context) -> DurationSettingsViewController {
        return DurationSettingsViewController()
    }
    
    func updateUIViewController(_ uiViewController: DurationSettingsViewController, context: Context) {
        
    }
}

#Preview {
    DurationSettingsViewControllerRepresentable()
}
