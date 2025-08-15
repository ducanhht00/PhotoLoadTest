//
//  baseMVVM.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 14/8/25.
//

import UIKit

public protocol ViewProtocol: AnyObject {
    associatedtype ViewModel: ViewModelProtocol
    var viewModel: ViewModel! { get set }
    func onViewEvent(_ event: ViewModel.ViewEvent)
}

public extension ViewProtocol {
    func onViewEvent(_ event: ViewModel.ViewEvent) { }
}

public protocol ViewModelAction { }
public protocol ViewEventProtocol { }
public protocol ViewModelProtocol {
    associatedtype ViewEvent: ViewEventProtocol
    associatedtype Action: ViewModelAction

    var onViewEvent: ((ViewEvent) -> Void)? { get set }
    func dispatch(action: Action)
    func performAction(_ action: Action) -> [ViewEvent]

}

public extension ViewModelProtocol {

    func dispatch(action: Action) {
        DispatchQueue.main.async {
            let events = self.performAction(action)
            for event in events {
                self.onViewEvent?(event)
            }
        }
    }

    func dispatch(actions: [Action]) {
        for action in actions {
            dispatch(action: action)
        }
    }

}

public class Observable <T> {
    typealias Listener = (T) -> Void
    private var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func binding(_ listener: Listener?) {
        DispatchQueue.main.async{
            listener?(self.value)
            self.listener = listener
        }
    }

}

