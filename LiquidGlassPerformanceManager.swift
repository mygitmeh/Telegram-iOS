// LiquidGlassPerformanceManager.swift
import UIKit

final class LiquidGlassPerformanceManager {
    
    static let shared = LiquidGlassPerformanceManager()
    
    private var blurCache: [String: UIBlurEffect] = [:]
    private var gradientCache: NSCache<NSString, CGGradient> = NSCache()
    
    private init() {
        setupMemoryWarningObserver()
    }
    
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func clearCache() {
        blurCache.removeAll()
        gradientCache.removeAllObjects()
    }
    
    func cachedBlurEffect(for style: UIBlurEffect.Style) -> UIBlurEffect {
        let key = "blur_\(style.rawValue)"
        
        if let cached = blurCache[key] {
            return cached
        }
        
        let effect = UIBlurEffect(style: style)
        blurCache[key] = effect
        return effect
    }
    
    func cachedGradient(for colors: [UIColor]) -> CGGradient? {
        let key = colors.map { $0.description }.joined()
        
        if let cached = gradientCache.object(forKey: key as NSString) {
            return cached
        }
        
        guard let gradient = createGradient(colors: colors) else {
            return nil
        }
        
        gradientCache.setObject(gradient, forKey: key as NSString)
        return gradient
    }
    
    private func createGradient(colors: [UIColor]) -> CGGradient? {
        let cgColors = colors.map { $0.cgColor } as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        return CGGradient(
            colorsSpace: colorSpace,
            colors: cgColors,
            locations: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}