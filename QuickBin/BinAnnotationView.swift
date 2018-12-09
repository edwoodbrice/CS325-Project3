//
//  BinAnnotationView.swift
//  QuickBin
//
//  Created by User on 12/5/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit
import MapKit

protocol BinAnnotationViewActionDelegate : NSObjectProtocol {
    func directionButtonTapped(annotationView: BinAnnotationView, actionSender: UIButton)
    func reportEditButtonTapped(annotationView: BinAnnotationView, actionSender: UIButton)
}
class BinAnnotationView: MKAnnotationView {

    weak var delegate: BinAnnotationViewActionDelegate?
    var binAnnotation: Bin {
        return self.annotation as! Bin
    }
    override var annotation: MKAnnotation? {
        willSet {
            if let newValue = newValue as? Bin, self.detailCalloutAccessoryView != nil {
                self.image = newValue.annotationImage
                self.binImage = newValue.image
                self.subtitleForBin = newValue.subtitle
                // report button is possibly nil but fine as it will inited in customInit.
                self.reportButton?.setTitle(self.binAnnotation.builtIn ? "Report" : "Edit", for: .normal)
                updateViewHeight()
            }
        }
    }
    private lazy var heightConstraint: NSLayoutConstraint = {
        let stackView = self.detailCalloutAccessoryView as! UIStackView
        return stackView.heightAnchor.constraint(equalToConstant: stackView.subviews.reduce(0) { (result, view) -> CGFloat in
            result + view.frame.size.height
        })
    }()

    private func updateViewHeight() {
        let stackView = self.detailCalloutAccessoryView as! UIStackView
        self.heightConstraint.constant = stackView.subviews.reduce(0) { (result, view) -> CGFloat in
            result + view.frame.size.height
        }
//        print("Updated: %.02f", self.heightConstraint.constant)
    }

    private weak var descriptionLabel: UILabel!
    private weak var imageView: UIImageView!

    private weak var reportButton: UIButton!


    private let viewSize = CGSize.init(width: 200, height: 200)

    private lazy var imageViewConstraint: (NSLayoutConstraint, NSLayoutConstraint) =
        (self.imageView.widthAnchor.constraint(equalToConstant: self.viewSize.width),
        self.imageView.heightAnchor.constraint(equalToConstant: self.viewSize.width * 0.75))

