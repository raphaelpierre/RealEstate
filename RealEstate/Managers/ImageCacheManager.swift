import Foundation
import UIKit
import CryptoKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // Maximum number of images
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB limit
        return cache
    }()
    
    private let queue = DispatchQueue(label: "com.realestate.imagecache")
    
    // Disk cache path
    private let fileManager = FileManager.default
    private lazy var diskCachePath: URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("ImageCache")
    }()
    
    private init() {
        createDiskCacheDirectoryIfNeeded()
    }
    
    private func createDiskCacheDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: diskCachePath.path) else { return }
        try? fileManager.createDirectory(at: diskCachePath, withIntermediateDirectories: true)
    }
    
    // Memory cache operations
    func setImage(_ image: UIImage, forKey key: String) {
        queue.async {
            self.imageCache.setObject(image, forKey: key as NSString)
            self.saveToDisk(image: image, forKey: key)
        }
    }
    
    func getImage(forKey key: String) -> UIImage? {
        if let cachedImage = imageCache.object(forKey: key as NSString) {
            return cachedImage
        }
        return loadFromDisk(forKey: key)
    }
    
    // Disk cache operations
    private func saveToDisk(image: UIImage, forKey key: String) {
        let fileURL = diskCachePath.appendingPathComponent(key.md5Hash)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    private func loadFromDisk(forKey key: String) -> UIImage? {
        let fileURL = diskCachePath.appendingPathComponent(key.md5Hash)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else { return nil }
        imageCache.setObject(image, forKey: key as NSString)
        return image
    }
    
    func clearCache() {
        queue.async {
            self.imageCache.removeAllObjects()
            try? self.fileManager.removeItem(at: self.diskCachePath)
            self.createDiskCacheDirectoryIfNeeded()
        }
    }
}

// Extension for MD5 hashing
extension String {
    var md5Hash: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
} 