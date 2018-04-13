//
//  ViewController.swift
//  CameraDemo
//
//  Created by iosdev on 7.4.2018.
//  Copyright © 2018 HuyTrinh. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var uiImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    var image: UIImage?
    
    /// - Tag: MLModelSetup
//    lazy var classificationRequest: VNCoreMLRequest = {
//        do {
//            /*
//             Use the Swift class `MobileNet` Core ML generates from the model.
//             To use a different Core ML classifier model, add it to the project
//             and replace `MobileNet` with that model's generated Swift class.
//             */
//            let model = try VNCoreMLModel(for: MobileNet().model)
//
//            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
//                self?.processClassifications(for: request, error: error)
//            })
//            request.imageCropAndScaleOption = .centerCrop
//            return request
//        } catch {
//            fatalError("Failed to load Vision ML model: \(error)")
//        }
//    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
   
        // Do any additional setup after loading the view, typically from a nib.
        let tapGusture = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTap(_:)))
        uiImageView.addGestureRecognizer(tapGusture)
    }
    

    
    /// - Tag: PerformRequests
//    func updateClassifications(for image: UIImage) {
//        nameLbl.text = "Classifying..."
//
//        let orientation = CGImagePropertyOrientation(image.imageOrientation)
//        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
//            do {
//                try handler.perform([self.classificationRequest])
//            } catch {
//                /*
//                 This handler catches general image processing errors. The `classificationRequest`'s
//                 completion handler `processClassifications(_:error:)` catches errors specific
//                 to processing that request.
//                 */
//                print("Failed to perform classification.\n\(error.localizedDescription)")
//            }
//        }
//    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
//    func processClassifications(for request: VNRequest, error: Error?) {
//        DispatchQueue.main.async {
//            guard let results = request.results else {
//                self.nameLbl.text = "Unable to classify image.\n\(error!.localizedDescription)"
//                return
//            }
//            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
//            let classifications = results as! [VNClassificationObservation]
//
//            if classifications.isEmpty {
//                self.nameLbl.text = "Nothing recognized."
//            } else {
//                // Display top classifications ranked by confidence in the UI.
//                let topClassifications = classifications.prefix(2)
//                let descriptions = topClassifications.map { classification -> String in
//                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
//                   print(String(format: "  (%.2f) %@", classification.confidence, classification.identifier))
//                    return classification.identifier
//                }
//
//                let delimiter = ","
//                let possibleName = descriptions.first ?? ""
//
//                let name = possibleName.components(separatedBy: delimiter)[0]
//                self.nameLbl.text = name
//            }
//        }
//    }
    
    @IBAction func uploadWasTapped(_ sender: Any) {
        if let imgFile = image {
            print("Uploading...")
            //let imageData = UIImagePNGRepresentation(imgFile)!
            let imageData = UIImageJPEGRepresentation(imgFile, 0.9)!
            print(imageData)
            let headers: HTTPHeaders = [
                "Authorization":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YWM5YmUwM2EwMDY2MjAwMTQ2YjEzNzMiLCJpYXQiOjE1MjMxNzA4MjAsImV4cCI6MTUyNDAzNDgyMH0.Ya0RgNe3Q_stXqnyuCxeng6ghnPKhg_78ktVTMRSlw4"
            ]
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData, withName: "photo", fileName: "image.jpg", mimeType: "image/jpeg")
            }, to: "https://fin-recycler.herokuapp.com/api/photos", headers: headers, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                    upload.responseJSON(completionHandler: { (response) in
                        print("Huy")
                        print(response)
                    })
                case .failure(let error):
                    print("Nhung")
                    print(error)
                }
            })
            
        
        } else {
            print("No img found")
        }
    }
    
    
    @objc func imageTap(_ sender: UITapGestureRecognizer) {

        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        uiImageView.image = image
        
        //updateClassifications(for: image!)
    }
}

