import XCTest
import class Foundation.Bundle

import AwsCCommon
import AwsCCommonTests

//typealias test_stack_trace_decoding = @convention(c) (CInt, UnsafePointer<CChar>?) -> CInt

//func test_stack_trace_decoding(_ argc: CInt, _ argv: UnsafePointer<CChar>?) -> CInt

func resolve<T>(_ name: String) -> T {
    let process = dlopen(nil, RTLD_NOW)
    defer {
        dlclose(process)
    }
    return dlsym(process, name).assumingMemoryBound(to: T.self).pointee
}

final class SandboxTests: XCTestCase {
    func testStackTraceDecoding() throws {
        let stackFrames = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: 16)
        let numFrames = aws_backtrace(stackFrames, 16)
        XCTAssert(0 != numFrames)
        let rawSymbols = aws_backtrace_symbols(stackFrames, 16)
        var symbols: [String] = []
        for idx in 0...15 {
            if let rawSymbol = rawSymbols?.advanced(by: idx) {
                if let symbol = String(validatingUTF8: rawSymbol.pointee!) {
                    symbols.append(symbol)
                }
            }
        }
        let parens = #function.firstIndex(of: "(") ?? #function.endIndex
        let functionName = #function[..<parens]
        let foundFunction = symbols.first {
            return $0.contains(functionName)
        }
        XCTAssertNotNil(foundFunction)
    }
}
