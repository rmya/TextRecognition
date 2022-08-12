//
//  ViewController.swift
//  TextRecognition
//
//  Created by Rumeysa TAN on 12.08.2022.
//

import UIKit
import Vision

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
        return button
    }()
    
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        return stackView
    }()
    
    private let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .systemGray5
        label.textAlignment = .center
        return label
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "talk2")
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(stackView)
        stackView.addArrangedSubview(cameraButton)
        stackView.addArrangedSubview(libraryButon)
        
        recognizeText(image: imageView.image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        stackView.frame = CGRect(x: 20, y: view.safeAreaInsets.top,
                                 width: view.frame.size.width-40,
                                 height: 60)
        
        imageView.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 60,
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

