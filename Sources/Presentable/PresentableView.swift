//
//  PresentableView.swift
//  
//
//  Created by tommy on 2022/5/17.
//

import UIKit
import RxSwift

open class PresentableView: UIView, Presentable {

    open var transition: PresentableTransitionType {
        return .center
    }

    open var shouldObserveKeyboard: Bool {
        return false
    }

    /// 背景层透明度
    open var backgroundLayerAlpha: CGFloat {
        return 0.38
    }
    
    open var shouldDismissIfTappedBlankArea: Bool {
        return true
    }
        
    public func present() {
        PresentableNavigator.shared.append(view: self)
    }

    public func dismiss() {
        PresentableNavigator.shared.pop(view: self)
    }

    public func pushToViewController(_ viewController: UIViewController) {
        PresentableNavigator.shared.append(viewController: viewController)
    }

    // 用于子类内部处理一些逻辑

    open func willPresent() { }
    open func didPresent() { }
    open func willDismiss() { }

    // 类 block 的形式给出事件

    public let willPresentSubject = PublishSubject<Void>()
    public let didPresentSubject = PublishSubject<Void>()
    public let willDismissSubject = PublishSubject<Void>()

    // delegate 的形式给出事件

    public weak var delegate: PresentableDelegate?


}
