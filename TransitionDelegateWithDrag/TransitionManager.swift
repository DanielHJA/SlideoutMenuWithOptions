//
//  TransitionManager.swift
//  TransitionDelegate
//
//  Created by Daniel Hjartstrom on 04/01/2018.
//  Copyright © 2018 Daniel Hjartstrom. All rights reserved.
//

import UIKit

enum Direction {
    case top
    case bottom
    case left
    case right
}

enum PresentationStatus {
    case present
    case dismiss
}

class TransitionManager: NSObject, UIViewControllerTransitioningDelegate {

    var height: CGFloat
    var duration: Double
    var tapToDismiss: Bool
    var presentingDirection: Direction
    var dismissingDirection: Direction
    
    init(height: CGFloat, duration: Double, tapToDismiss: Bool, presentingDirection: Direction, dismissingDirection: Direction) {
        self.height = height
        self.duration = duration
        self.tapToDismiss = tapToDismiss
        self.presentingDirection = presentingDirection
        self.dismissingDirection = dismissingDirection
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimation(height: height, transition: .present, duration: duration, presentingDirection: presentingDirection, dismissingDirection: dismissingDirection)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimation(height: height, transition: .dismiss, duration: duration, presentingDirection: presentingDirection, dismissingDirection: dismissingDirection)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting, height: height, tapToDismiss: tapToDismiss, presentingDirection: presentingDirection, dismissingDirection: dismissingDirection)
    }
    
}

class PresentationController: UIPresentationController {
    
    var height: CGFloat = 0
    var presentingDirection: Direction
    var dismissingDirection: Direction
    var dimViewAlphaMax: CGFloat = 1.0
    
    lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
    }()
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        let temp = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        temp.numberOfTapsRequired = 1
        return temp
    }()
    
    let dimmView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        temp.alpha = 0
        return temp
    }()
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, height: CGFloat, tapToDismiss: Bool, presentingDirection: Direction, dismissingDirection: Direction) {
        self.height = height
        self.presentingDirection = presentingDirection
        self.dismissingDirection = dismissingDirection
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.view.addGestureRecognizer(panGesture)
        
        if tapToDismiss {
            dimmView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        guard let container = containerView else { return }
        let translation = sender.translation(in: presentedViewController.view)
        let origin = presentedViewController.view.frame.origin
        
        let translationWithHeightBottom = CGPoint(x: 0, y: (translation.y > 0.0 ? translation.y : 0.0) + container.frame.height - height)
       
        let translationWithHeightTop = CGPoint(x: 0, y:  (translation.y > 0.0 ? translation.y : 0.0))
        
        switch presentingDirection {
        case .bottom:
            if origin.y >= 0.0 && sender.velocity(in: presentedViewController.view).y > 0.0 {
                presentedViewController.view.frame.origin.y = translationWithHeightBottom.y
                dimmView.alpha = 1.0 - (translation.y / presentedViewController.view.frame.height)
                if sender.state == .ended {
                    if origin.y > container.frame.height * 0.8 {
                        dismiss()
                    } else {
                        returnToOrigin(CGPoint(x: 0, y: container.frame.height - height))
                    }
                }
            } else {
                returnToOrigin(CGPoint(x: 0, y: container.frame.height - height))
            }
        case .top:
            if origin.y <= 0.0 && sender.velocity(in: presentedViewController.view).y < 0.0 {
                presentedViewController.view.frame.origin.y = translationWithHeightTop.y
                dimmView.alpha = 1.0 + (translation.y / presentedViewController.view.frame.height)
                if sender.state == .ended {
                    if origin.y < -height * 0.8 {
                        dismiss()
                    } else {
                        returnToOrigin(CGPoint(x: 0, y: 0))
                    }
                }
            } else {
                returnToOrigin(CGPoint(x: 0, y: 0))
            }
        case .right:
break
        case .left:
            break
        }
        
    }
    
    private func returnToOrigin(_ origin: CGPoint) {
        presentingViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.presentedViewController.view.frame.origin = CGPoint(x: origin.x, y: origin.y)
            self.dimmView.alpha = 1.0
            self.presentingViewController.view.layoutIfNeeded()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        switch presentingDirection {
        case .bottom:
            presentedView?.frame = CGRect(x: 0, y: frameOfPresentedViewInContainerView.height - height, width: frameOfPresentedViewInContainerView.width, height: height)
        case .top:
            presentedView?.frame = CGRect(x: 0, y: 0, width: frameOfPresentedViewInContainerView.width, height: height)
        case .right:
            presentedView?.frame = CGRect(x: 0, y: frameOfPresentedViewInContainerView.height - height, width: frameOfPresentedViewInContainerView.width, height: height)
        case .left:
            presentedView?.frame = CGRect(x: 0, y: frameOfPresentedViewInContainerView.height - height, width: frameOfPresentedViewInContainerView.width, height: height)
        }
    }
    
    override func presentationTransitionWillBegin() {
        dimmView.frame = self.containerView!.bounds
        dimmView.alpha = 0
        containerView?.insertSubview(dimmView, at: 0)
        
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: {[weak self] (_) -> Void in
            self?.dimmView.alpha = (self?.dimViewAlphaMax)!
        })
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentedViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: {[weak self] (_) -> Void in
            self?.dimmView.alpha = 0.0
        })
    }
    
    @objc func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
}

class TransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var height: CGFloat
    var duration: Double
    var transition: PresentationStatus
    var presentingDirection: Direction
    var dismissingDirection: Direction
    
    init(height: CGFloat, transition: PresentationStatus, duration: Double, presentingDirection: Direction, dismissingDirection: Direction) {
        self.height = height
        self.transition = transition
        self.duration = duration
        self.presentingDirection = presentingDirection
        self.dismissingDirection = dismissingDirection
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        
        switch transition {
        case .present:
            
            container.addSubview(toView)
            container.clipsToBounds = true
            toView.layer.masksToBounds = true
            
            switch presentingDirection {
            case .bottom:
                toView.frame.origin.y = toView.bounds.height
            case .top:
                toView.frame.origin.y = -height
            case .right:
                toView.frame.origin.x = toView.bounds.width
            case .left:
                toView.frame.origin.x = -toView.bounds.width
            }
        
            animateIn(container: container, fromView: fromView, toView: toView, transitionContext: transitionContext)
 
        case .dismiss:
            
            animateOut(container: container, fromView: fromView, toView: toView, transitionContext: transitionContext)
        }
    }
    
    private func animateOut(container: UIView, fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning) {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
          
                switch self.dismissingDirection {
                case .top:
                    fromView.frame.origin.y = -self.height
                case .bottom:
                    fromView.frame.origin.y = fromView.bounds.height + (toView.frame.height - self.height)
                case .left:
                    fromView.frame.origin.x -= toView.frame.width
                case .right:
                    fromView.frame.origin.x += toView.frame.width
                }
            
            }, completion: { (completion) in
                transitionContext.completeTransition(!(transitionContext.transitionWasCancelled))
            })
        }
    
    private func animateIn(container: UIView, fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
            
            switch self.presentingDirection {
            case .top:
                toView.frame.origin.y += self.height
            case .bottom:
                toView.frame.origin.y -= self.height
            case .left:
                toView.frame.origin.x += toView.frame.width
            case .right:
                toView.frame.origin.x -= toView.frame.width
            }
            
            }, completion: { (completion) in
                transitionContext.completeTransition(!(transitionContext.transitionWasCancelled))
        })
    }
}
