//
//  ModelDataHandler.swift
//  FingersClassificationExample
//
//  Created by Chittapon Thongchim on 13/8/2562 BE.
//  Copyright © 2562 Appsynth. All rights reserved.
//

import Foundation
import TensorFlowLite
import CoreImage

/// A result from invoking the `Interpreter`.
struct Result {
    let inferenceTime: Double
    let inferences: [Inference]
}

/// An inference from invoking the `Interpreter`.
struct Inference {
    let confidence: Float
    let label: String
}

/// Information about a model file or labels file.
typealias FileInfo = (name: String, extension: String)

/// Information about the MobileNet model.
enum Model {
    static let modelInfo: FileInfo = (name: "fingers_model", extension: "tflite")
}

/// This class handles all data preprocessing and makes calls to run inference on a given frame
/// by invoking the `Interpreter`. It then formats the inferences obtained and returns the top N
/// results for a successful inference.
class ModelDataHandler {
    
    // MARK: - Internal Properties
    
    // MARK: - Model Parameters
    let inputWidth = 128.0
    let inputHeight = 128.0
    
    // MARK: - Private Properties
    /// List of labels from the given labels file.
    private var labels: [String] = []
    
    /// TensorFlow Lite `Interpreter` object for performing inference on a given model.
    private var interpreter: Interpreter
    
    init?(modelFileInfo: FileInfo) {
        
        let modelFilename = modelFileInfo.name
        
        // Construct the path to the model file.
        guard let modelPath = Bundle.main.path(
            forResource: modelFilename,
            ofType: modelFileInfo.extension
            ) else {
                print("Failed to load the model file with name: \(modelFilename).")
                return nil
        }
        
        do {
            // Create the `Interpreter`.
            interpreter = try Interpreter(modelPath: modelPath)
            // Allocate memory for the model's input `Tensor`s.
            try interpreter.allocateTensors()
        } catch let error {
            print("Failed to create the interpreter with error: \(error.localizedDescription)")
            return nil
        }

        labels = ["0", "1", "2", "3", "4", "5"]
    }
    
    /// Performs image preprocessing, invokes the `Interpreter`, and processes the inference results.
    func runModel(onImage image: UIImage) -> Result? {
        
        let interval: TimeInterval
        let outputTensor: Tensor
        
        do {
            
            let inputData = image.grayScaleData()

            // Copy the pixel data to the input `Tensor`.
            try interpreter.copy(inputData, toInputAt: 0)
            
            // Run inference by invoking the `Interpreter`.
            let startDate = Date()
            try interpreter.invoke()
            interval = Date().timeIntervalSince(startDate) * 1000
            
            // Get the output `Tensor` to process the inference results.
            outputTensor = try interpreter.output(at: 0)
            
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
            return nil
        }
        
        let results: [Float]
        switch outputTensor.dataType {
        case .uInt8:
            guard let quantization = outputTensor.quantizationParameters else {
                print("No results returned because the quantization values for the output tensor are nil.")
                return nil
            }
            let quantizedResults = [UInt8](outputTensor.data)
            results = quantizedResults.map {
                quantization.scale * Float(Int($0) - quantization.zeroPoint)
            }
        case .float32:
            results = [Float32](unsafeData: outputTensor.data) ?? []
            
        default:
            print("Output tensor data type \(outputTensor.dataType) is unsupported for this example app.")
            return nil
        }
        
        // Process the results.
        let topNInferences = getTopN(results: results)
        
        // Return the inference time and inference results.
        return Result(inferenceTime: interval, inferences: topNInferences)
    }
    
    // MARK: - Private Methods
    /// Returns the top N inference results sorted in descending order.
    private func getTopN(results: [Float]) -> [Inference] {
        // Create a zipped array of tuples [(labelIndex: Int, confidence: Float)].
        let zippedResults = zip(labels.indices, results)
        
        // Sort the zipped results by confidence value in descending order.
        let sortedResults = zippedResults.sorted { $0.1 > $1.1 }
        
        // Return the `Inference` results.
        return sortedResults.map { result in Inference(confidence: result.1, label: labels[result.0]) }
    }
    
}
