import Routing
import Vapor
import Fluent

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of creating a Service and using it.
    router.get("hash", String.parameter) { req -> String in
        // Create a BCryptHasher using the Request's Container
        let hasher = try req.make(BCryptHasher.self)

        // Fetch the String parameter (as described in the route)
        let string = try req.parameter(String.self)

        // Return the hashed string!
        return try hasher.make(string)
    }

    // 1
    router.post("api", "acronyms") { req -> Future<Acronym> in
        // 2
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
                // 3
                return acronym.save(on: req)
        }
    }

    // 1
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        // 2
        return Acronym.query(on: req).all()
    }

    // 1
    router.get("api",
               "acronyms",
               Acronym.parameter) { req -> Future<Acronym> in
                // 2
                return try req.parameter(Acronym.self)
    }

    // 1
    router.put("api",
               "acronyms",
               Acronym.parameter) { req -> Future<Acronym> in
                // 2
                return try flatMap(to: Acronym.self,
                                   req.parameter(Acronym.self),
                                   req.content.decode(Acronym.self)) {
                                    acronym, updatedAcronym in
                                    // 3
                                    acronym.short = updatedAcronym.short
                                    acronym.long = updatedAcronym.long

                                    // 4
                                    return acronym.save(on: req)
                }
    }

    // 1
    router.delete("api",
                  "acronyms",
                  Acronym.parameter) { req -> Future<HTTPStatus> in
                    // 2
                    return try req.parameter(Acronym.self)
                        .flatMap(to: HTTPStatus.self) { acronym in
                            // 3
                            return acronym.delete(on: req)
                                .transform(to: HTTPStatus.noContent)
                    }
    }

    // 1
    router.get("api",
               "acronyms",
               "search") { req -> Future<[Acronym]> in
                // 2
                guard let searchTerm = req.query[String.self,
                                                 at: "term"] else {
                                                    throw Abort(.badRequest)
                }
                // 1
                return try Acronym.query(on: req).group(.or) { or in
                    // 2
                    try or.filter(\.short == searchTerm)
                    // 3
                    try or.filter(\.long == searchTerm)
                    // 4
                }.all()
    }

    // 1
    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
        // 2
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self) { acronym in
                // 3
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                // 4
                return acronym
        }
    }

    // 1
    router.get("api",
               "acronyms",
               "sorted") { req -> Future<[Acronym]> in
                // 2
                return try Acronym.query(on: req)
                    .sort(\.short, .ascending)
                    .all()
    }
}
