//
//  PresentableNavigator.swift
//  
//
//  Created by tommy on 2022/5/17.
//

import UIKit
import SnapKit

struct PresentableItem: Equatable {
    
    let view: PresentableView?
    
    let viewController: UIViewController?
    
    var isNil: Bool {
        return view == nil && viewController == nil
    }
    
}

final class PresentableNavigator: UINavigationController {
    
    private static let rootViewController = PresentableContainerViewController()
    
    static let shared = PresentableNavigator(rootViewController: rootViewController)
    
    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var stack: [PresentableItem] = []
    
}

// MARK: - Stack

extension PresentableNavigator {
    
    func append(view: PresentableView) {
        guard let topViewController = self.topViewController,
              let targetView = topViewController.view else {
                  return
              }
        dismissKeyboard()
        stack.append(PresentableItem(view: view, viewController: nil))
        
        if let root = topViewController as? PresentableContainerViewController {
            root.append(presentableView: view)
        }

        view.willPresent()
        view.willPresentSubject.onNext(())
        view.delegate?.presentableViewWillPresent(view)

        presentContainerNavigationIfNeeded {
            targetView.addSubview(view)
            self.doPresentTransitionAnimation(for: view,
                                                 at: targetView,
                                                 transition: view.transition)
            view.didPresent()
            view.didPresentSubject.onNext(())
            view.delegate?.presentableViewDidPresent(view)
        }
        
    }
    
    func append(viewController: UIViewController) {
        dismissKeyboard()

        let containerViewController = PresentableContainerViewController()
        viewController.willMove(toParent: containerViewController)
        containerViewController.addChild(viewController)
        containerViewController.view.addSubview(viewController.view)
        viewController.view.frame = containerViewController.view.bounds
        viewController.didMove(toParent: containerViewController)
        stack.append(PresentableItem(view: nil, viewController: containerViewController))

        presentContainerNavigationIfNeeded {
            self.pushViewController(containerViewController, animated: true)
        }
    }
    
    /// navigation bar
    func removeViewControllerFromStack(_ viewController: PresentableContainerViewController) {
        stack.removeAll { item in
            if let view = item.view {
                return viewController.presentableViews.contains(view)
            } else {
                return false
            }
        }
        stack.removeAll { $0.viewController == viewController }
        dismissIfEmpty()
    }

    /// pop 特定的某个 view
    func pop(view: PresentableView) {
        view.willDismiss()
        view.willDismissSubject.onNext(())
        view.delegate?.presentableViewWillDismiss(view)
        stack.removeAll { $0.view == view }
        doDismissTransitionAnimation(for: view,
                                     transition: view.transition,
                                     completion: dismissIfEmpty)
    }

    /// remove 最上层的一个 item
    func pop() {
        guard let lasItem = stack.last,
              lasItem.isNil == false else {
            dismiss(animated: false, completion: nil)
            return
        }
        
        if let view = lasItem.view {
            view.willDismiss()
            view.willDismissSubject.onNext(())
            view.delegate?.presentableViewWillDismiss(view)

            stack.removeAll{ $0 == lasItem }
            doDismissTransitionAnimation(for: view,
                                         transition: view.transition,
                                         completion: dismissIfEmpty)
        } else if let _ = lasItem.viewController {
            stack.removeAll{ $0 == lasItem }
            popViewController(animated: true)
            dismissIfEmpty()
        }
    }

    private func dismissIfEmpty() {
        guard stack.count == 0 else { return }
        dismiss(animated: false, completion: nil)
    }

    /// 清空所有 item, 并且 dismiss
    func popAll() {
        stack.removeAll()
        viewControllers = []
        dismiss(animated: false, completion: nil)
    }
    
    private func presentContainerNavigationIfNeeded(completion: (() -> Void)? = nil) {
        if presentingViewController == nil {
            UIApplication.shared.keyWindow?.rootViewController?.present(self,
                                                                        animated: false,
                                                                        completion: completion)
        } else {
            completion?()
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared
            .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

