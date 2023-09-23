import Foundation

public enum PrototypeMacrosError: Error {
    public enum MacroAttachment: String {
        case variableDeclaration = "`var`, `let` declaration"
        case classOrStructDeclaration = "`class` or `struct` declaration"
    }
    
    public enum MacroOfType: String {
        case none
        case string = "`String`"
    }
    
    case macro(
        _ macro: String,
        canOnlyBeAttachedTo: MacroAttachment,
        ofType: MacroOfType = .none
    )
    
    case invalidPrototypeKindsArgument
    case missingPrototypeKindsArgument
    case duplicatePrototypeKindArgument
    case missingMemberPatternBinding
    case missingMemberPatternTypeAnnotation(member: String)
    case unsupportedMemberPatternBinding
    case unsupportedMemberPatternTypeAnnotation(type: String, member: String)
    case underlyingError(message: String)
}

#warning("Add error localizations strings")
extension PrototypeMacrosError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .macro(macro, attachment, type) where type == .none:
            "Macro \(macro) can only be attached to \(attachment)."
            
        case let .macro(macro, attachment, type):
            "Macro \(macro) can only be attached to \(attachment) of type \(type)."
            
        case .invalidPrototypeKindsArgument:
            "Invalid argument given for Prototype(...) macro"

        case .missingPrototypeKindsArgument:
            "Prototype arguments not specified expected a list of prototype kinds to generate including `.view` and/or `.form`."

        case .duplicatePrototypeKindArgument:
            "Duplicate use of prototype kind arguments."

        case .missingMemberPatternBinding:
            "#TODO missingMemberPatternBinding"

        case let .missingMemberPatternTypeAnnotation(member):
            "Prototype macro expected type annotation for member `\(member)`."

        case .unsupportedMemberPatternBinding:
            "#TODO unsupportedMemberPatternBinding"

        case let .unsupportedMemberPatternTypeAnnotation(type, member):
            "Prototype macro doesn't support type `\(type)` for member `\(member)`"

        case let .underlyingError(message):
            message
        }
    }
}
