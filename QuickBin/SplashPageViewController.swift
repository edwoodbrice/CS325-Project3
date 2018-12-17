//
//  SplashPageViewController.swift
//  QuickBin
//
//  Created by User on 12/5/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit

class SplashPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var finishedBlock: (() -> Void)!
    private lazy var totalTutorialVC = [
        generateTutorialImageVCWithImage(0, description: "Welcome to QuickBin! QuickBin is a convenient app to help you find the nearest waste receptacle. Swipe to the next page to go over QuickBin's tutorial."),
        generateTutorialImageVCWithImage(1, description: "Tapping one of the three colored buttons will locate the nearest composting bin, recycling bin or trash bin, respectively."),
        generateTutorialImageVCWithImage(2, description: "Tap the pins to see details about a particular bin on the map."),
        generateTutorialImageVCWithImage(3, description: "You can also add a bin to the map! The pin will be striped to indicate that it was made by you. It will also match the color of the bin type."),
        {
            let vc = generateTutorialImageVCWithImage(4, description: "You're now ready to use QuickBin! Tap the screen to continue.")
            vc.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(finishedTutorial(_:))))
            return vc
        }()
    ]

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? TutorialImageViewController, viewController.indexInTutorial  > 0 else {
            return nil
        }
        return self.totalTutorialVC[viewController.indexInTutorial - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? TutorialImageViewController, viewController.indexInTutorial + 1 < self.totalTutorialVC.count else {
            return nil
        }
        return self.totalTutorialVC[viewController.indexInTutorial + 1]
    }

    private func generateTutorialImageVCWithImage(_ imageIndex: Int, description: String?) -> TutorialImageViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialImageVC") as! TutorialImageViewController
        vc.loadViewIfNeeded()
        vc.indexInTutorial = imageIndex
        vc.imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: "\(imageIndex)", ofType: "png", inDirectory: "Tutorial")!)
        vc.descriptionLabel.text = description
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([self.totalTutorialVC.first!], direction: .forward, animated: true, completion: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc private func finishedTutorial(_ sender: UITapGestureRecognizer) {
        finishedBlock()
        self.dismiss(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
