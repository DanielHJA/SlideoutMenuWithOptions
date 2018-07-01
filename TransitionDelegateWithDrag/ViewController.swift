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
        return TransitionManager(percentage: 0.8, duration: 2.0, tapToDismiss: true, direction: .top, backgroundStyle: .blurred)
    }()
    
    private lazy var button: UIButton = {
        let temp = UIButton(frame: CGRect(x: 0, y: 0, width: 50.0, height: 30.0))
        temp.setTitle("Modal", for: .normal)
        temp.center = view.center
        temp.backgroundColor = UIColor.blue
        temp.addTarget(self, action: #selector(presentModally(_:)), for: .touchUpInside)
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "becky"))
        imageView.frame = view.bounds
        view.addSubview(imageView)
        view.insertSubview(button, aboveSubview: imageView)
    }
    
    @objc private func presentModally(_ sender: UIButton) {
        let vc = ModalViewController()
        vc.transitioningDelegate = transitionManager
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

