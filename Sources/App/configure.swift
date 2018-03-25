import FluentPostgreSQL
import Vapor

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    // Step 2
    try services.register(FluentPostgreSQLProvider())

    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    var middlewares = MiddlewareConfig()
    middlewares.use(DateMiddleware.self)
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    // Configure a database
    var databases = DatabaseConfig()
    // 2
    let hostname = Environment.get("DATABASE_HOSTNAME")
        ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD")
        ?? "password"
    // 3
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: 5432,
        username: username,
        database: databaseName,
        password: password)
    // 4
    let database = PostgreSQLDatabase(config: databaseConfig)
    // 5
    databases.add(database: database, as: .psql)
    // 6
    services.register(databases)

    var migrations = MigrationConfig()
    // Step 5
    migrations.add(model: Acronym.self, database: .psql)
    services.register(migrations)
}

