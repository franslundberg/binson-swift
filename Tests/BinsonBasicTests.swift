//  BinsonTests.swift
//  binsonTests
//
//  Created by Kenneth Pernyer on 2017-06-07.
//  Copyright © 2017 Assa Abloy. All rights reserved.

import XCTest
import Binson

class BinsonBasicTests: XCTestCase {
    func testBasicBinson() {
        let bn = Binson()
        let str = bn.pack().toHexString("\\x")
        XCTAssertEqual(str, "\\x40\\x41")
    }

    func testDictionaryBinson() {
        let bn = Binson(values: ["Olle": 4711])
        XCTAssertEqual(bn.value(key: "Olle"), 4711)
    }

    func testStringBinson() {
        var bn = Binson()
        bn += ("c", "u")

        let str = bn.hex
        XCTAssertEqual(str, "4014016314017541")
    }

    func testLongerTagBinson() {
        var bn = Binson()
        bn += ("co", "u")

        let str = bn.hex
        XCTAssertEqual(str, "401402636f14017541")
    }

    func testArrayBinson() {
        let value: Value = Value(["co", "u"])
        var binson = Binson()
        binson += ("co", value)
        let str = binson.hex
        XCTAssertEqual(str, "401402636f421402636f1401754341")
    }

    func testIntegerBinson() {
        var binson = Binson()
        binson += ("i", 1)

        let str = binson.hex
        XCTAssertEqual(str, "40140169100141")
    }

    func testBinson2JSON() {
        var a = Binson()
        a += ("i", "Happy birthday")
        a += ("r", false)

        var bn = Binson()
        bn += ("i", 230)
        bn += ("e", 23.0992)
        bn += ("b", true)

        bn += ("t", Value.bytes([0x02, 0x02, 0x04]))
        bn += ("array", Value(["co", "u"]))
        bn += ("z", Value.object(a))

        let params = bn.jsonParams()
        let bn2 = Builder.unpack(jsonparams: params)!

        XCTAssertEqual(bn2["b"], true)
        XCTAssertEqual(bn2["i"], 230)
        XCTAssertEqual(bn2["array"], [ "co", "u" ])
        XCTAssertEqual(bn2["e"], 23.0992)
        XCTAssertEqual(bn2["t"], Value.bytes([0x02, 0x02, 0x04]))

        XCTAssertNotEqual(bn2["d"], 23.09)
        XCTAssertNotEqual(bn2["e"], 23.09922)
        XCTAssertNotEqual(bn2["e"], [ "co", "u" ])

        if let binson = bn2["z"].objectValue {
            XCTAssertEqual(binson.value(key: "i"), "Happy birthday")
            XCTAssertEqual(binson.value(key: "r"), false)
        } else {
            XCTFail("Unpack JSON failed")
        }

        let string = bn.json
        let bn3 = Builder.unpack(jsonstring: string)!

        XCTAssertEqual(bn3["b"], true)
        XCTAssertEqual(bn3["i"], 230)
        XCTAssertEqual(bn3["array"], [ "co", "u" ])
        XCTAssertEqual(bn3["e"], 23.0992)
        XCTAssertEqual(bn3["t"], Value.bytes([0x02, 0x02, 0x04]))

        XCTAssertNotEqual(bn3["d"], 23.09)
        XCTAssertNotEqual(bn3["e"], 23.09922)
        XCTAssertNotEqual(bn3["e"], [ "co", "u" ])

        if let binson2 = bn3["z"].objectValue {
            XCTAssertEqual(binson2["i"], "Happy birthday")
            XCTAssertEqual(binson2["r"], false)
        } else {
            XCTAssert(false)
        }

        XCTAssertEqual(bn, bn2)
        XCTAssertEqual(bn, bn3)
    }

    func testJSON2Binson() {
        let json =
"""
{
  "b" : true,
  "e" : 23.0992,
  "i" : 230,
  "array" : [
    "co",
    {
      "r" : false,
      "i" : "Happy birthday"
    }
  ],
  "t" : "0x020204",
  "z" : {
    "r" : false,
    "i" : "Happy birthday"
  }
}
"""
        let binson = Builder.unpack(jsonstring: json)!
        XCTAssertEqual(json, binson.json)
    }

    func testIntegerLongBinson() {
        var binson = Binson()
        binson += ("i", 230)

        let str = binson.hex
        XCTAssertEqual(str, "4014016911e60041")
    }

    func testByteArrayBinson() {
        // bytes      = bytesLen raw
        // bytesLen   = %x18 int8 / %x19 int16 / %x1a int32

        var binson = Binson()
        binson += ("t", Value.bytes([0x02, 0x02]))

        let str = binson.hex
        XCTAssertEqual(str, "401401741802020241")
    }

    func testBinsonInBinson() {
        var binson = Binson()
        binson += ("z", Value.object(Binson()))

        let str = binson.hex
        XCTAssertEqual(str, "4014017a404141")
    }

    /*
     Hex representation: 4014016314017514016910011401741802020214017a404141
     Array representation:
     0x40, 0x14, 0x01, 0x63, 0x14, 0x01, 0x75, 0x14,
     0x01, 0x69, 0x10, 0x01, 0x14, 0x01, 0x74, 0x18,
     0x02, 0x02, 0x02, 0x14, 0x01, 0x7a, 0x40, 0x41,
     0x41

     * {
     *   "c": "u",          // Conversation "u" (String)
     *   "i": 1,            // Converstation instance ID (Integer)
     *   "t": {0x02,0x02},  // Lock-thing id (Byte array)
     *   "z": { }           // Parameters (Empty binson object)
     * }
     */

    func testOperator() {
        var unlock = Binson()
        unlock += ("c", "u")
        unlock += ("i", 1)
        unlock += ("t", Value.bytes([0x02, 0x02]))
        unlock += ("z", Value.object(Binson()))

        XCTAssertEqual(unlock.value(key: "c"), "u")
        XCTAssertEqual(unlock.value(key: "i"), 1)
        XCTAssertEqual(unlock.value(key: "t"), Value.bytes([0x02, 0x02]))
    }

    func testPackUnlock() {
        let expected_hex = "4014016314017514016910011401741802020214017a404141"
        let expected_data = Data([0x40, 0x14, 0x01, 0x63, 0x14, 0x01, 0x75, 0x14,
                                  0x01, 0x69, 0x10, 0x01, 0x14, 0x01, 0x74, 0x18,
                                  0x02, 0x02, 0x02, 0x14, 0x01, 0x7a, 0x40, 0x41,
                                  0x41])

        var unlock = Binson()
        unlock += ("c", "u")
        unlock += ("i", 1)
        unlock += ("t", Value.bytes([0x02, 0x02]))
        unlock += ("z", Value.object(Binson()))

        let actual_data = unlock.pack()
        let actual_hex = actual_data.hex

        XCTAssertEqual(expected_hex, actual_hex)
        XCTAssertEqual(expected_data, actual_data)
    }

    func testBinsonAppend() {
        let a = Binson()
            .append("i", "Happy birthday")
            .append("r", false)

        var b = Binson()
        b += ("i", "Happy birthday")
        b += ("r", false)

        XCTAssertEqual(a, b)
    }

    func testCompareDoubleInt() {
        let a: Value = 4711
        let b: Value = 4711.0000

        XCTAssertEqual(a, b)
        XCTAssertEqual(a, a)
        XCTAssertEqual(b, a)
        XCTAssertEqual(b, b)
    }
}
