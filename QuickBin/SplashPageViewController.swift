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
        generateTutorialImageVCWithImage(0, description: "Welcome to QuickBin! QuickBin is a convenient app to help you find nearest bin. Scroll to next page to go over this tutorial."),
        generateTutorialImageVCWithImage(1, description: "Tap three buttons at the bottom to locate nearest recycle bin, compost bin and trash bin, respectively."),
        generateTutorialImageVCWithImage(2, description: "Tap pins on the map to see details about bins."),
        generateTutorialImageVCWithImage(3, description: "You can add a bin on the map by yourself! "),
        {
            let vc = generateTutorialImageVCWithImage(4, description: "You has finished the tutorial. Continue by tapping!")
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
