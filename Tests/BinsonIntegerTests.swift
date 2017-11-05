//
//  BinsonIntegerTests.swift
//  Binson-test
//
//  Created by Kenneth Pernyer on 2017-11-01.
//

import XCTest
import Binson

class BinsonIntegerTests: XCTestCase {
    static let twoto7  = Int64(Int8.max)
    static let twoto15 = Int64(Int16.max)
    static let twoto31 = Int64(Int32.max)
    static let twoto63 = Int64(Int64.max)
    
    let posx10: (low: Value, high: Value) = (1, 127)
    let posx11: (low: Value, high: Value) = (128, 32767)
    let posx12: (low: Value, high: Value) = (32768, 2147483647)
    let posx13: (low: Value, high: Value) = (2147483648, 9223372036854775807)
    
    let negx10: (low: Value, high: Value) = (0, -128)
    let negx11: (low: Value, high: Value) = (-129, -32768)
    let negx12: (low: Value, high: Value) = (-32769, -2147483648)
    let negx13: (low: Value, high: Value) = (-2147483649, -9223372036854775808)
    
    /*
    X – Binson-objektet som hex-sträng
     127 -  0x40140161 107F 41
    -128 - 0x40140161 1080 41
    
     32767 -  0x40140161 11FF7F 41
    -32768 - 0x40140161 110080 41
    
     2147483647 -  0x40140161 12FFFFFF7F 41
    -2147483648 - 0x40140161 1200000080 41
    
     9223372036854775807 -  0x40140161 13FFFFFFFFFFFFFF7F 41
    -9223372036854775808 - 0x40140161 130000000000000080 41
     */
    
    func testPosIntegerValues() {
        let v0: Value = 0
        XCTAssertEqual(v0.hex, "1000")
        
        let v1: Value = 1
        XCTAssertEqual(v1.hex, "1001")
        
        let v1max: Value = Value(Int8.max)
        XCTAssertEqual(v1max.hex, "107f")
        
        let v1max_plus: Value = Value(Int16(Int8.max)+1)
        XCTAssertEqual(v1max_plus.hex, "118000")
        
        let v2max: Value = Value(Int16.max)
        XCTAssertEqual(v2max.hex, "11ff7f")
        
        let v2max_plus: Value = Value(Int32(Int16.max)+1)
        XCTAssertEqual(v2max_plus.hex, "1200800000")
        
        let v4max: Value = Value(Int32.max)
        XCTAssertEqual(v4max.hex, "12ffffff7f")
        
        let v4max_plus: Value = Value(Int64(Int32.max)+1)
        XCTAssertEqual(v4max_plus.hex, "130000008000000000")
        
        let v8max: Value = Value(Int64.max)
        XCTAssertEqual(v8max.hex, "13ffffffffffffff7f")
    }
    
    func testNegIntegerValues() {
        let v0: Value = Value(Int8(-0))
        XCTAssertEqual(v0.hex, "1000")
        
        let v1: Value = Value(Int8(-1))
        XCTAssertEqual(v1.hex, "10ff")
        
        let v1max: Value = Value(Int8.min)
        XCTAssertEqual(v1max.hex, "1080")
        
        let v1max_plus: Value = Value(Int16(Int8.min)-11)
        XCTAssertEqual(v1max_plus.hex, "1175ff")
        
        let v2max: Value = Value(Int16.min)
        XCTAssertEqual(v2max.hex, "110080")
        
        let v2max_plus: Value = Value(Int32(Int16.min)-1)
        XCTAssertEqual(v2max_plus.hex, "12ff7fffff")
        
        let v4max: Value = Value(Int32.min)
        XCTAssertEqual(v4max.hex, "1200000080")
        
        let v4max_plus: Value = Value(Int64(Int32.min)-1)
        XCTAssertEqual(v4max_plus.hex, "13ffffff7fffffffff")
        
        let v8max: Value = Value(Int64.min)
        XCTAssertEqual(v8max.hex, "130000000000000080")
    }
}