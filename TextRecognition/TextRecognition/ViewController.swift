//
//  ViewController.swift
//  TextRecognition
//
//  Created by Rumeysa TAN on 12.08.2022.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    private let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .systemGray5
        label.textAlignment = .center
        return label
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "talk2")
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(imageView)
        
        recognizeText(image: imageView.image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: 20, y: view.safeAreaInsets.top,
                                 width: view.frame.size.width-40,
                                 height: view.frame.size.width-40)
        
        label.frame = CGRect(x: 20, y: view.frame.size.width + view.safeAreaInsets.top,
                             width: view.frame.size.width-40,
                             height: 200)
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

