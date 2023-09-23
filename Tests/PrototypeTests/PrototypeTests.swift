import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PrototypeMacros)
import PrototypeMacros

let testMacros: [String: Macro.Type] = [
    "Prototype": PrototypeMacro.self,
    "Secure": SecureMacro.self
]
#endif

final class PrototypeTests: XCTestCase {
    func testPrototypeMacroErrorUnsupportedPeerDeclarationOnEnum() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .view)
            enum MyEnum {}
            """,
            expandedSource: """
            enum MyEnum {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.macro("Prototype", canOnlyBeAttachedTo: .classOrStructDeclaration).debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorUnsupportedPeerDeclarationOnVariable() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .view)
            var myValue: Int = 0
            """,
            expandedSource: """
            var myValue: Int = 0
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.macro("Prototype", canOnlyBeAttachedTo: .classOrStructDeclaration).debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorInvalidPrototypeKindArgument() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .unknown)
            struct MyStruct {}
            """,
            expandedSource: """
            struct MyStruct {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.invalidPrototypeKindsArgument.debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testPrototypeMacroErrorMissingPrototypeKindArgument() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype()
            struct MyStruct {}
            """,
            expandedSource: """
            struct MyStruct {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.missingPrototypeKindsArgument.debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorDuplicatePrototypeKindArgument() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .view, .form, .form)
            struct MyStruct {}
            """,
            expandedSource: """
            struct MyStruct {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.duplicatePrototypeKindArgument.debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorMissingMemberPatternTypeAnnotation() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            import SwiftUI

            @Prototype(kinds: .form)
            struct MyStruct {
                @Environment(\\.accessibilityEnabled) var accessibilityEnabled
            }
            """,
            expandedSource: """
            import SwiftUI
            struct MyStruct {
                @Environment(\\.accessibilityEnabled) var accessibilityEnabled
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.missingMemberPatternTypeAnnotation(member: "accessibilityEnabled").debugDescription,
                    line: 3,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorUnsupportedMemberPatternBinding() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            import SwiftUI

            @Prototype(kinds: .form)
            class MyClass {
                var callable: () -> Void
            }
            """,
            expandedSource: """
            import SwiftUI
            class MyClass {
                var callable: () -> Void
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.unsupportedMemberPatternTypeAnnotation(type: "() -> Void", member: "callable").debugDescription,
                    line: 3,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
