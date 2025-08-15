//
//  NetworkMonitor.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 14/8/25.
//

import Foundation
import Network

enum NetworkConnectionStatus {
    case online 
    case offline
}
extension Notification.Name {
    static let internetChanged = Notification.Name("internetChanged")
}

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var lastKnownStatus: NetworkConnectionStatus = .online  // 상태 추적을 위해 추가
    
    var currentStatus: NetworkConnectionStatus {
        return determineNetworkStatus(monitor.currentPath)
    }
    
    private func updateInitialState() {
        let initialStatus = determineNetworkStatus(monitor.currentPath)
        updateNetworkStatus(initialStatus)
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let status = self.determineNetworkStatus(path)
            if lastKnownStatus != status{
                lastKnownStatus = status
                NotificationCenter.default.post(name: .internetChanged, object: self)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func determineNetworkStatus(_ path: NWPath) -> NetworkConnectionStatus {
        let isConnected = path.status == .satisfied
        return isConnected ? .online : .offline
    }
    
    func updateNetworkStatus(_ status: NetworkConnectionStatus) {
        lastKnownStatus = status
    }
    
    deinit {
        monitor.cancel()
    }
}
