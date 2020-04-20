// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "OgreKit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "OgreKit",
            targets: ["OgreKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "OgreKit",
            dependencies: ["onigmo"],
            publicHeadersPath:".",
            cSettings: [
                    .headerSearchPath("."),
                    .headerSearchPath(".."),
            ]
        ),
        .target(
        name: "onigmo",
            dependencies: [],
            exclude: ["testc.c", "testu.c", "enc/mktable.c", "test_enc_utf8.c", "sample/posix.c", "regposerr.c", "regposix.c", "win32" , "sample"],
            publicHeadersPath:"inc",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath(".."),
                .headerSearchPath("enc/unicode"),
                .define("SIZEOF_INT", to: String(MemoryLayout<CInt>.size)),
                .define("SIZEOF_LONG_LONG", to: String(MemoryLayout<CLongLong>.size)),
                .define("SIZEOF_LONG", to: String(MemoryLayout<CLong>.size)),
                .define("SIZEOF_SHORT", to: String(MemoryLayout<CShort>.size)),
                .define("SIZEOF_VOIDP", to: String(MemoryLayout<UnsafeRawPointer>.size))
        ]),
    ]
)


