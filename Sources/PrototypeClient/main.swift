import Prototype
import SwiftUI

@Prototype(.form)
struct Article {
    @Section
    var title: String
    var content: String
    var author: String
    
    @Section("metadata")
    var isPublished: Bool
    let views: Int
}
