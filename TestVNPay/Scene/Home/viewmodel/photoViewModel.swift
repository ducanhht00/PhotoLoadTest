//
//  photoViewModel.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 14/8/25.
//

import UIKit
enum PhotoViewModelAction: ViewModelAction{
    case updateLoadingState(_ enable: Bool)
    case scrollToTop
    case filterData(_ filterText: String)
    case loadData(_ fullData: Bool)
    case changePage( _ isNextPage: Bool)
    case `nil`
}

enum PhotoViewEvent: ViewEventProtocol{
    case updateLoadingState(_ enable: Bool)
    case scrollToTop
    case `nil`
}

class PhotoViewModel: ViewModelProtocol {
    var onViewEvent: ((PhotoViewEvent) -> Void)?
    func performAction(_ action: PhotoViewModelAction) -> [PhotoViewEvent] {
        switch action {
        case .updateLoadingState(let enable):
            return [.updateLoadingState(enable)]
        case .scrollToTop:
            return [.scrollToTop]
        case .loadData(let fullData):
            loadPhotos(isLoadFullData: fullData)
        case .filterData(let text):
            filterData(text: text)
        case .changePage(let isNext):
            changePageAction(isNext)
        default: break
            
        }
        return [.nil]
    }
    
    private let loadPhotosUseCase = LoadPhotosUseCase()
    private var photos: [Photo] = []
    private var searchText : String = ""
    private var isLoading : Bool = false
    
    let filterPhotos: Observable<[Photo]> = Observable([])
    let currentPage: Observable<Int> = Observable(1)
    
    func changePageAction(_ isNextBtn: Bool = true) {
        currentPage.value += isNextBtn ? 1 : -1
        self.dispatch(action: .scrollToTop)
        loadPhotos(isLoadFullData: false)
    }
    
    // MARK: Load Image
    private func loadPhotos(isLoadFullData: Bool) {
        guard !isLoading else { return}
        self.dispatch(action: .updateLoadingState(true))
        isLoading = true
        var apiPageNumber = currentPage.value
        var pageLimit = 50
        
        // Xử lý data để phân biệt load more/refresh/chuyển trang
        // Logic: api page sẽ khác với số page tại app ( xử lý load more)
        // Mỗi page phân trđể call api là 50
        // Mỗi page thể hiện trên ứng dụng là 100
        
        if currentPage.value != 1 && !isLoadFullData {
            apiPageNumber = apiPageNumber * 2 + 1
        } else if isLoadFullData && !self.photos.isEmpty {
            apiPageNumber = apiPageNumber * 2
        }
        if isLoadFullData && self.photos.isEmpty {
            pageLimit = 100
        }
        loadPhotosUseCase.fetchPhotos(page: apiPageNumber, limit: pageLimit) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let newPhotos):
                        if !isLoadFullData {
                            self.photos = newPhotos
                        } else {
                            self.photos.append(contentsOf: newPhotos)
                        }
                        self.filterData(text: self.searchText)
                    case .failure(let error):
                        print("Error fetching photos:", error)
                    }
                    self.isLoading = false
                    self.dispatch(action: .updateLoadingState(false))
                }
            }
    }
    // MARK: Filter Data
    func filterData(text : String) {
        searchText = text
        if text.isEmpty {
            filterPhotos.value = photos
        } else {
            filterPhotos.value = photos.filter { $0.author.lowercased().contains(text.lowercased()) }
        }
    }
}

