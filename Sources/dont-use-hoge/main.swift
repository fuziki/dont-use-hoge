import Foundation
import SwiftSyntax
import SwiftSyntaxParser

class HogeDetectorSyntaxVisitor: SyntaxVisitor {
    var locations: [(line: Int, column: Int)] = []
    private let locationConverter: SourceLocationConverter
    init(tree: SourceFileSyntax) {
        locationConverter = SourceLocationConverter(file: "", tree: tree)
    }
    override func visit(_ node: IdentifierPatternSyntax) -> SyntaxVisitorContinueKind {
        if node.identifier.text != "hoge" { return .visitChildren }
        let location: SourceLocation = node.startLocation(converter: locationConverter)
        locations.append((line: location.line!, column: location.column!))
        return .visitChildren
    }
    override open func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
      return .visitChildren
    }
}

if CommandLine.arguments.count >= 2 {
    let url = URL(fileURLWithPath: CommandLine.arguments[1])
    let sourceFile: SourceFileSyntax = try SyntaxParser.parse(url)
    let hogeDetector = HogeDetectorSyntaxVisitor(tree: sourceFile)
    hogeDetector.walk(sourceFile)
    for location in hogeDetector.locations {
        print("\(url.path):\(location.line):\(location.column): error: don't use hoge")
    }
    exit(0)
}

let source = """
class Example {
    public private(set) var hoge = "Hello, World!"

    public init() {
    }
}
"""

let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)

class MySyntaxRewriter: SyntaxRewriter {
    private var nest: Int = 0
    override func visitPre(_ node: Syntax) {
        let space = Array(repeating: " ", count: nest).joined(separator: "|") + "+"
        if "\(node.syntaxNodeType)" == "TokenSyntax" {
            let text = "\(node)".trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespaces)
            print("\(space)-> \(text)")
        } else {
            print("\(space)\(node.syntaxNodeType)")
        }
        nest += 1
    }
    override func visitPost(_ node: Syntax) {
        nest -= 1
    }
}
_ = MySyntaxRewriter().visit(sourceFile._syntaxNode)

class HogeToFugaSyntaxRewriter: SyntaxRewriter {
    override func visit(_ node: IdentifierPatternSyntax) -> PatternSyntax {
        if node.identifier.text == "hoge" {
            return super.visit(node.withIdentifier(SyntaxFactory.makeIdentifier("fuga", trailingTrivia: .spaces(1))))
        } else {
            return super.visit(node)
        }
    }
}
let res = HogeToFugaSyntaxRewriter().visit(sourceFile._syntaxNode)
print(res.description)

let hogeDetector = HogeDetectorSyntaxVisitor(tree: sourceFile)
hogeDetector.walk(sourceFile)
for location in hogeDetector.locations {
    print("hoge location line: \(location.line), column: \(location.column)")
}
