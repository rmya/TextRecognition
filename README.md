# TextRecognition
Text recognition from image with Vision

#### Recognize Text Function
    
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
    
  ##### If the camera does not support, the library opens when you want to take a photo from the camera.
  
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
    


https://user-images.githubusercontent.com/17739433/184451142-b8aa423f-2423-429d-884b-d7c10f7ab887.mov

