import Foundation

public enum SectionMacroError: Error {
    case unsupportedPeerDeclaration
}

extension SectionMacroError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unsupportedPeerDeclaration:
            "Section macro can only be attached to `let` or `var` declarations."
        }
    }
}
