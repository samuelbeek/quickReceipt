//
//  ViewController.swift
//  quickReceipt
//
//  Created by Samuel Beek on 13-06-14.
//  Copyright (c) 2014 subtiel. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DBRestClientDelegate {
   
    //properties:
    var restClient: DBRestClient = DBRestClient()
    var captureSession: AVCaptureSession = AVCaptureSession()
    var device: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    var viewLayer: CALayer = CALayer()
    @IBOutlet var cameraView: UIView
    
    
    override func viewDidLoad() {
        println("viewDidLoad")

        //setting devices
        
        var error: NSErrorPointer = nil
        
        var input: AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error: error) as AVCaptureDeviceInput
        
        if input == nil {
            println("something went wrong")
        }
        
        var output:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        output.videoSettings = nil
        var queue: dispatch_queue_t = dispatch_queue_create("MyQue", nil)
        //queue that stuff here
        
        
        
        //setting delegates
        restClient = DBRestClient(session: DBSession.sharedSession())
        restClient.delegate = self
        
        //making the previewlayer the same size as the cameraView
        viewLayer.frame = cameraView.frame
        viewLayer.backgroundColor = CGColorCreateGenericRGB(0.5, 0.7,0.2,0.9)
        
//        cameraView.layer.addSublayer(viewLayer)
        
        //set camera
        if captureSession.canSetSessionPreset(AVCaptureSessionPreset1280x720){
            println("photo is possible")
            captureSession.sessionPreset = AVCaptureSessionPreset1280x720
            
            var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraView.layer.addSublayer(captureVideoPreviewLayer)
            captureSession.addInput(input)
            captureSession.addOutput(output)

            
        } else {
            println("can't take no photos")
        }

        captureSession.startRunning()
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    
    //MARK: dropbox calls
    func restClient(client: DBRestClient, uploadedFile desPath:NSString, from srcPath:NSString, metadata:DBMetadata){
        println("File uploaded succesfully to Path: %@", metadata.path)
        
    }
    
    func restClient(client: DBRestClient, uploadFailedWithError error:NSError){
        
        println("File upload failed with error: %@", error)
        
    }
    
    //function



}

