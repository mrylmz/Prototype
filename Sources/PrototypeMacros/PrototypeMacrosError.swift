import Foundation

public enum PrototypeMacrosError: Error {
    public enum Attachment: String, CustomStringConvertible {
        case variableDeclaration = "`var`, `let` declaration"
        case classOrStructDeclaration = "`class` or `struct` declaration"
        
        public var description: String { rawValue }
    }
    
    public enum OfType: String, CustomStringConvertible {
        case none
        case string = "String"
        
        public var description: String { "`\(rawValue)`" }
    }
    
    public enum OfMacro: String, CustomStringConvertible {
        case prototype = "Prototype"
        
        public var description: String { "`\(rawValue)`" }
    }
    
    public enum MacroArgument: String, CustomStringConvertible {
        case kinds
        
        public var description: String { "`\(rawValue)`" }
    }
    
    public enum Syntax: String, CustomStringConvertible {
        case typeAnnotation = "type-annotation"
        
        public var description: String { "`\(rawValue)`" }
    }
    
    case macro(
        _ macro: String,
        canOnlyBeAttachedTo: Attachment,
        ofType: OfType = .none
    )

    case invalid(argument: String, givenForArgument: MacroArgument, ofMacro: OfMacro)
    case missing(argument: MacroArgument, ofMacro: OfMacro)
    case duplicate(argument: String, givenForArgument: MacroArgument, ofMacro: OfMacro)
    case missingSyntax(_ syntax: Syntax, forMember: String, ofMacro: OfMacro)
    case unsupportedPatternBinding(_ pattern: String, givenInMemberListOfMacro: OfMacro)
    case unsupportedType(_ type: String, forMember: String, ofMacro: OfMacro)
    case underlyingError(message: String)
}

extension PrototypeMacrosError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .macro(macro, attachment, type) where type == .none:
            "Macro \(macro) can only be attached to \(attachment)."
            
        case let .macro(macro, attachment, type):
            "Macro \(macro) can only be attached to \(attachment) of type \(type)."

        case let .invalid(invalidArgument, argument, macro):
            "Invalid argument `\(invalidArgument)` given for argument \(argument) of \(macro) macro"

        case let .missing(argument, macro):
            "Missing argument \(argument) for macro \(macro)"

        case let .duplicate(invalidArgument, argument, macro):
            "Duplicate argument `\(invalidArgument)` given for argument \(argument) of \(macro) macro"

        case let .missingSyntax(syntax, member, macro):
            "\(macro) macro expected \(syntax) for member `\(member)`."

        case let .unsupportedPatternBinding(pattern, macro):
            "Unsupported pattern binding `\(pattern)` given in member list of \(macro)` macro"

        case let .unsupportedType(type, member, macro):
            "\(macro) macro doesn't support type `\(type)` for member `\(member)`"

        case let .underlyingError(message):
            message
        }
    }
}
