//
//  PhotoModel.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 13/8/25.
//

import Foundation

struct Photo: Codable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, author, width, height
        case downloadURL = "download_url"
    }
}
