//
//  PresentableContainerViewController.swift
//  
//
//  Created by tommy on 2022/5/17.
//

import UIKit
import RxSwift
import RxKeyboard
import SnapKit

///  Presentable 全局统一容器
final class PresentableContainerViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private var keyboardDisposeBag = DisposeBag()
    
    var shouldObserveKeyboard: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        observeKeyboardIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        bindEvents()
    }
    
    // 用于控制背景色以及键盘监控等操作，不涉及任何视图层级
    private(set) var presentableViews: [PresentableView] = []
    
    func append(presentableView: PresentableView) {
        presentableViews.append(presentableView)
        onPresentableViewsChanged()
    }
    
    private func pop() -> PresentableView? {
        defer {
            onPresentableViewsChanged()
        }
        return presentableViews.popLast()
    }
    
    private func onPresentableViewsChanged() {
        observeKeyboardIfNeeded()
        changeBackgroundColorIfNeeded()
    }
    
    private func changeBackgroundColorIfNeeded() {
        let finalAlpha = presentableViews.map({ $0.backgroundLayerAlpha }).max() ?? 0
        view.backgroundColor = UIColor.black.withAlphaComponent(finalAlpha)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        guard parent == nil else { return }
        PresentableNavigator.shared.removeViewControllerFromStack(self)
    }
    
}

// MARK: - keyBoard observer

extension PresentableContainerViewController {
    
    private func observeKeyboardIfNeeded() {
        guard let topObservedKeyboardView = presentableViews.filter({ $0.shouldObserveKeyboard }).last else {
            removeKeyboardObserver()
            return
        }
        
        // only observe for the top view
        observeKeyboard(for: topObservedKeyboardView)
    }
    
    private func observeKeyboard(for presentableView: PresentableView) {
        keyboardDisposeBag = DisposeBag()
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [presentableView] keyboardVisibleHeight in
            guard presentableView.superview != nil else { return }
            presentableView.snp.updateConstraints({ (make) in
                // TODO: 具体的偏移值有待更精确
                switch presentableView.transition {
                    case .bottom:
                        make.bottom.equalToSuperview().offset(-keyboardVisibleHeight)
                    case .center:
                        make.centerY.equalToSuperview().offset(-keyboardVisibleHeight)
                }
            })
            presentableView.superview?.layoutIfNeeded()
        }).disposed(by: keyboardDisposeBag)
    }
    
    private func removeKeyboardObserver() {
        keyboardDisposeBag = DisposeBag()
    }

}

// MARK: - Events

extension PresentableContainerViewController: UIGestureRecognizerDelegate {
    
    private func bindEvents() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(onTapView))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func onTapView(_ sender: UITapGestureRecognizer) {
        guard sender.state == .recognized else {
            return
        }
        
        if let lastView = presentableViews.last,
           lastView.shouldDismissIfTappedBlankArea {
            _ = self.pop()
            PresentableNavigator.shared.pop()
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return self.view == touch.view
    }

}
