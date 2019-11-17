//
//  ViewController.swift
//  BostonHacks2019
//
//  Created by Bang Tran on 11/16/19.
//  Copyright © 2019 Bang Tran. All rights reserved.
//

import UIKit
import AVKit
import Vision
import AVFoundation


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
//    let imagePicker = UIImagePickerController()
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let synthesizer  = AVSpeechSynthesizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // here is where we start up the camera
        // for more details visit: https://www.letsbuildthatapp.com/course_video?id=1252
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
        //        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
        setupIdentifierConfidenceLabel()
    }
    
    fileprivate func setupIdentifierConfidenceLabel() {
        view.addSubview(identifierLabel)
        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    func speech(text:String){
        let utterance = AVSpeechUtterance(string: text)
        self.synthesizer.speak(utterance)
    }
    
  
    var name: String = "" {
        didSet {
            self.speech(text: name)
        }
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        

        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
        
            
            
            DispatchQueue.main.async {
                self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                if (firstObservation.confidence >= 0.5 && firstObservation.identifier != self.name){
                    self.name = firstObservation.identifier
                }
                
            }
            
        
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    @IBAction func Repeat(_ sender: Any) {
        self.speech(text: name)
    }
    
    
}
