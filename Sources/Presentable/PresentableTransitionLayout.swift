//
//  PresentableTransitionLayout.swift
//  Test
//
//  Created by tommy on 2022/5/17.
//

import UIKit
import SnapKit

// MARK: - Transition

extension PresentableNavigator {
    
    /// - Parameters:
    ///   - targetView: view's superView
    func doPresentTransitionAnimation(for view: UIView,
                                      at targetView: UIView,
                                      transition: PresentableTransitionType) {
        switch transition {
        case .bottom:
            self.presentFromBottom(for: view, at: targetView)
        case .center:
            self.presentFromCenter(for: view)
        }
    }
    
    func doDismissTransitionAnimation(for view: UIView,
                                      transition: PresentableTransitionType,
                                      completion: @escaping () -> Void) {
        switch transition {
        case .bottom:
            dismissFromBottom(for: view, completion: completion)
        case .center:
            dismissFromCenter(for: view, completion: completion)
        }
    }
    
    private func dismissFromBottom(for view: UIView, completion: @escaping () -> Void) {
        guard let targetSuperView = view.superview else {
            view.removeFromSuperview()
            completion()
            return
        }
        
        view.snp.remakeConstraints { make in
            make.top.equalTo(targetSuperView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.90,
                       initialSpringVelocity: 0.8,
                       options: .curveLinear, animations: {
            targetSuperView.layoutIfNeeded()
        }, completion: { _ in
            view.removeFromSuperview()
            completion()
        })
    }
    
    private func dismissFromCenter(for view: UIView, completion: @escaping () -> Void) {
        view.removeFromSuperview()
        completion()
    }
    
    private func presentFromCenter(for view: UIView) {
        
        view.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        view.layoutIfNeeded()

        view.transform = CGAffineTransform(scaleX: CGFloat.leastNormalMagnitude,
                                           y: CGFloat.leastNormalMagnitude)
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.8,
                       options: .curveLinear) {
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    private func presentFromBottom(for view: UIView,
                                   at targetView: UIView) {
        
        var topSuperViewConstraint: Constraint?
        
        view.snp.makeConstraints { make in
            topSuperViewConstraint = make.top.equalTo(targetView.snp.bottom).constraint
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        targetView.layoutIfNeeded()
        
        topSuperViewConstraint?.deactivate()
        
        view.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.90,
                       initialSpringVelocity: 0.8,
                       options: .curveLinear) {
            targetView.layoutIfNeeded()
        }
        
    }
    
    
}
