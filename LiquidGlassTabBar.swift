// LiquidGlassTabBar.swift
import UIKit

final class LiquidGlassTabBar: UITabBar {
    
    private let glassContainer = UIView()
    private var glassLayers: [CALayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLiquidGlassTabBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLiquidGlassTabBar()
    }
    
    private func setupLiquidGlassTabBar() {
        // Remove default background
        backgroundImage = UIImage()
        shadowImage = UIImage()
        isTranslucent = true
        
        // Setup glass container
        glassContainer.frame = bounds
        glassContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        glassContainer.isUserInteractionEnabled = false
        insertSubview(glassContainer, at: 0)
        
        // Create glass effect for each tab
        setupGlassLenses()
    }
    
    private func setupGlassLenses() {
        // Clear existing layers
        glassLayers.forEach { $0.removeFromSuperlayer() }
        glassLayers.removeAll()
        
        // Calculate tab positions
        guard let items = items, items.count > 0 else { return }
        
        let tabWidth = bounds.width / CGFloat(items.count)
        
        for i in 0..<items.count {
            let xPosition = CGFloat(i) * tabWidth
            let lensFrame = CGRect(x: xPosition, y: 0, width: tabWidth, height: bounds.height)
            
            let glassLayer = createGlassLayer(for: lensFrame)
            glassContainer.layer.addSublayer(glassLayer)
            glassLayers.append(glassLayer)
        }
    }
    
    private func createGlassLayer(for frame: CGRect) -> CALayer {
        let glassLayer = CAGradientLayer()
        glassLayer.frame = frame
        
        // Create subtle glass gradient
        glassLayer.colors = [
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor
        ]
        
        glassLayer.locations = [0, 0.5, 1]
        glassLayer.startPoint = CGPoint(x: 0.5, y: 0)
        glassLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Rounded corners
        glassLayer.cornerRadius = 20
        glassLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if #available(iOS 13.0, *) {
            glassLayer.cornerCurve = .continuous
        }
        
        return glassLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGlassLenses()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Update appearance for dark/light mode
        setupGlassLenses()
    }
}