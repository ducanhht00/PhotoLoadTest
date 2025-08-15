//
//  PhotoService.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 13/8/25.
//

import Foundation
import UIKit

class PhotoAPIService {
    func fetchPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        let urlString = "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let photos = try JSONDecoder().decode([Photo].self, from: data)
                completion(.success(photos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
