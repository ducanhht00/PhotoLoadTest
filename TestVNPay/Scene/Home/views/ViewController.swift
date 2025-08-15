//
//  ViewController.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 13/8/25.
//

import UIKit

class ViewController: UIViewController{
    
    var viewModel: PhotoViewModel!
    func onViewEvent(_ event: PhotoViewEvent) {
        switch event {
        case .updateLoadingState(let enable): updateLoadingState(enable)
        case .scrollToTop: tableview.scroll(to: .top, animated: true)
        default: break
        }
    }

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var pageNumberLbl: UILabel!
    
    private let refreshControl = UIRefreshControl()
    let loadingOverlay = LoadingOverlay()
    private var photos: [Photo] = []
    private var isLoadFullData : Bool = false
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PhotoViewModel()
        setupAction()
        setupTableView()
        bindingData()
        viewModel.dispatch(action: .loadData(isLoadFullData))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .internetChanged, object: nil)
    }
    
    // MARK: Setup Component
    @objc func statusManager(_ notification: Notification) {
        if NetworkMonitor.shared.currentStatus == .offline {
            showAlert(title: Constants.noInternetTitle,
                      msg: Constants.noInternetBody)
        }
    }
    func updateLoadingState(_ enable : Bool){
        if enable {
            loadingOverlay.show(on: self.view)
        } else {
            loadingOverlay.hide()
        }
    }
    
    func bindingData(){
        viewModel.onViewEvent = { [weak self] event in
            self?.onViewEvent(event)
        }
        viewModel.filterPhotos.binding({ [weak self] data in
            self?.photos = data
            self?.tableview.reloadData()
        })
        
        viewModel.currentPage.binding({ [weak self] page in
            self?.pageNumberLbl.text = "\(page)"
            self?.previousBtn.isHidden = page == 1
        })
    }
    
    func setupAction() {
        searchBar.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, 
                                                action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(statusManager),
                                               name: .internetChanged, object: nil)
    }
    
    func setupTableView() {
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UINib(nibName: PhotoTableViewCell.identifier, bundle: nil),
                forCellReuseIdentifier: PhotoTableViewCell.identifier)
        refreshControl.attributedTitle = NSAttributedString(string: Constants.refreshText)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableview.refreshControl = refreshControl
    }
    
    // MARK: Action
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func refreshData() {
        isLoadFullData = false
        viewModel.dispatch(action: .loadData(isLoadFullData))
        refreshControl.endRefreshing()
       }
        
    @IBAction func previousBtnPressed(_ sender: UIButton) {
        if NetworkMonitor.shared.currentStatus == .online {
            isLoadFullData = false
            viewModel.dispatch(action: .changePage(false))
        } else {
            showAlert(title: Constants.noInternetTitle,
                      msg: Constants.noInternetChangePageBody)
        }
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        if NetworkMonitor.shared.currentStatus == .online {
            isLoadFullData = false
            viewModel.dispatch(action: .changePage(true))
        } else {
            showAlert(title: Constants.noInternetTitle,
                      msg: Constants.noInternetChangePageBody)
        }
    }

    // MARK: Alert
    func showAlert(title: String, msg: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController (
                title: title,
                message: msg,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK:  TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photos.count
        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.identifier, for: indexPath) as! PhotoTableViewCell
            let photo = photos[indexPath.row]
            cell.setupUI(photo: photo)
            cell.configureImage(with: photo.downloadURL, id: photo.id)
            return cell
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let position = scrollView.contentOffset.y
            let contentHeight = tableview.contentSize.height
            let scrollHeight = scrollView.frame.size.height
            
            if (position > contentHeight - scrollHeight * 2) && !isLoadFullData {
                isLoadFullData = true
                viewModel.dispatch(action: .loadData(self.isLoadFullData))
            }
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let photo = photos[indexPath.row]
        let photoHeight = screenWidth * CGFloat(photo.height) / CGFloat(photo.width)
        
        // Chiều cao cell = chiều cao ảnh + chiều cao đoạn hiển thị thông tin ảnh(40)
        return photoHeight + 40
        }
}

// MARK: Search bar
extension ViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let sanitized = searchText.sanitizedEnglishOnly(maxLength: 15)
        if sanitized != searchBar.text {
            searchBar.text = sanitized
        }
        self.viewModel.dispatch(action: .filterData(sanitized))
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchBar.resignFirstResponder()
            return false
        }
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
