//
//  MenuViewController.swift
//  TransitionDelegateWithDrag
//
//  Created by Daniel Hjärtström on 2018-07-02.
//  Copyright © 2018 Daniel Hjärtström. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let temp = UITableView()
        temp.delegate = self
        temp.dataSource = self
        temp.tableFooterView = UIView()
        temp.backgroundColor = UIColor.white
        temp.register(MenuTableviewCell.self, forCellReuseIdentifier: MenuTableviewCell.identifier) 
        view.addSubview(temp)
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        temp.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        temp.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        temp.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        return temp
    }()
    
    var items: [MenuModel] = [
        MenuModel(title: "One", endPoint: .one),
        MenuModel(title: "Two", endPoint: .two),
        MenuModel(title: "Three", endPoint: .three)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableviewCell.identifier, for: indexPath) as? MenuTableviewCell else { return UITableViewCell() }
       cell.setupWithMenuModel(items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let presenter = presentingViewController as? UINavigationController else { return }
        dismiss(animated: true, completion: nil)

        switch items[indexPath.row].endPoint {
            case .one:
                presenter.pushViewController(OneViewController(), animated: true)
            case .two:
               presenter.pushViewController(TwoViewController(), animated: true)
            case .three:
                break
        }
    }
    
}
