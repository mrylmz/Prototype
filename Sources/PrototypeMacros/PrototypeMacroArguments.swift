import SwiftSyntax
import PrototypeAPI

public struct PrototypeMacroArguments {
    public let style: PrototypeStyle
    public let kinds: Set<PrototypeKind>
    
    public init(from attribute: AttributeSyntax) throws {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self), !arguments.isEmpty else {
            throw PrototypeMacrosError.missing(argument: .kinds, ofMacro: .prototype)
        }
        
        let styleArgument = attribute.argument(labeled: "style")
        let styleIdentifier = styleArgument?.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.trimmed.text
        
        guard let firstKindsArgument = attribute.argument(labeled: "kinds") else {
            throw PrototypeMacrosError.missing(argument: .kinds, ofMacro: .prototype)
        }
        
        let otherKindsArguments = attribute.arguments(after: firstKindsArgument)
        let allKindsArguments = [firstKindsArgument] + otherKindsArguments
        let parsedPrototypeKinds = try allKindsArguments.map(PrototypeKind.init(from:))
        let distinctPrototypeKinds = Set(parsedPrototypeKinds)
        
        guard parsedPrototypeKinds.count == distinctPrototypeKinds.count else {
            var duplicatePrototypeKinds = parsedPrototypeKinds
            
            distinctPrototypeKinds.forEach { kind in
                if let index = duplicatePrototypeKinds.firstIndex(of: kind) {
                    duplicatePrototypeKinds.remove(at: index)
                }
            }
            
            let argument = duplicatePrototypeKinds.map { $0.rawValue }.joined(separator: ", ")
            
            throw PrototypeMacrosError.duplicate(argument: argument, givenForArgument: .kinds, ofMacro: .prototype)
        }
        
        self.style = styleIdentifier.flatMap { PrototypeStyle(rawValue: $0) } ?? PrototypeStyle.default
        self.kinds = distinctPrototypeKinds
    }
}
