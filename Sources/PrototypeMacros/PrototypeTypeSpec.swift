import Foundation
import SwiftSyntax
import SwiftSyntaxExtensions

public struct PrototypeTypeSpec {
    public let name: String
    public let isOptional: Bool
    
    private init(name: String, isOptional: Bool) {
        self.name = name
        self.isOptional = isOptional
    }
    
    public init?(parsing typeAnnotation: TypeAnnotationSyntax) {
        if let name = typeAnnotation.type.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.trimmed.text {
            self.init(name: name, isOptional: true)
            return
        }
        
        if let name = typeAnnotation.type.as(IdentifierTypeSyntax.self)?.name.trimmed.text {
            self.init(name: name, isOptional: false)
            return
        }
        
        return nil
    }
}
