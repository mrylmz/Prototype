import Foundation
import SwiftSyntax
import PrototypeAPI

public struct FormatMacroArguments {
    public let expression: ExprSyntax
    
    public init(from attribute: AttributeSyntax) throws {
        guard let usingArgument = attribute.argument(labeled: "using") else {
            throw PrototypeMacrosError.missing(argument: .using, ofMacro: .format)
        }
        
        self.expression = usingArgument.expression
    }
}
