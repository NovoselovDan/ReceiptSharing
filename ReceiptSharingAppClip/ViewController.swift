//
//  ViewController.swift
//  ReceiptSharingAppClip
//
//  Created by Daniil Novoselov on 08.10.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let label = UILabel()
        label.text = "ReceiptSharingAppClip"
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .largeTitle, compatibleWith: nil)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
        ])
    }


}

