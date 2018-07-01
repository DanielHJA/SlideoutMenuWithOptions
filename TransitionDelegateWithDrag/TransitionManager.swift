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

enum BackgroundStyle {
    case dimmed, blurred
}

class TransitionManager: NSObject, UIViewControllerTransitioningDelegate {

    var percentage: CGFloat
    var duration: Double
    var tapToDismiss: Bool
    var direction: Direction
    var backgroundStyle: BackgroundStyle
    
    init(percentage: CGFloat, duration: Double, tapToDismiss: Bool, direction: Direction, backgroundStyle: BackgroundStyle) {
        self.percentage = percentage
        self.duration = duration
        self.tapToDismiss = tapToDismiss
        self.direction = direction
        self.backgroundStyle = backgroundStyle
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimation(percentage: percentage, transition: .present, duration: duration, direction: direction)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimation(percentage: percentage, transition: .dismiss, duration: duration, direction: direction)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting, percentage: percentage, tapToDismiss: tapToDismiss, direction: direction, backgroundStyle: backgroundStyle)
    }
    
}

class PresentationController: UIPresentationController {
    
    var percentage: CGFloat = 0
    var direction: Direction
    var backgroundStyle: BackgroundStyle
    var dimViewAlphaMax: CGFloat = 1.0

    lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
    }()
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        let temp = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        temp.numberOfTapsRequired = 1
        return temp
    }()
    
    let dimmView: UIView? = {
        let temp = UIView()
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        temp.alpha = 0
        return temp
    }()
    
    let blurView: UIVisualEffectView? = {
        let effect = UIBlurEffect(style: .regular)
        let temp = UIVisualEffectView(effect: effect)
        temp.alpha = 0
        return temp
    }()
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, percentage: CGFloat, tapToDismiss: Bool, direction: Direction, backgroundStyle: BackgroundStyle) {
        self.percentage = percentage
        self.direction = direction
        self.backgroundStyle = backgroundStyle
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.view.addGestureRecognizer(panGesture)
        
        if tapToDismiss {
            if backgroundStyle == .dimmed {
                dimmView?.addGestureRecognizer(tapRecognizer)
            } else {
                blurView?.addGestureRecognizer(tapRecognizer)
            }
        }
    }
    
    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        guard let container = containerView else { return }
        let translation = sender.translation(in: presentedViewController.view)
        let origin = presentedViewController.view.frame.origin
        
        let translationBottom = CGPoint(x: 0, y: (translation.y > 0.0 ? translation.y : 0.0) + container.frame.height - (container.frame.height * percentage))

        let translationRight = CGPoint(x: (translation.x > 0.0 ? translation.x : 0.0) + container.frame.width - (container.frame.width * percentage), y: 0)
        
        switch direction {
        case .bottom:
            if origin.y >= 0.0 && sender.velocity(in: presentedViewController.view).y > 0.0 {
                presentedViewController.view.frame.origin.y = translationBottom.y
                setAlpha(1.0 - (translation.y / presentedViewController.view.frame.height))
                if sender.state == .ended {
                    if origin.y > container.frame.height * 0.8 {
                        dismiss()
                    } else {
                        returnToOrigin(CGPoint(x: 0, y: container.frame.height - (container.frame.height * percentage)))
                    }
                }
            } else {
                returnToOrigin(CGPoint(x: 0, y: container.frame.height - (container.frame.height * percentage)))
            }
        case .top:
            if origin.y <= 0.0 && sender.velocity(in: presentedViewController.view).y < 0.0 {
                presentedViewController.view.frame.origin.y = translation.y
                setAlpha(1.0 + (translation.y / presentedViewController.view.frame.height))
                if sender.state == .ended {
                    if origin.y < -(container.frame.height * percentage) * 0.8 {
                        dismiss()
                    } else {
                        returnToOrigin(CGPoint(x: 0, y: 0))
                    }
                }
            } else {
                returnToOrigin(CGPoint(x: 0, y: 0))
            }
        case .right:
            if origin.x >= 0.0 && sender.velocity(in: presentedViewController.view).x > 0.0 {
                presentedViewController.view.frame.origin.x = translationRight.x
                setAlpha(1.0 - (translation.x / presentedViewController.view.frame.width))
                if sender.state == .ended {
                    if origin.x > container.frame.width * 0.8 {
                        dismiss()
                    } else {
                        returnToOrigin(CGPoint(x: container.frame.width - (container.frame.width * percentage), y: 0))
                    }
                }
            } else {
                returnToOrigin(CGPoint(x: container.frame.width - (container.frame.width * percentage), y: 0))
            }
        case .left:
            if origin.x <= 0.0 && sender.velocity(in: presentedViewController.view).x < 0.0 {
                presentedViewController.view.frame.origin.x = translation.x
                setAlpha(1.0 + (translation.x / presentedViewController.view.frame.width))
                if sender.state == .ended {
                    if origin.x < -(container.frame.width * percentage) * 0.8 {
                        dismiss()
                    } else {
                        returnToOrigin(CGPoint(x: 0, y: 0))
                    }
                }
            } else {
                returnToOrigin(CGPoint(x: 0, y: 0))
            }
        }
        
    }
    
    private func returnToOrigin(_ origin: CGPoint) {
        presentingViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.presentedViewController.view.frame.origin = CGPoint(x: origin.x, y: origin.y)
            self.setAlpha(1.0)
            self.presentingViewController.view.layoutIfNeeded()
        }
    }
    
    private func setAlpha(_ alpha: CGFloat) {
        dimmView?.alpha = alpha
        blurView?.alpha = alpha

    }
    
    override func containerViewWillLayoutSubviews() {
        let container = frameOfPresentedViewInContainerView
        switch direction {
        case .bottom:
            presentedView?.frame = CGRect(x: 0, y: container.height - (container.height * percentage), width: container.width, height: (container.height * percentage))
        case .top:
            presentedView?.frame = CGRect(x: 0, y: 0, width: container.width, height: (container.height * percentage))
        case .right:
            presentedView?.frame = CGRect(x: container.width - (container.width * percentage), y: 0, width: container.width * percentage, height: container.height)
        case .left:
             presentedView?.frame = CGRect(x: 0, y: 0, width: container.width * percentage, height: container.height)
        }
    }
    
    override func presentationTransitionWillBegin() {

        if backgroundStyle == .dimmed {
            dimmView?.frame = self.containerView!.bounds
            dimmView?.alpha = 0
            containerView?.insertSubview(dimmView!, at: 0)
        } else {
            blurView?.frame = self.containerView!.bounds
            blurView?.alpha = 0
            containerView?.insertSubview(blurView!, at: 0)
        }
        
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: {[weak self] (_) -> Void in
            self?.setAlpha((self?.dimViewAlphaMax)!)
        })
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentedViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: {[weak self] (_) -> Void in
            self?.setAlpha(0)
        })
    }
    
    @objc func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
}

class TransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var percentage: CGFloat
    var duration: Double
    var transition: PresentationStatus
    var direction: Direction
    
    init(percentage: CGFloat, transition: PresentationStatus, duration: Double, direction: Direction) {
        self.percentage = percentage
        self.transition = transition
        self.duration = duration
        self.direction = direction
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
            
            animateIn(container: container, fromView: fromView, toView: toView, transitionContext: transitionContext)
 
        case .dismiss:
            
            animateOut(container: container, fromView: fromView, toView: toView, transitionContext: transitionContext)
        }
    }
    
    private func animateOut(container: UIView, fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
          
                switch self.direction {
                case .top:
                    fromView.frame.origin.y = -(container.frame.height * self.percentage)
                case .bottom:
                    fromView.frame.origin.y = fromView.bounds.height + (toView.frame.height - (container.frame.height * self.percentage))
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
            
            switch self.direction {
            case .top:
                toView.frame.origin.y += container.frame.height * self.percentage
            case .bottom:
                toView.frame.origin.y -= container.frame.height * self.percentage
            case .left:
                toView.frame.origin.x += container.frame.width * self.percentage
            case .right:
                toView.frame.origin.x -= toView.frame.width * self.percentage
            }
            
            }, completion: { (completion) in
                transitionContext.completeTransition(!(transitionContext.transitionWasCancelled))
        })
    }
}
