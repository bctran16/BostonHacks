//
//  Starter.swift
//  BostonHacks2019
//
//  Created by Bang Tran on 11/16/19.
//  Copyright © 2019 Bang Tran. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVKit

class Starter: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    let synthesizer  = AVSpeechSynthesizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        setupIdentifierConfidenceLabel()
        // Do any additional setup after loading the view.
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             imageView.image = image
            guard let ciimage = CIImage(image: image) else {
                return
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true) {
            
        }
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
  func detect(image: CIImage) {
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            DispatchQueue.main.async {
                self.identifierLabel.text = topResult.identifier
                self.speech(text:topResult.identifier)
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
        
    @IBAction func capture(_ sender: UIButton) {
        present(imagePicker, animated: true) {
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
