//
//  ImageAdjustView.swift
//  Doodle Pad
//
//  Created by Yue Zhou on 4/4/18.
//  Copyright © 2018 Yue Zhou. All rights reserved.
//

import UIKit

private let highlightedDuration = 0.25

class ImageAdjustView: UIView, UIGestureRecognizerDelegate {
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image!
        }
    }
    
    var handleCompletion: ((_ image: UIImage)->Void)?
    
    // MARK: - lazy init
    lazy var imageView: UIImageView = {
        let iv: UIImageView = UIImageView(frame: self.bounds)
        iv.isUserInteractionEnabled = true
        self.addSubview(iv)
        
        // add gestureRecognizers
        // Addition of pan gestureRecognizer to ImageHandleView disables doodling on DrawView before long-pressing image
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: nil))
        
        // All gestures: pan, rotation, pinch and long press
        let pgr = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotate(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        
        // Being the delegate can enable multiple gesture recognizers including pinch and rotation
        pinch.delegate = self
        rotation.delegate = self
        iv.addGestureRecognizer(pgr)
        iv.addGestureRecognizer(rotation)
        iv.addGestureRecognizer(pinch)
        iv.addGestureRecognizer(lp)
        return iv
    }()
    
    // MARK: - Gestures
    @objc private func pan(_ pan: UIPanGestureRecognizer) {
        let transP = pan.translation(in: self.imageView)
        self.imageView.transform = self.imageView.transform.translatedBy(x: transP.x, y: transP.y)
        pan.setTranslation(CGPoint.zero, in: self.imageView)
        pan.delegate = self
    }
    
    @objc private func rotate(_ rgr: UIRotationGestureRecognizer) {
        self.imageView.transform = self.imageView.transform.rotated(by: rgr.rotation)
        rgr.rotation = 0
    }
    
    @objc private func pinch(_ pgr: UIPinchGestureRecognizer) {
        self.imageView.transform = self.imageView.transform.scaledBy(x: pgr.scale, y: pgr.scale)
        pgr.scale = 1
    }
    
    @objc private func longPress(_ lpr: UILongPressGestureRecognizer) {
        if lpr.state == .began {
            // image gestures done
            // highlighted effect
            UIView.animate(withDuration: highlightedDuration, animations: { 
                self.imageView.alpha = 0
            }, completion: { (_) in
                
                UIView.animate(withDuration: highlightedDuration, animations: { 
                    self.imageView.alpha = 1
                }, completion: { (_) in
                    // highlighted effect done
                    // capture the doodle pad
                    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
                    
                    // render and get new Image
                    self.layer.render(in: UIGraphicsGetCurrentContext()!)
                    let newImage = UIGraphicsGetImageFromCurrentImageContext()
                    
                    UIGraphicsEndImageContext()
                    
                    // pass newImage to drawView
                    if let completion = self.handleCompletion {
                        completion(newImage!)
                    }
                    
                    // remove self
                    self.removeFromSuperview()
                })
            })
        }
    }

    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
