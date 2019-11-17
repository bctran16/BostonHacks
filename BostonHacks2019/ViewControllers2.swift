//
//  ViewControllers2.swift
//  BostonHacks2019
//
//  Created by Bang Tran on 11/16/19.
//  Copyright © 2019 Bang Tran. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO
import AVFoundation


class ViewControllers2: UIViewController {

    
   
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let synthesizer  = AVSpeechSynthesizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    func detectImageContent(){
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: Resnet50().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-o;ff".
                    return String(format : "%@", classification.identifier)
                }
                self.classificationLabel.adjustsFontSizeToFitWidth = true
                self.classificationLabel.text = descriptions.joined(separator: "\n")
                self.speech(text: classifications.first!.identifier)
            
                
            }
        }
    }
    
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        
       
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    @IBAction func chooseImage(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()

        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
            photoSourcePicker.addAction(choosePhoto)
            photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
            
            present(photoSourcePicker, animated: true)
        }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self// as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = sourceType
        self.present(picker, animated: true)
        imageView.image = picker as? UIImage
        print("present photo picker being called")
    }
    
    func speech(text:String){
          let utterance = AVSpeechUtterance(string: text)
          self.synthesizer.speak(utterance)
      }

    
//     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
//        picker.dismiss(animated: true)
//        print("image control picker being called")
//        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
//        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else {
//                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
//        }
//        imageView.image = selectedImage
//        updateClassifications(for: selectedImage)
//        }
//
    }
extension ViewControllers2: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
// MARK: - Handling Image Picker Selection

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    print("image control picker being called")
    picker.dismiss(animated: true)

    // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    imageView.image = image
    updateClassifications(for: image)
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
