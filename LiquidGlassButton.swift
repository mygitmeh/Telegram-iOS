// LiquidGlassButton.swift
import UIKit

final class LiquidGlassButton: UIButton {
    
    private let liquidGlassView = LiquidGlassView()
    private var originalBackgroundColor: UIColor?
    
    var glassCornerRadius: CGFloat = 12 {
        didSet {
            liquidGlassView.cornerRadius = glassCornerRadius
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // Store original background
        originalBackgroundColor = backgroundColor
        
        // Setup liquid glass view
        liquidGlassView.isUserInteractionEnabled = false
        liquidGlassView.cornerRadius = glassCornerRadius
        insertSubview(liquidGlassView, at: 0)
        
        // Remove default button background
        backgroundColor = .clear
        
        // Add target for button actions
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchCancel), for: .touchCancel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        liquidGlassView.frame = bounds
    }
    
    @objc private func touchDown() {
        // The LiquidGlassView handles its own animations
    }
    
    @objc private func touchUpInside() {
        // The LiquidGlassView handles its own animations
    }
    
    @objc private func touchCancel() {
        // Reset transform if touch cancelled
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
    }
    
    // MARK: - Custom Appearance
    
    func setGlassTintColor(_ color: UIColor) {
        // Adjust glass appearance based on tint
        let adjustedColor = color.withAlphaComponent(0.1)
        if let gradientLayer = liquidGlassView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.colors = [
                color.withAlphaComponent(0.2).cgColor,
                color.withAlphaComponent(0.05).cgColor,
                color.withAlphaComponent(0.1).cgColor
            ]
        }
    }
}