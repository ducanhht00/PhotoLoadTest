//
//  PhotoTableViewCell.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 13/8/25.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    private var currentURL: URL?
    
    @IBOutlet weak var inforLbl: UILabel!
    
    static let identifier : String = "PhotoTableViewCell"
    private var imageLoadUUID: UUID?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let uuid = imageLoadUUID {
            ImageLoader.shared.cancelLoad(uuid)
        }
        photoImageView.image = nil
    }
    
    func setupUI(photo: Photo){
        self.inforLbl.text = "\(photo.author) \nSize: \(photo.width)x\(photo.height)"
    }
    
    func configureImage(with urlString: String, id: String) {
        guard let url = URL(string: urlString) else { return }
        currentURL = url
        imageLoadUUID = ImageLoader.shared.loadImage(from: url) { [weak self] image in
            print("PhotoTableViewCell load image")
            if self?.currentURL == url {
                self?.photoImageView.image = image
            }
            
        }
    }
}
