//
//  DetailViewController.swift
//  Sharpener
//
//  Created by Inti Guo on 2/23/16.
//  Copyright © 2016 Inti Guo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var docRef: SPSharpenerDocumentRef?
    var document: SPSharpenerDocument? {
        didSet {
            if document?.dataJson != nil {
                store = SPGeometricsStore(json: document!.dataJson!)
                document?.closeWithCompletionHandler(nil)
            }
        }
    }
    var store: SPGeometricsStore? {
        didSet {
            guard store != nil else { return }
            for s in store!.shapeStore {
                refineView.appendShapeLayerForGeometric(s)
            }
            for l in store!.lineStore {
                refineView.appendShapeLayerForGeometric(l)
            }
        }
    }
    
    @IBOutlet weak var navigationBar: SPDetailNavigationBar! {
        didSet {
            navigationBar.buttonDelegate = self
        }
    }
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentSize = Preference.vectorizeSize
            scrollView.maximumZoomScale = 1.2
            
        }
    }
    @IBOutlet weak var toolBar: SPDetailToolBar! {
        didSet {
            let tapL = UITapGestureRecognizer(target: self, action: "shouldDeleteDocument")
            toolBar.deleteButton.addGestureRecognizer(tapL)
            let tapR = UITapGestureRecognizer(target: self, action: "shouldShareDocument")
            toolBar.shareButton.addGestureRecognizer(tapR)
        }
    }
    var refineView: SPRefineView! {
        didSet {
            scrollView.addSubview(refineView)
            refineView.frame.size = Preference.vectorizeSize
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refineView = SPRefineView()
        let screenSize = UIScreen.mainScreen().bounds.size
        scrollView.minimumZoomScale = screenSize.width / Preference.vectorizeSize.width
        scrollView.zoomScale = screenSize.width / Preference.vectorizeSize.width
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard docRef != nil else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        let fileHandler = SPSharpenerFileHandler()
        fileHandler.fetchDocumentForRef(docRef!) { d in
            self.document = d
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteCurrentDocument() {
        let url = docRef!.url
        let fileManager = NSFileManager()
        do {
            try fileManager.removeItemAtURL(url)
            performSegueWithIdentifier("UnwindWithFileDeleted", sender: self)
        } catch {
            print("unable to remove file")
        }
    }
    
    func shouldDeleteDocument() {
        deleteCurrentDocument()
        
    }
    func shouldShareDocument() {
        
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return refineView
    }
}

extension DetailViewController: SPNavigationBarDelegate {
    func navigationBarButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}