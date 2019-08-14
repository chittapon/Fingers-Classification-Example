//
//  ViewController.swift
//  FingersClassificationExample
//
//  Created by Chittapon Thongchim on 13/8/2562 BE.
//  Copyright © 2562 Appsynth. All rights reserved.
//

import UIKit
import TensorFlowLite

class ViewController: UIViewController {

    @IBOutlet weak var inputImageView: UIImageView!
    @IBOutlet weak var outputLabel: UILabel!
    
    let modelDataHandler = ModelDataHandler(modelFileInfo: Model.modelInfo)
    let dataSet = DataSet.makeImageDataSet()
    lazy var dataSetCount = dataSet.count
    var imageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: dataSet[imageIndex])
        inputImageView.image = image
        outputLabel.text = predict(image: image)
    }
    
    private func predict(image: UIImage?) -> String {
        guard let image = image, let results = modelDataHandler?.runModel(onImage: image),
            let inference = results.inferences.first else {
            return "Unknown result"
        }
        return inference.label
    }

    @IBAction func previousImage(_ sender: Any) {
        guard imageIndex > 0 else { return }
        imageIndex -= 1
        let image = UIImage(named: dataSet[imageIndex])
        inputImageView.image = image
        outputLabel.text = predict(image: image)
    }
    
    @IBAction func nextImage(_ sender: Any) {
        guard imageIndex < dataSetCount else { return }
        imageIndex += 1
        let image = UIImage(named: dataSet[imageIndex])
        inputImageView.image = image
        outputLabel.text = predict(image: image)
    }
}

