import Foundation
import XCTest

final class SourceBoundaryTests: XCTestCase {
    func testCoreSourceDoesNotContainForbiddenImportsOrPatterns() throws {
        let coreSourceURL = packageRootURL().appendingPathComponent("Sources/LightRoute")
        let swiftFiles = try allSwiftFiles(in: coreSourceURL)
        XCTAssertFalse(swiftFiles.isEmpty)

        let forbiddenPatterns = try [
            ForbiddenPattern(name: "UIKit import", pattern: #"\bimport\s+UIKit\b"#),
            ForbiddenPattern(name: "AppKit import", pattern: #"\bimport\s+AppKit\b"#),
            ForbiddenPattern(name: "SwiftUI import", pattern: #"\bimport\s+SwiftUI\b"#),
            ForbiddenPattern(name: "XCTest import", pattern: #"\bimport\s+XCTest\b"#),
            ForbiddenPattern(name: "AnyView", pattern: #"\bAnyView\b"#),
            ForbiddenPattern(name: "ViewBuilder", pattern: #"\bViewBuilder\b"#),
            ForbiddenPattern(name: "NavigationLink", pattern: #"\bNavigationLink\b"#),
            ForbiddenPattern(name: "navigationDestination modifier", pattern: #"\.navigationDestination\s*\("#),
            ForbiddenPattern(name: "sheet modifier", pattern: #"\.sheet\s*\("#, ignoredLinePrefixes: ["case .sheet"]),
            ForbiddenPattern(name: "fullScreenCover modifier", pattern: #"\.fullScreenCover\s*\("#),
            ForbiddenPattern(name: "route registry", pattern: #"\b(RouteRegistry|Registry)\b"#),
            ForbiddenPattern(name: "route factory", pattern: #"\b(RouteFactory|DestinationFactory)\b"#),
            ForbiddenPattern(name: "DI container", pattern: #"\b(DIContainer|ServiceLocator|ServiceContainer)\b"#),
            ForbiddenPattern(name: "shared singleton", pattern: #"\bstatic\s+(let|var)\s+shared\b"#)
        ]

        for fileURL in swiftFiles {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            let sanitizedContents = sanitizedSourceContents(contents)
            for pattern in forbiddenPatterns {
                let violation = firstViolation(of: pattern, in: sanitizedContents, originalContents: contents)
                XCTAssertNil(violation, "Forbidden pattern \(pattern.name) found in \(relativePath(for: fileURL)): \(violation ?? "")")
            }
        }
    }

    func testPublicSourceAPIStaysOnAllowlist() throws {
        let sourceURL = packageRootURL().appendingPathComponent("Sources")
        let swiftFiles = try allSwiftFiles(in: sourceURL)
        XCTAssertFalse(swiftFiles.isEmpty)

        let allowedPublicLines: [String: Set<String>] = [
            "Sources/LightRoute/Presentation.swift": [
                "public enum Presentation<Route: Hashable>: Equatable {"
            ],
            "Sources/LightRoute/Router.swift": [
                "public protocol Router<Route>: AnyObject {",
                "func go(_ presentation: Presentation<Route>)"
            ],
            "Sources/LightRoute/RouteStore.swift": [
                "public final class RouteStore<Route: Hashable>: Router {",
                "public private(set) var path: [Route]",
                "public private(set) var sheet: Route?",
                "public private(set) var fullScreen: Route?",
                "public init(",
                "public func go(_ presentation: Presentation<Route>) {"
            ],
            "Sources/LightRoute/DeepLinking.swift": [
                "public protocol DeepLinkParser<Route> {",
                "func parse(_ url: URL) -> Presentation<Route>?"
            ],
            "Sources/LightRouteTesting/RouterSpy.swift": [
                "public final class RouterSpy<Route: Hashable>: Router {",
                "public private(set) var presentations: [Presentation<Route>]",
                "public init() {",
                "public func go(_ presentation: Presentation<Route>) {",
                "public func reset() {"
            ]
        ]

        for fileURL in swiftFiles {
            let relativePath = relativePath(for: fileURL)
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            let sanitizedContents = sanitizedSourceContents(contents)
            let apiLines = Set(sanitizedContents
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { line in
                    line.hasPrefix("public ")
                        || line.hasPrefix("open ")
                        || line == "func go(_ presentation: Presentation<Route>)"
                        || line == "func parse(_ url: URL) -> Presentation<Route>?"
                })

            XCTAssertEqual(apiLines, allowedPublicLines[relativePath] ?? [], "Unexpected public API in \(relativePath)")
        }
    }

    func testProductionSourcesDoNotImportXCTest() throws {
        let sourceURL = packageRootURL().appendingPathComponent("Sources")
        let swiftFiles = try allSwiftFiles(in: sourceURL)
        XCTAssertFalse(swiftFiles.isEmpty)

        for fileURL in swiftFiles {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            let sanitizedContents = sanitizedSourceContents(contents)
            XCTAssertFalse(
                sanitizedContents.contains("import XCTest"),
                "XCTest import found in production source \(relativePath(for: fileURL))"
            )
        }
    }

    private func allSwiftFiles(in directoryURL: URL) throws -> [URL] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return try enumerator.compactMap { item in
            guard let fileURL = item as? URL else {
                return nil
            }

            let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard resourceValues.isRegularFile == true, fileURL.pathExtension == "swift" else {
                return nil
            }

            return fileURL
        }
    }

    private func firstViolation(of pattern: ForbiddenPattern, in sanitizedContents: String, originalContents: String) -> String? {
        let sanitizedLines = sanitizedContents.split(separator: "\n", omittingEmptySubsequences: false)
        let originalLines = originalContents.split(separator: "\n", omittingEmptySubsequences: false)

        for (sanitizedLine, originalLine) in zip(sanitizedLines, originalLines) {
            let lineText = String(sanitizedLine)
            let originalLineText = String(originalLine)
            let trimmedLine = lineText.trimmingCharacters(in: .whitespaces)

            if pattern.ignoredLinePrefixes.contains(where: { trimmedLine.hasPrefix($0) }) {
                continue
            }

            let range = NSRange(lineText.startIndex..<lineText.endIndex, in: lineText)
            if pattern.regex.firstMatch(in: lineText, range: range) != nil {
                return originalLineText
            }
        }

        return nil
    }

    private func sanitizedSourceContents(_ contents: String) -> String {
        var result = ""
        var index = contents.startIndex
        var isInString = false
        var isEscaped = false
        var isInLineComment = false
        var blockCommentDepth = 0

        while index < contents.endIndex {
            let nextIndex = contents.index(after: index)
            let character = contents[index]
            let followingCharacter = nextIndex < contents.endIndex ? contents[nextIndex] : nil

            if isInLineComment {
                if character == "\n" {
                    isInLineComment = false
                    result.append("\n")
                } else {
                    result.append(" ")
                }
                index = nextIndex
                continue
            }

            if blockCommentDepth > 0 {
                if character == "/", followingCharacter == "*" {
                    blockCommentDepth += 1
                    result.append(" ")
                    result.append(" ")
                    index = contents.index(after: nextIndex)
                    continue
                }

                if character == "*", followingCharacter == "/" {
                    blockCommentDepth -= 1
                    result.append(" ")
                    result.append(" ")
                    index = contents.index(after: nextIndex)
                    continue
                }

                result.append(character == "\n" ? "\n" : " ")
                index = nextIndex
                continue
            }

            if isInString {
                result.append(character == "\n" ? "\n" : " ")

                if isEscaped {
                    isEscaped = false
                } else if character == "\\" {
                    isEscaped = true
                } else if character == "\"" {
                    isInString = false
                }
            } else if character == "/", followingCharacter == "/" {
                isInLineComment = true
                result.append(" ")
                result.append(" ")
                index = contents.index(after: nextIndex)
                continue
            } else if character == "/", followingCharacter == "*" {
                blockCommentDepth = 1
                result.append(" ")
                result.append(" ")
                index = contents.index(after: nextIndex)
                continue
            } else if character == "\"" {
                isInString = true
                result.append(" ")
            } else {
                result.append(character)
            }

            index = nextIndex
        }

        return result
    }

    private func packageRootURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func relativePath(for fileURL: URL) -> String {
        let packageRoot = packageRootURL().standardizedFileURL.path()
        let path = fileURL.standardizedFileURL.path()
        let prefix = packageRoot.hasSuffix("/") ? packageRoot : packageRoot + "/"

        guard path.hasPrefix(prefix) else {
            return path
        }

        return String(path.dropFirst(prefix.count))
    }
}

private struct ForbiddenPattern {
    let name: String
    let regex: NSRegularExpression
    let ignoredLinePrefixes: [String]

    init(name: String, pattern: String, ignoredLinePrefixes: [String] = []) throws {
        self.name = name
        self.regex = try NSRegularExpression(pattern: pattern)
        self.ignoredLinePrefixes = ignoredLinePrefixes
    }
}