// TelegramLiquidGlassIntegration.swift
import UIKit

// MARK: - Tab Bar Integration
extension MainTabBarController {
    
    func setupLiquidGlassTabBar() {
        let liquidTabBar = LiquidGlassTabBar()
        
        // Replace existing tab bar
        setValue(liquidTabBar, forKey: "tabBar")
        
        // Configure appearance
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            
            liquidTabBar.standardAppearance = appearance
            
            if #available(iOS 15.0, *) {
                liquidTabBar.scrollEdgeAppearance = appearance
            }
        }
    }
}

// MARK: - Button Integration
extension AttachButton {
    
    func applyLiquidGlassEffect() {
        let glassButton = LiquidGlassButton()
        glassButton.glassCornerRadius = 10
        glassButton.setGlassTintColor(tintColor)
        
        // Replace existing button appearance
        addSubview(glassButton)
        sendSubviewToBack(glassButton)
    }
}

// MARK: - Recording Button
extension VoiceMessageButton {
    
    func setupLiquidGlassRecording() {
        let glassView = LiquidGlassView()
        glassView.cornerRadius = bounds.height / 2
        
        insertSubview(glassView, at: 0)
        
        // Add stretch animation for recording
        addTarget(self, action: #selector(startRecording), for: .touchDown)
        addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
    }
    
    @objc private func startRecording() {
        guard let glassView = subviews.first(where: { $0 is LiquidGlassView }) as? LiquidGlassView else {
            return
        }
        
        let stretchedSize = CGSize(width: bounds.width * 1.2, height: bounds.height * 0.9)
        glassView.applyStretchEffect(to: stretchedSize, duration: 0.2)
    }
    
    @objc private func stopRecording() {
        guard let glassView = subviews.first(where: { $0 is LiquidGlassView }) as? LiquidGlassView else {
            return
        }
        
        glassView.applyStretchEffect(to: bounds.size, duration: 0.3)
    }
}

// MARK: - Switch Integration
extension UISwitch {
    
    func applyLiquidGlassStyle() {
        // Customize thumb with glass effect
        let thumbView = subviews
            .compactMap { $0 as? UIView }
            .first { String(describing: type(of: $0)) == "UISwitchModernVisualElement" }
        
        if let thumb = thumbView {
            let glassLayer = createThumbGlassLayer(for: thumb.bounds)
            thumb.layer.insertSublayer(glassLayer, at: 0)
            thumb.layer.cornerRadius = thumb.bounds.height / 2
        }
        
        // Customize track
        onTintColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    private func createThumbGlassLayer(for bounds: CGRect) -> CALayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.8).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = bounds.height / 2
        
        return gradientLayer
    }
}