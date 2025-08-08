//
//  TopLevelDecoderTests.swift
//  Yams
//
//  Created by JP Simard on 2020-07-05.
//  Copyright (c) 2020 Yams. All rights reserved.
//

import XCTest
@testable import Yams

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
class DecodableWithConfigurationTests: XCTestCase {
    func testDecodeWithConfiguration() throws {
        let yaml = """
        customField: 100
        object:
          itemName: item1
        """

        let yamlData = try XCTUnwrap(yaml.data(using: Parser.Encoding.default.swiftStringEncoding))

        struct Container: DecodableWithConfiguration, Equatable {
            struct DecodingConfiguration {
                func customFieldValue() -> Int { 42 }
            }
            struct Object: Decodable, Equatable {
                var itemName: String
            }

            var customField: Int?
            var object: Object?

            enum CodingKeys: String, CodingKey {
                case object
                case customField = "custom_field"
            }

            init(from decoder: any Decoder, configuration: DecodingConfiguration) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                object = try container.decodeIfPresent(Object.self, forKey: .object)
                customField = configuration.customFieldValue()
            }
        }

        let container: Container
        do {
            container = try YAMLDecoder().decode(
                Container.self,
                from: yamlData,
                configuration: Container.DecodingConfiguration()
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
            return
        }

        XCTAssertEqual(container.customField, 42,
                       "Will ignore customField in YAML and use the value from the configuration")
        XCTAssertEqual(container.object, .init(itemName: "item1"))
    }
}
