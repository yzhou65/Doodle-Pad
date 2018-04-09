//
//  ViewController.swift
//  Doodle
//
//  Created by Yue Zhou on 1/19/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    // MARK: - subviews and fields
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var hud: UILabel!
    @IBOutlet weak var blackButton: UIButton!
    
    /** last selection of path color */
    var lastPathColor: UIColor?
    
    /** last selected button */
    var lastColorButton: UIButton?
    
    
    // MARK: - tabbar buttons
    @IBAction func clear(_ sender: Any) {
        self.drawView.clear()
    }
    
    @IBAction func undo(_ sender: Any) {
        self.drawView.undo()
    }
    
    @IBAction func eraser(_ sender: UIBarButtonItem) {
        self.lastColorButton?.isSelected = false
        
//        let eraser: UIButton = sender.customView as! UIButton
//        if !eraser.isHighlighted {
//            eraser.isHighlighted = true
//            self.lastPathColor = self.drawView.pathColor
//            self.drawView.pathColor = UIColor.white
//        }
//        else {
//            eraser.isHighlighted = false
//            self.drawView.pathColor = self.lastPathColor
//        }
        self.drawView.pathColor = UIColor.white
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        // system's image picker controller
        let pickerVC: UIImagePickerController = UIImagePickerController();
        
        // set picker controller's sourceType
        // UIImagePickerControllerSourceTypePhotoLibrary
        // UIImagePickerControllerSourceTypeSavedPhotosAlbum
        pickerVC.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        
        // set delegate
        pickerVC.delegate = self;
        
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    
    @IBAction func save(_ sender: Any) {
        // save the screen
        // begin context
        UIGraphicsBeginImageContextWithOptions(self.drawView.bounds.size, false, 0)
        let ctx: CGContext! = UIGraphicsGetCurrentContext()
        
        // render
        self.drawView.layer.render(in: ctx)
        
        // get the image from context
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // end context
        UIGraphicsEndImageContext()
        
        // save the content on the canvas to PhotosAlbum
        // note: #selector()'s method name cannot be randomly named, must be "image:didFinishSavingWithError:contextInfo:"
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    /**
     * Called when the user finishes picking an image
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // get the image picked by user
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage;
        
        let iv = ImageAdjustView(frame: self.drawView.bounds)
        
        // handle the image
        iv.image = image;
        
        iv.handleCompletion = { (newImage: UIImage) in
            self.drawView.image = newImage
        }
        
        // add imageHandleView to drawView
        self.drawView.addSubview(iv)
        
        
        // dismiss
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     * Called when image saving is successful.
     * This method must be implemented.
     */
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        print("Image saved.")
        
        // round corners for hud
        self.hud.layer.cornerRadius = 10
        self.hud.layer.masksToBounds = true
        
        UIView.animate(withDuration: 2.0, animations: { 
            self.hud.alpha = 1.0
        }) { (_) in
            UIView.animate(withDuration: 2.0, animations: { 
                self.hud.alpha = 0.001
            })
        }
    }
    
    
    // MARK: - bottom tools
    
    @IBAction func colorChange(_ sender: UIButton) {
        self.drawView.pathColor = sender.backgroundColor
        
        sender.isSelected = !sender.isSelected
        if self.lastColorButton != nil {
            if self.lastColorButton!.isSelected {
                self.lastColorButton!.isSelected = false
            }
        }
        self.lastColorButton = sender
    }
    
    @IBAction func valueChange(_ sender: UISlider) {
        self.drawView.lineWidth = CGFloat(sender.value)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blackButton.isSelected = true
        self.lastColorButton = self.blackButton
    }
}

