//
//  PhotoUseCases.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 15/8/25.
//

import Foundation

protocol FetchPhotosUseCaseProtocol {
    func fetchPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], Error>) -> Void)
}

final class LoadPhotosUseCase: FetchPhotosUseCaseProtocol {
    private let apiService: PhotoAPIService
    
    init(apiService: PhotoAPIService = PhotoAPIService()) {
        self.apiService = apiService
    }
    
    func fetchPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        apiService.fetchPhotos(page: page, limit: limit, completion: completion)
    }
}
