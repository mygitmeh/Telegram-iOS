// LiquidGlassView.swift
import UIKit

final class LiquidGlassView: UIView {
    
    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let bounceScale: CGFloat = 1.05
        static let highlightOpacity: Float = 0.3
        static let blurRadius: CGFloat = 20.0
    }
    
    // MARK: - Properties
    
    private let glassLayer = CAGradientLayer()
    private let highlightLayer = CAShapeLayer()
    private let blurView = UIVisualEffectView()
    private var currentBlurEffect: UIBlurEffect?
    private var tapFeedbackGenerator: UIImpactFeedbackGenerator?
    
    var isBlurEnabled: Bool = true {
        didSet {
            blurView.isHidden = !isBlurEnabled
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Setup blur
        setupBlurEffect()
        
        // Setup glass gradient
        setupGlassLayer()
        
        // Setup highlight layer
        setupHighlightLayer()
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        // Setup feedback generator for iOS 10+
        if #available(iOS 10.0, *) {
            tapFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        }
    }
    
    private func setupBlurEffect() {
        let blurEffect: UIBlurEffect
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            blurEffect = UIBlurEffect(style: .light)
        }
        
        blurView.effect = blurEffect
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        insertSubview(blurView, at: 0)
        
        currentBlurEffect = blurEffect
    }
    
    private func setupGlassLayer() {
        glassLayer.frame = bounds
        glassLayer.colors = [
            UIColor.white.withAlphaComponent(0.25).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        glassLayer.locations = [0, 0.5, 1]
        glassLayer.startPoint = CGPoint(x: 0.5, y: 0)
        glassLayer.endPoint = CGPoint(x: 0.5, y: 1)
        glassLayer.cornerRadius = cornerRadius
        
        layer.addSublayer(glassLayer)
    }
    
    private func setupHighlightLayer() {
        highlightLayer.fillColor = UIColor.white.cgColor
        highlightLayer.opacity = 0
        highlightLayer.cornerRadius = cornerRadius
        layer.addSublayer(highlightLayer)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        glassLayer.frame = bounds
        highlightLayer.frame = bounds
        blurView.frame = bounds
        
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
        glassLayer.cornerRadius = cornerRadius
        highlightLayer.cornerRadius = cornerRadius
        blurView.layer.cornerRadius = cornerRadius
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
            glassLayer.cornerCurve = .continuous
            blurView.layer.cornerCurve = .continuous
        }
    }
    
    // MARK: - Touch Handling
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            showTapHighlight(at: location)
            tapFeedbackGenerator?.prepare()
        case .ended:
            animateTapRelease()
            tapFeedbackGenerator?.impactOccurred()
        case .cancelled, .failed:
            hideTapHighlight()
        default:
            break
        }
    }
    
    private func showTapHighlight(at point: CGPoint) {
        // Create highlight path
        let highlightPath = UIBezierPath(
            ovalIn: CGRect(
                x: point.x - 30,
                y: point.y - 30,
                width: 60,
                height: 60
            )
        )
        
        highlightLayer.path = highlightPath.cgPath
        
        // Animate highlight appearance
        let highlightAnimation = CABasicAnimation(keyPath: "opacity")
        highlightAnimation.fromValue = 0
        highlightAnimation.toValue = Constants.highlightOpacity
        highlightAnimation.duration = Constants.animationDuration * 0.3
        highlightAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        highlightLayer.add(highlightAnimation, forKey: "highlightAppear")
        highlightLayer.opacity = Constants.highlightOpacity
        
        // Scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = Constants.bounceScale
        scaleAnimation.duration = Constants.animationDuration * 0.4
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(scaleAnimation, forKey: "scaleUp")
        
        // Apply scale
        UIView.animate(withDuration: Constants.animationDuration * 0.4) {
            self.transform = CGAffineTransform(scaleX: Constants.bounceScale, y: Constants.bounceScale)
        }
    }
    
    private func animateTapRelease() {
        // Bounce animation
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [Constants.bounceScale, 0.98, 1.0]
        bounceAnimation.keyTimes = [0, 0.5, 1]
        bounceAnimation.duration = Constants.animationDuration * 0.6
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(bounceAnimation, forKey: "bounce")
        
        // Apply bounce transform
        UIView.animate(withDuration: Constants.animationDuration * 0.6,
                      delay: 0,
                      usingSpringWithDamping: 0.4,
                      initialSpringVelocity: 0.5,
                      options: []) {
            self.transform = .identity
        }
        
        // Hide highlight
        hideTapHighlight()
    }
    
    private func hideTapHighlight() {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = Constants.highlightOpacity
        fadeAnimation.toValue = 0
        fadeAnimation.duration = Constants.animationDuration * 0.3
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        highlightLayer.add(fadeAnimation, forKey: "highlightFade")
        highlightLayer.opacity = 0
    }
    
    // MARK: - Stretch Effect
    
    func applyStretchEffect(to size: CGSize, duration: TimeInterval = 0.3) {
        let animation = CABasicAnimation(keyPath: "bounds.size")
        animation.fromValue = NSValue(cgSize: bounds.size)
        animation.toValue = NSValue(cgSize: size)
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(animation, forKey: "stretch")
        bounds.size = size
        
        // Animate blur view
        UIView.animate(withDuration: duration) {
            self.blurView.bounds.size = size
        }
    }
}