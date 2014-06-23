//
//  ViewController.swift
//  quickReceipt
//
//  Created by Samuel Beek on 13-06-14.
//  Copyright (c) 2014 subtiel. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DBRestClientDelegate {
   
    //properties:
    
    @IBOutlet var imageView : UIImageView = nil
    
    
    var restClient: DBRestClient = DBRestClient()
    var session: AVCaptureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("viewDidLoad")

        //setting delegates
        restClient = DBRestClient(session: DBSession.sharedSession())
        restClient.delegate = self
        
        //set camera
        if session.canSetSessionPreset(AVCaptureSessionPresetPhoto){
            println("photo is possible")
            session.sessionPreset = AVCaptureSessionPresetPhoto
        } else {
            println("can't take no photos")
        }

        session.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func takePhoto(sender : AnyObject) {
        println("takePhoto")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
//            imagePicker.mediaTypes = [kUTTypeImage]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        
    }
    
    
    @IBAction func didPressLink(){
        println("app is linked")
        
        if !DBSession.sharedSession().isLinked() {
            
            println("no shared session")
            
            DBSession.sharedSession().linkFromController(self)
        } else {
            
            println("attem[t to create a file")
            
            var text = "Hello World"
            var filename = "working-draft.txt"
            
            // Write a file to the local documents directory
            let localDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            var localPath = localDir.stringByAppendingPathComponent(filename)
            text.writeToFile(localPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            
            println("local file created")
            
            // Upload file to Dropbox
            let destDir = "/" as String
            self.restClient.uploadFile(filename, toPath: destDir, withParentRev:nil, fromPath: localPath)
            
            println("file seems to be uploaded")
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        
        let selectedImage : UIImage = image
        
        self.imageView.image = image
        picker.dismissModalViewControllerAnimated(true)
    }
    
    //MARK: dropbox calls
    func restClient(client: DBRestClient, uploadedFile desPath:NSString, from srcPath:NSString, metadata:DBMetadata){
        println("File uploaded succesfully to Path: %@", metadata.path)
        
    }
    
    func restClient(client: DBRestClient, uploadFailedWithError error:NSError){
        
        println("File upload failed with error: %@", error)
        
    }



}

