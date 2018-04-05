//
//  ViewController.swift
//  Doodle
//
//  Created by Yue Zhou on 1/19/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    @IBOutlet weak var drawView: DrawView!
    
    
    // MARK: tabbar buttons
    @IBAction func clear(_ sender: Any) {
        self.drawView.clear()
    }
    
    @IBAction func undo(_ sender: Any) {
        self.drawView.undo()
    }
    
    @IBAction func eraser(_ sender: Any) {
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
    
    
    // MARK: UIImagePickerControllerDelegate
    /**
     * Called when the user finishes picking an image
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // get the image picked by user
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage;
        
        // draw the picture onto the canvas
        self.drawView.image = image;
        
        
        // dismiss
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     * Called when image saving is successful.
     * This method must be implemented.
     */
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        print("Image saved.")
    }
    
    
    // MARK: bottom tools
    
    @IBAction func colorChange(_ sender: UIButton) {
        self.drawView.pathColor = sender.backgroundColor
    }
    
    @IBAction func valueChange(_ sender: UISlider) {
        self.drawView.lineWidth = CGFloat(sender.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

