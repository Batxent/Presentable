//
//  Presentable.swift
//
//
//  Created by tommy on 2022/5/17.
//

import UIKit

public enum PresentableTransitionType {

    /// 从底部弹出
    case bottom

    /// 由中间弹出
    case center
}

public protocol Presentable {

    var transition: PresentableTransitionType { get }

    /// 若为 true, 会随着键盘弹起下落而改变位置
    var shouldObserveKeyboard: Bool { get }

    /// 黑色蒙层透明度
    var backgroundLayerAlpha: CGFloat { get }

    func present()

    func dismiss()

    /// 在弹框中需要 push 到一个新的页面
    func pushToViewController(_ viewController: UIViewController)

}

public protocol PresentableDelegate: AnyObject {

    func presentableViewWillPresent(_ presentableView: Presentable)

    func presentableViewDidPresent(_ presentableView: Presentable)

    func presentableViewWillDismiss(_ presentableView: Presentable)

}
