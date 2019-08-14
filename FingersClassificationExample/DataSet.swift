//
//  DataSet.swift
//  FingersClassificationExample
//
//  Created by Chittapon Thongchim on 14/8/2562 BE.
//  Copyright © 2562 Appsynth. All rights reserved.
//

import Foundation

struct DataSet {
    
    static func makeImageDataSet() -> [String] {
        var images: [String] = []
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fileManager.contentsOfDirectory(atPath: path)
        for item in items {
            if item.hasSuffix(".png") {
                images.append(item)
            }
        }
        return images
    }
}
