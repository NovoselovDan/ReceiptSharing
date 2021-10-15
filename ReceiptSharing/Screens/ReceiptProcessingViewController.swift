//
//  ReceiptProcessingViewController.swift
//  ReceiptSharing
//
//  Created by Daniil Novoselov on 09.10.2021.
//

import UIKit

class ReceiptProcessingViewController: UIViewController {

    // receipt_mask
    // 255 x 380
    
    private let receiptBgView = UIView()
    
    private let gradientView = Gradient()
    
    private let receiptMaskView: UIView = {
        let imageView = UIImageView(image: .init(named: "receipt_mask"))
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkBackground
        
        let container = UIView()
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 255),
            container.heightAnchor.constraint(equalToConstant: 380),
            container.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
        ])
        
        receiptBgView.backgroundColor = .init(hex: "DADBE9")
        receiptBgView.layer.masksToBounds = true
        container.addSubview(receiptBgView)
        receiptBgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            receiptBgView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            receiptBgView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: receiptBgView.bottomAnchor, constant: 24),
            container.rightAnchor.constraint(equalTo: receiptBgView.rightAnchor, constant: 8)
        ])
        
        container.addSubview(receiptMaskView)
        receiptMaskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            receiptMaskView.widthAnchor.constraint(equalTo: container.widthAnchor),
            receiptMaskView.heightAnchor.constraint(equalTo: container.heightAnchor),
            receiptMaskView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            receiptMaskView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        let topLabel = UILabel()
        topLabel.font = .systemFont(ofSize: 18)
        topLabel.textAlignment = .center
        topLabel.textColor = .white
        topLabel.text = "Распознаём чек"
        view.addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            container.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 64)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if gradientView.superview == nil {
            receiptBgView.addSubview(gradientView)
            gradientView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                gradientView.widthAnchor.constraint(equalToConstant: 210),
                gradientView.heightAnchor.constraint(equalTo: receiptBgView.heightAnchor),
                gradientView.centerYAnchor.constraint(equalTo: receiptBgView.centerYAnchor),
                gradientView.leftAnchor.constraint(equalTo: receiptBgView.leftAnchor, constant: -210)
            ])
        }
        
        gradientView.gradientLayer.removeAllAnimations()
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.repeat]) {
                self.gradientView.transform = .init(translationX: 480, y: 0)
            } completion: { _ in }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.goToSplitVC()
        }
    }
    
    private func goToSplitVC() {
        let splitVC = ReceiptSplitViewController(commandProcessor: Server.shared)
        self.show(splitVC, sender: nil)
    }
}


public class Gradient: UIView {

    private enum Colors {
        static let transparent = UIColor(hex: "9D9FB6")!.withAlphaComponent(0)
        static let opaque = UIColor(hex: "9D9FB6")!
    }
    
    var startColor:   UIColor = Colors.transparent//.black { didSet { updateColors() }}
    var midColor:     UIColor = Colors.opaque
    var endColor:     UIColor = Colors.transparent //.white { didSet { updateColors() }}
    var startLocation: Double =   0.05 { didSet { updateLocations() }}
    var midLocation:   Double =   0.5
    var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    var horizontalMode:  Bool =  true { didSet { updatePoints() }}
    var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [
            startLocation as NSNumber,
            midLocation as NSNumber,
            endLocation as NSNumber
        ]
    }
    func updateColors() {
        gradientLayer.colors = [
            startColor.cgColor,
            midColor.cgColor,
            endColor.cgColor
        ]
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}
