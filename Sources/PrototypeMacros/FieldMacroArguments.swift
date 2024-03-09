import SwiftSyntax
import PrototypeAPI

public struct FieldMacroArguments {
    public let attributes: Set<FieldAttribute>
    
    public init(from attribute: AttributeSyntax) throws {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self), !arguments.isEmpty else {
            throw PrototypeMacrosError.missing(argument: .attributes, ofMacro: .field)
        }
        
        let parsedFieldAttributes = try arguments.map(FieldAttribute.init(from:))
        let distinctFieldAttributes = Set(parsedFieldAttributes)
        
        guard parsedFieldAttributes.count == distinctFieldAttributes.count else {
            var duplicateFieldAttributes = parsedFieldAttributes
            
            distinctFieldAttributes.forEach { kind in
                if let index = duplicateFieldAttributes.firstIndex(of: kind) {
                    duplicateFieldAttributes.remove(at: index)
                }
            }
            
            let argument = duplicateFieldAttributes.map { $0.rawValue }.joined(separator: ", ")
            
            throw PrototypeMacrosError.duplicate(argument: argument, givenForArgument: .attributes, ofMacro: .field)
        }
        
        self.attributes = distinctFieldAttributes
    }
}