    var binImage: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
            if newValue != nil {
                self.imageView.frame = .init(origin: .zero, size: .init(width: viewSize.width, height: viewSize.width * 0.75))
                self.imageViewConstraint.0.isActive = true
                self.imageViewConstraint.1.isActive = true
                self.imageView.isHidden = false
            }
            else {
                self.imageViewConstraint.0.isActive = false
                self.imageViewConstraint.1.isActive = false
                self.imageView.frame = .zero
                self.imageView.isHidden = true
            }
        }
    }
    var subtitleForBin: String? {
        get {
            return self.descriptionLabel.text
        }
        set {
            self.descriptionLabel.text = newValue
            if !(newValue?.isEmpty ?? false) {
                self.descriptionLabel.sizeToFit()
                self.descriptionLabel.frame.size = self.descriptionLabel.sizeThatFits(viewSize)
                self.descriptionLabel.isHidden = false
            }
            else {
                self.descriptionLabel.frame.size = .zero
                self.descriptionLabel.isHidden = true
            }
        }
    }
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        customInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    private func customInit() {
        self.canShowCallout = true
        self.calloutOffset = CGPoint(x: 0, y: -2.5)

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = description
        descriptionLabel.font = descriptionLabel.font.withSize(12)
        self.descriptionLabel = descriptionLabel

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        self.imageView = imageView


//        var subviews: [UIView] = []
//        let descriptionLabel = UILabel(frame: .zero)
//        descriptionLabel.numberOfLines = 0
//        descriptionLabel.text = description
//        descriptionLabel.font = descriptionLabel.font.withSize(12)
//        self.descriptionLabel = descriptionLabel
//        subviews.append(descriptionLabel)

//        if let image = self.binAnnotation.image {
            // use 4:3 as standard ratio

//            subviews.append(imageView)
//        self.imageView = imageView
//        self.imageView.isHidden = true
//        }
        let buttonHeight: CGFloat = 30

        let buttonView = UIView(frame: .init(origin: .zero, size: .init(width: viewSize.width, height: buttonHeight)))
//        buttonView.backgroundColor = .gray

        let navigationButton = UIButton(type: .custom)
        navigationButton.frame = .init(origin: .zero, size: .init(width: viewSize.width/2, height: buttonHeight))
        navigationButton.setTitle("Direction", for: UIControlState.normal)
        navigationButton.setTitleColor(.blue, for: UIControlState.normal)
        navigationButton.titleLabel?.font = navigationButton.titleLabel?.font.withSize(12)
        navigationButton.addTarget(self, action: #selector(navigationButton(sender:)), for: .touchUpInside)

//        navigationButton.backgroundColor = .red
//        navigationButton.addTopBorder(color: .gray, width: 1)

        let reportButton = UIButton(type: .custom)
        reportButton.frame = .init(origin: .init(x: viewSize.width/2, y: 0), size: .init(width: viewSize.width/2, height: buttonHeight))
        reportButton.setTitle(self.binAnnotation.builtIn ? "Report" : "Edit", for: UIControlState.normal)
        reportButton.titleLabel?.font = reportButton.titleLabel?.font.withSize(12)
        reportButton.setTitleColor(.red, for: UIControlState.normal)
        reportButton.addTarget(self, action: #selector(reportButton(sender:)), for: .touchUpInside)
        self.reportButton = reportButton
//        reportButton.backgroundColor = .blue

//        reportButton.addTopBorder(color: .gray, width: 1)
//        reportButton.addLeftBorder(color: .gray, width: 1)

        buttonView.addSubview(navigationButton)
        buttonView.addSubview(reportButton)
//        buttonView.translatesAutoresizingMaskIntoConstraints = false

//        subviews.append(buttonView)

        let detailsStackView = UIStackView(arrangedSubviews: [self.descriptionLabel, self.imageView, buttonView])
        buttonView.heightAnchor.constraint(equalToConstant: buttonView.frame.size.height).isActive = true
//        subviews.forEach { view in
//            if (view is UIImageView == false) {
//            }
//        }
//        let constraints = [buttonView.topAnchor.constraint(equalTo: detailsStackView.topAnchor),
//                           buttonView.leadingAnchor.constraint(equalTo: detailsStackView.leadingAnchor),
//                           buttonView.trailingAnchor.constraint(equalTo: detailsStackView.trailingAnchor),
//                           buttonView.bottomAnchor.constraint(equalTo: detailsStackView.bottomAnchor)
//                           ]
//        NSLayoutConstraint.activate(constraints)


        detailsStackView.widthAnchor.constraint(equalToConstant: viewSize.width).isActive = true
//        detailsStackView.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true

        detailsStackView.axis = .vertical
//        detailsStackView.autoresizingMask = .flexibleHeight
        // = CGRect(frame: CGRect(origin: .zero, size: viewSize))
        self.detailCalloutAccessoryView = detailsStackView
////
//        let widthConstraint = NSLayoutConstraint(item: self.detailCalloutAccessoryView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize.width)
//        self.detailCalloutAccessoryView?.addConstraint(widthConstraint)
//        let heightConstraint = NSLayoutConstraint(item: self.detailCalloutAccessoryView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
//        self.detailCalloutAccessoryView?.addConstraint(heightConstraint)
////
////
//
//        self.detailCalloutAccessoryView?.addSubview(navigationButton)
//        self.detailCalloutAccessoryView?.addSubview(reportButton)

    }
    @objc private func navigationButton(sender: UIButton) {
        self.delegate?.directionButtonTapped(annotationView: self, actionSender: sender)
    }
    @objc private func reportButton(sender: UIButton) {
        self.delegate?.reportEditButtonTapped(annotationView: self, actionSender: sender)
    }
}
/*- (void) addTopBorderOnView: (UIView *) view WithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    UIView *border = [UIView new];
    border.backgroundColor = color;
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    border.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
    [view addSubview:border];
}
- (void)addLeftBorderOnView: (UIView *) view WithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    UIView *border = [UIView new];
    border.backgroundColor = color;
    border.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
    border.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [view addSubview:border];
}*/
extension UIView {
    func addTopBorder(color: UIColor, width: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame.size = .init(width: self.frame.size.width, height: width)
        self.addSubview(border)
    }
    // unused
    func addBottomBorder(color: UIColor, width: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = .init(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.addSubview(border)
    }
    func addLeftBorder(color: UIColor, width: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        border.frame.size = .init(width: width, height: self.frame.size.height)
        self.addSubview(border)
    }
}
