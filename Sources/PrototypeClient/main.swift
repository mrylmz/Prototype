import Prototype
import SwiftUI

@Prototype(.form)
struct Author {
    let name: String
}

@Prototype(.form)
struct Article {
    @Section
    var title: String
    var content: String
    
    @Section("metadata")
    var isPublished: Bool
    let views: Int
    let author: Author
}
