import UIKit

class CircularProgressBarView: UIView {
    private let strokeWidth: CGFloat = 8
    private var progress: CGFloat = 0.0 {
        didSet {
            animateProgress()
        }
    }
    private var endAngle: CGFloat = CGFloat.pi
    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(shapeLayer)
        setupShapeLayer()
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShapeLayer()
    }

    private func setupShapeLayer() {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (bounds.width - strokeWidth) / 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = CGFloat.pi * 2 + startAngle
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        shapeLayer.opacity = 0.0
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor(hex: Theme.current.accent).cgColor
        shapeLayer.lineWidth = strokeWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeStart = .zero
        shapeLayer.strokeEnd = .zero
    }

    private func animateProgress() {
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.fromValue = shapeLayer.strokeEnd
        progressAnimation.toValue = progress
        progressAnimation.duration = 0.9
        progressAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let opacity: CFloat = progress == 0.0 ? 0.0 : 1.0
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = shapeLayer.opacity
        opacityAnimation.toValue = opacity
        opacityAnimation.duration = opacity == 0.0 ? 2.0 : 0.5
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shapeLayer.strokeEnd = progress
        shapeLayer.opacity = opacity
        shapeLayer.add(progressAnimation, forKey: "animateProgress")
        shapeLayer.add(opacityAnimation, forKey: "animateOpacity")
    }

    func configure(progress: CGFloat) {
        self.progress = progress
    }
}

#Preview {
    CircularProgressBarView(frame: .zero)
}
