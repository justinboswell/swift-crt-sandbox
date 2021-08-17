import XCTest
import class Foundation.Bundle

typealias test_stack_trace_decoding = @convention(c) (CInt, UnsafePointer<CChar>?) -> CInt

func resolve<T>(_ name: String) -> T {
    let process = dlopen(nil, RTLD_NOW)
    defer {
        dlclose(process)
    }
    return dlsym(process, name).assumingMemoryBound(to: T.self).pointee
}

final class SandboxTests: XCTestCase {
    func testExample() throws {
        let test_stack_trace_decoding = resolve("test_stack_trace_decoding") as test_stack_trace_decoding
        XCTAssertEqual(0, test_stack_trace_decoding(0, nil))
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
