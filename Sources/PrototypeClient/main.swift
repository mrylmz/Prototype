import Prototype
import SwiftUI

@Prototype(style: .inline, kinds: .form, .view)
struct Author {
    let name: String
}

@Prototype(kinds: .form)
struct Article {
    var title: String
    var content: String
    @Secure var password: String
    
    @Section("metadata")
    var isPublished: Bool
    let views: Int
    let author: Author
}
