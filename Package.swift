// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let excludesFromAll = ["tests", "cmake", "CONTRIBUTING.md",
                       "LICENSE", "format-check.sh", "NOTICE", "builder.json",
                        "CMakeLists.txt", "README.md"]

// aws-c-common config
var awsCCommonPlatformExcludes = ["source/windows", "source/android",
                                  "AWSCRTAndroidTestRunner", "docker-images", "verification",
                                  "include/aws/common/", "sanitizer-blacklist.txt"] + excludesFromAll

#if arch(i386) || arch(x86_64)
awsCCommonPlatformExcludes.append("source/arch/arm")
// temporary cause I can't use intrensics because swiftpm doesn't like the necessary compiler flag.
awsCCommonPlatformExcludes.append("source/arch/intel")
// unsafeFlagsArray.append("-mavx512f")
#elseif arch(arm64)
awsCCommonPlatformExcludes.append("source/arch/intel")
#else
awsCCommonPlatformExcludes.append("source/arch/intel")
awsCCommonPlatformExcludes.append("source/arch/arm")
#endif

#if !os(Windows)
awsCCommonPlatformExcludes.append("source/arch/intel/msvc")
awsCCommonPlatformExcludes.append("source/arch/arm/msvc")
#else
awsCCommonPlatformExcludes.append("source/arch/intel/asm")
awsCCommonPlatformExcludes.append("source/arch/arm/asm")
#endif

let package = Package(
    name: "Sandbox",
    platforms: [.iOS(.v11), .macOS(.v10_14)],
//    products: [
//      .executable(name: "AwsCrtSandbox", targets: ["Sandbox"])
//    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Sandbox",
            dependencies: []
        ),
        .target(
            name: "AwsCPlatformConfig",
            dependencies: [],
            path: "crt/config",
            publicHeadersPath: "."
        ),
        .target(
            name: "AwsCCommon",
            dependencies: ["AwsCPlatformConfig"],
            path: "crt/aws-c-common",
            exclude: awsCCommonPlatformExcludes
        ),
        .testTarget(
            name: "SandboxTests",
            dependencies: ["AwsCCommon"]
        ),
    ]
)
