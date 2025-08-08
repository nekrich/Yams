//
//  EncoderTests.swift
//  Yams
//
//  Created by Norio Nomura on 5/2/17.
//  Copyright (c) 2017 Yams. All rights reserved.
//

import Foundation
import XCTest
import Yams

final class EncodableWithConfigurationTests: XCTestCase, @unchecked Sendable {
    func testEncodeWithConfiguration() throws {
        struct Container: EncodableWithConfiguration, Equatable {
            struct EncodingConfiguration {
                func customFieldValue() -> Int { 42 }
            }
            struct Object: Encodable, Equatable {
                var itemName: String
            }

            var object: Object?

            enum CodingKeys: String, CodingKey {
                case object
                case customField
            }

            func encode(to encoder: any Encoder, configuration: EncodingConfiguration) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(object, forKey: .object)
                try container.encode(configuration.customFieldValue(), forKey: .customField)
            }
        }

        let container: Container = .init(object: .init(itemName: "item1"))

        let yamlString: String = try YAMLEncoder().encode(container, configuration: Container.EncodingConfiguration())

        let expectedYAML = """
            object:
              itemName: item1
            customField: 42
            """.trimmingCharacters(in: .newlines)

        XCTAssertEqual(yamlString.trimmingCharacters(in: .newlines), expectedYAML)
    }
}
