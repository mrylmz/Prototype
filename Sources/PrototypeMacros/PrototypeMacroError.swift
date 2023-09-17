import Foundation

public enum PrototypeMacroError: Error {
    case unsupportedPeerDeclaration
    case invalidPrototypeKindArgument
    case missingPrototypeKindArgument
    case duplicatePrototypeKindArgument
    case missingMemberPatternBinding
    case missingMemberPatternTypeAnnotation(member: String)
    case unsupportedMemberPatternBinding
    case unsupportedMemberPatternTypeAnnotation(type: String, member: String)
    case underlyingError(message: String)
}

#warning("Add error localizations strings")
extension PrototypeMacroError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unsupportedPeerDeclaration:
            "Prototype macro can only be attached to `struct` or `class` declarations."

        case .invalidPrototypeKindArgument:
            "Invalid argument given for Prototype(...) macro"

        case .missingPrototypeKindArgument:
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
