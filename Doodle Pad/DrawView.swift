//
//  DrawView.swift
//  Doodle
//
//  Created by Yue Zhou on 1/19/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class DrawView: UIView {

    fileprivate var path: DrawPath?
    var pathColor: UIColor?
    var lineWidth: CGFloat?
    var image: UIImage? {
        didSet {
            self.paths.addObjects(from: [image as Any])
            
            // re-draw
            self.setNeedsDisplay()
        }
    }
    
    fileprivate lazy var paths: NSMutableArray = {
        return NSMutableArray()
    }()
    
//    fileprivate lazy var paths: [DrawPath] = {
    
    /**
     * Clears all paths
     */
    func clear() {
        self.paths.removeAllObjects()
        self.setNeedsDisplay()
    }
    
    /**
     * Undo last path
     */
    func undo() {
        self.paths.removeLastObject()
        self.setNeedsDisplay()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUp()
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setUp()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    /**
     * init
     */
    func setUp() {
        self.lineWidth = 1
        self.pathColor = UIColor.black
        // add pan gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DrawView.panGesture(_:)))
        self.addGestureRecognizer(pan)
    }
    
    func panGesture(_ pan: UIPanGestureRecognizer) {
        // finger's touch point
        let curP: CGPoint = pan.location(in: self)
        
        // beginning point of touch
        if pan.state == UIGestureRecognizerState.began {
            self.path = DrawPath()
            self.path!.lineWidth = self.lineWidth!
            self.path!.pathColor = self.pathColor!
            
            // move to point
            self.path!.move(to: curP)
            
            // save the path
            self.paths.addObjects(from: [path as Any])
        }
        
        // finger keeps moving
        // add line to curP
        path?.addLine(to: curP)
        
        // re-draw
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        for i in 0..<self.paths.count {
            if (self.paths.object(at: i) as AnyObject) is UIImage {
                // draw an image
                let image: UIImage = self.paths.object(at: i) as! UIImage
                image.draw(in: rect)
            }
            else {
                // draw a line
                (self.paths.object(at: i) as! DrawPath).pathColor?.set()
                (self.paths.object(at: i) as! DrawPath).stroke()
            }
        }
    }

}
