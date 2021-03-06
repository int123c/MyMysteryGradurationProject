//
//  TestViewController.swift
//  Sharpener
//
//  Created by Inti Guo on 2/9/16.
//  Copyright © 2016 Inti Guo. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    let scrollView = UIScrollView()
    let processSize = CGSize(width: 375, height: 500)
    let testView = UIView(frame: CGRect(origin: CGPointZero, size: Preference.vectorizeSize))
    let indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var testImage: UIImage?
    
    override func viewDidLoad() {
        view.addSubview(scrollView)
        scrollView.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        let incomeImage = testImage ?? UIImage(named: "LineTrackingTestImage")
        let newImage = incomeImage!.resizedImageToSize(processSize)
        let trippleTap = UITapGestureRecognizer(target: self, action: #selector(TestViewController.back))
        trippleTap.numberOfTapsRequired = 3
        testView.addGestureRecognizer(trippleTap)

        let finder = SPRawGeometricsFinder(medianFilterRadius: 1, thresholdingFilterThreshold: 0.2, lineShapeFilteringFilterAttributes: (5, 4), extractorSize: Preference.vectorizeSize)
        finder.delegate = self
        finder.process(newImage)
    }

    func back() {
        dismissViewControllerAnimated(true, completion: nil)
        SPGeometricsStore.universalStore.removeAll()
    }
}

extension TestViewController: SPRawGeometricsFinderDelegate, SPLineGroupVectorizorVisualTestDelegate {
    func succefullyFoundRawGeometrics() {
        // put results on screen.
        let v = SPLineGroupVectorizor(size: Preference.vectorizeSize)
        v.testDelegate = self
        print(SPGeometricsStore.universalStore.rawStore.count)
        let layer = SPGeometricsStore.universalStore.rawStore[0].shapeLayer
        testView.layer.addSublayer(layer)
        indicatorView.backgroundColor = UIColor.blackColor()
        testView.addSubview(indicatorView)
        scrollView.addSubview(testView)
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: Preference.vectorizeSize.height, height: Preference.vectorizeSize.height)
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = UIScreen.mainScreen().bounds.width / Preference.vectorizeSize.width
        scrollView.zoomScale = UIScreen.mainScreen().bounds.width / Preference.vectorizeSize.width
        dispatch_async(GCD.utilityQueue) {
            v.vectorize(SPGeometricsStore.universalStore.rawStore[0])
        }
    }
    
    func trackingToPoint(point: CGPoint) {
        dispatch_async(GCD.mainQueue) {
            self.indicatorView.frame.origin = point
        }
    }

    func foundMagnetPoint(point: CGPoint) {
        dispatch_async(GCD.mainQueue) {
            let square = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
            square.frame.origin = point
            square.backgroundColor = UIColor.randomColor()
            self.testView.addSubview(square)
        }
    }
}

extension TestViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return testView
    }
}