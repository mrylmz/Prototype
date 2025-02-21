import SwiftSyntax

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

extension PrototypeTypeSpec {
    private static let numericTypes: [String] = [
        "Int8", "Int16", "Int32", "Int64", "Int",
        "UInt8", "UInt16", "UInt32", "UInt64", "UInt",
        "Float16", "Float32", "Float64", "Float80", "Float", "Double",
        "Decimal"
    ]

    public var isBool: Bool { name == "Bool" }
    public var isString: Bool { name == "String" }
    public var isNumeric: Bool { Self.numericTypes.contains(name) }
    
    public var defaultValue: String {
        if isNumeric {
            return "0"
        }
        
        if isBool {
            return "false"
        }
        
        if isString {
            return "\"\""
        }
        
        return ".init()"
    }
}
