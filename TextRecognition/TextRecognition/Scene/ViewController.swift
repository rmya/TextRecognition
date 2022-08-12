//
//  ViewController.swift
//  TextRecognition
//
//  Created by Rumeysa TAN on 12.08.2022.
//

import UIKit
import Vision
import Photos

class ViewController: UIViewController {
    
    private let cameraButton : UIButton = {
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.tintColor = .white
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.setTitle(" Camera ", for: .normal)
        button.layer.cornerRadius = 15.0
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()
    
    private let libraryButon : UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .purple
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "photo.fill.on.rectangle.fill"), for: .normal)
        button.setTitle(" Library ", for: .normal)
        button.layer.cornerRadius = 15.0
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)
        return button
    }()
    
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        return stackView
    }()
    
    private let recognizeButton : UIButton = {
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.tintColor = .white
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "doc.text.viewfinder"), for: .normal)
        button.setTitle(" Recognize Text ", for: .normal)
        button.layer.cornerRadius = 15.0
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.addTarget(self, action: #selector(sendImage), for: .touchUpInside)
        return button
    }()
    
    private let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .systemGray5
        label.textAlignment = .center
        return label
    }()
    
    private let recognizeImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    @objc func openCamera(sender: UIButton!){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self

        // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
           print("Camera is available")
            picker.sourceType = .camera
        } else {
           print("Camera is not available so we will use photo library instead")
            picker.sourceType = .photoLibrary
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    var imageViewController = UIImagePickerController()
    
    @objc func openLibrary(sender: UIButton){
        self.imageViewController.sourceType = .photoLibrary
        self.present(self.imageViewController, animated: true, completion: nil)
    }
    func checkPermissions(){
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized{
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in ()
                
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
        }else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            print("Access granted to use photo library.")
        }else {
            print("We don't have access to your photos.")
        }
    }
    
    @objc func sendImage(){
        recognizeText(image: recognizeImage.image)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkPermissions()
        imageViewController.delegate = self
        
        view.addSubview(label)
        view.addSubview(recognizeImage)
        view.addSubview(stackView)
        stackView.addArrangedSubview(cameraButton)
        stackView.addArrangedSubview(libraryButon)
        view.addSubview(recognizeButton)
        
        recognizeText(image: recognizeImage.image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        stackView.frame = CGRect(x: 20, y: view.safeAreaInsets.top,
                                width: view.frame.size.width-40,
                                height: 60)
        
        recognizeImage.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 60,
                                      width: view.frame.size.width-40,
                                      height: view.frame.size.width-40)
        
        recognizeButton.frame = CGRect(x: 20, y: view.frame.size.width + view.safeAreaInsets.top,
                                       width: view.frame.size.width-40,
                                       height: 60)
        
        label.frame = CGRect(x: 20, y: view.frame.size.width + view.safeAreaInsets.top + 70,
                            width: view.frame.size.width-40,
                            height: 250)
    }

    private func recognizeText(image: UIImage?) {
        
        guard let cgImage = image?.cgImage else {
            print("fatal error could not cgimage")
            return
        }
        
        //Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        //Request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else{
                return
            }
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            
            DispatchQueue.main.async {
                self?.label.text  = text
            }
        }
        
        //Process Request
        do{
            try handler.perform([request])
        }catch{
            print(error.localizedDescription)
        }

    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if picker.sourceType == .photoLibrary{
            recognizeImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }else{
            recognizeImage.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        dismiss(animated: true, completion: nil)
    }
}
