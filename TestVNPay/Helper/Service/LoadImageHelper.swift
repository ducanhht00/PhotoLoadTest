//
//  LoadImageHelper.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 13/8/25.
//

import Foundation
import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let ioQueue = DispatchQueue(label: "ImageLoader.IOQueue", qos: .userInitiated)
    private var runningRequests: [UUID: URLSessionDataTask] = [:]

    private init() {
        memoryCache.countLimit = 100
        // Limit: 50MB
        memoryCache.totalCostLimit = 50 * 1024 * 1024
    }

    @discardableResult
    func loadImage(from url: URL, targetSize: CGSize? = nil, completion: @escaping (UIImage?) -> Void) -> UUID? {
        
        let cacheKey = cacheKeyFor(url: url, targetSize: targetSize)
        
        // 1. Memory cache
        if let cachedImage = memoryCache.object(forKey: cacheKey as NSString) {
            completion(cachedImage)
            return nil
        }
        
        let uuid = UUID()
        
        // 2. Disk cache
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            let diskPath = self.cacheFilePath(for: url, targetSize: targetSize)
            if let data = try? Data(contentsOf: URL(fileURLWithPath: diskPath)),
               let image = UIImage(data: data) {
                let decoded = image.decodedImage()
                self.memoryCache.setObject(decoded, forKey: cacheKey as NSString)
                DispatchQueue.main.async { completion(decoded) }
                return
            }
            
            // 3. Network
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
                defer { self?.runningRequests.removeValue(forKey: uuid) }
                guard let self = self,
                      let data = data,
                      let originalImage = UIImage(data: data) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                self.ioQueue.async {
                    var processedImage = originalImage.decodedImage()
                    if let size = targetSize {
                        processedImage = processedImage.resized(to: size)
                    }
                    self.memoryCache.setObject(processedImage, forKey: cacheKey as NSString)
                    
                    if let jpegData = processedImage.jpegData(compressionQuality: 0.7) {
                        let path = self.cacheFilePath(for: url, targetSize: targetSize)
                        try? jpegData.write(to: URL(fileURLWithPath: path), options: [.atomic])
                    }
                    
                    DispatchQueue.main.async { completion(processedImage) }
                }
            }
            
            task.resume()
            self.runningRequests[uuid] = task
        }
        
        return uuid
    }

    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
    
    // MARK: - Cache Helpers
    private func cacheKeyFor(url: URL, targetSize: CGSize?) -> String {
        if let size = targetSize {
            return "\(url.absoluteString)_\(Int(size.width))x\(Int(size.height))"
        }
        return url.absoluteString
    }
    
    private func cacheFilePath(for url: URL, targetSize: CGSize?) -> String {
        let key = cacheKeyFor(url: url, targetSize: targetSize)
        let fileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheDir.appendingPathComponent(fileName).path
    }
}


