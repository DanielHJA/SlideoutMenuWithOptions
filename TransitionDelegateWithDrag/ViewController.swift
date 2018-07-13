//
//  ViewController.swift
//  TransitionDelegateWithDrag
//
//  Created by Daniel Hjärtström on 2018-06-30.
//  Copyright © 2018 Daniel Hjärtström. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var transitionManager: TransitionManager = {
        return TransitionManager(percentage: 0.8, duration: 2.0, tapToDismiss: true, direction: .top, backgroundStyle: .blurred, shouldMinimizeBackGround: true, pushesBackground: false)
    }()
    
    var menuTransitionManager: TransitionManager = {
        return TransitionManager(percentage: 0.6, duration: 0.5, tapToDismiss: true, direction: .left, backgroundStyle: .none, shouldMinimizeBackGround: false, pushesBackground: true)
    }()
    
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(presentMenu(_:)))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "becky"))
        imageView.frame = view.bounds
        view.addSubview(imageView)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    @objc private func presentModally(_ sender: UIButton) {
        let vc = ModalViewController()
        vc.transitioningDelegate = transitionManager
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func presentMenu(_ sender: UIBarButtonItem) {
        let vc = MenuViewController()
        vc.transitioningDelegate = menuTransitionManager
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

