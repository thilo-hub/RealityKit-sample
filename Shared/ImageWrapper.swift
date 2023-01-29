//
//  ImageWrapper.swift
//  RealityMaker
//
//  Created by Thilo Jeremias on 04.02.23.
//

import SwiftUI


// MARK: - ImageWrapper

public struct ImageWrapper: Codable {

    // Enums

    public enum CodingKeys: String, CodingKey {
        case image
    }

    // Properties

    public let image: NSImage

    // Inits

    public init(image: NSImage) {
        self.image = image
    }

    // Methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        if let image = NSImage(data: data) {
            self.image = image
        } else {
            // Error Decode
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.image, in: container, debugDescription: "Decoding image failed")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let imageData: Data = image.tiffRepresentation {
            try container.encode(imageData, forKey: .image)
        } else {
            // Error Encode
        }
    }
}
