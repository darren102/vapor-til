import Vapor
import FluentPostgreSQL

final class Category: Codable {
    var id: Int?
    var name: String

    init(name: String) {
        self.name = name
    }
}

extension Category: PostgreSQLModel {}
extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}

extension Category {
    // 1
    var acronyms: Siblings<Category,
        Acronym,
        AcronymCategoryPivot> {
        // 2
        return siblings()
    }

    static func addCategory(_ name: String, to acronym: Acronym,
                            on req: Request) throws
        -> Future<Void> {
            // 1
            return try Category.query(on: req)
                .filter(\.name == name)
                .first()
                .flatMap(to: Void.self) { foundCategory in
                    if let existingCategory = foundCategory {
                        // 2
                        let pivot =
                            try AcronymCategoryPivot(acronym.requireID(),
                                                     existingCategory.requireID())
                        // 3
                        return pivot.save(on: req).transform(to: ())
                    } else {
                        // 4
                        let category = Category(name: name)
                        // 5
                        return category.save(on: req)
                            .flatMap(to: Void.self) { savedCategory in
                                // 6
                                let pivot =
                                    try AcronymCategoryPivot(acronym.requireID(),
                                                             savedCategory.requireID())
                                // 7
                                return pivot.save(on: req).transform(to: ())
                        }
                    }
            }
    }
}
