// LiquidGlassSlider.swift
import UIKit

final class LiquidGlassSlider: UISlider {
    
    private let thumbGlassView = LiquidGlassView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSlider()
    }
    
    private func setupSlider() {
        // Setup thumb appearance
        let thumbSize = CGSize(width: 28, height: 28)
        let thumbImage = createGlassThumbImage(size: thumbSize)
        setThumbImage(thumbImage, for: .normal)
        
        // Setup thumb glass view
        thumbGlassView.frame = CGRect(origin: .zero, size: thumbSize)
        thumbGlassView.cornerRadius = thumbSize.width / 2
        thumbGlassView.isUserInteractionEnabled = false
        
        // Customize track
        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        
        // Setup custom track
        setupTrackLayers()
    }
    
    private func createGlassThumbImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw glass effect
        let colors = [
            UIColor.white.withAlphaComponent(0.8).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ] as CFArray
        
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: [0, 1]
        )!
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2
        
        context.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: 0,
            endCenter: center,
            endRadius: radius,
            options: .drawsBeforeStartLocation
        )
        
        // Add border
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(1)
        context.strokeEllipse(in: CGRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    private func setupTrackLayers() {
        // Remove default track
        setMaximumTrackImage(UIImage(), for: .normal)
        setMinimumTrackImage(UIImage(), for: .normal)
        
        // Create custom track layers
        let trackHeight: CGFloat = 4
        
        let backgroundTrack = CALayer()
        backgroundTrack.frame = CGRect(
            x: 0,
            y: (bounds.height - trackHeight) / 2,
            width: bounds.width,
            height: trackHeight
        )
        backgroundTrack.backgroundColor = UIColor.white.withAlphaComponent(0.1).cgColor
        backgroundTrack.cornerRadius = trackHeight / 2
        
        let valueTrack = CALayer()
        valueTrack.frame = CGRect(
            x: 0,
            y: (bounds.height - trackHeight) / 2,
            width: 0, // Will be updated
            height: trackHeight
        )
        valueTrack.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
        valueTrack.cornerRadius = trackHeight / 2
        
        layer.insertSublayer(backgroundTrack, at: 0)
        layer.insertSublayer(valueTrack, at: 1)
        
        // Update value track on value change
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc private func valueChanged() {
        updateTrackLayers()
    }
    
    private func updateTrackLayers() {
        guard let valueTrack = layer.sublayers?[1] else { return }
        
        let trackWidth = bounds.width * CGFloat(value)
        valueTrack.frame.size.width = trackWidth
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTrackLayers()
    }
}