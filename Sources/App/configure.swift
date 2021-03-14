import Vapor
import Leaf
import Authentication
import FluentMySQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())
    services.register(KaminoErrorMiddleware.self)
    services.register(PrivateFileMiddleware.self)
    
    services.register { container -> LeafTagConfig in
        var config = LeafTagConfig.default()
        config.use(DateFormat(), as: "formatDate")
        config.use(ValueForField(), as: "valueForField")
        config.use(ShowIfFieldHasErrors(), as: "showIfFieldHasErrors")
        config.use(ConfigValue(), as: "configValueFor")
        config.use(PrintHTML(), as: "html")
        return config
    }
    try services.register(AuthenticationProvider())
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(KaminoErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    middlewares.use(PrivateFileMiddleware.self)
    services.register(middlewares)

    // Configure databases
    
//    let CoruscantConfig = MySQLDatabaseConfig(hostname: "10.0.1.9", port: 3306, username: "iamwire_carolyne", password: "carolyne", database: "Coruscant")
//    let Coruscant = MySQLDatabase(config: CoruscantConfig)
    
    /// Register the configured SQLite database to the database config.
    
    print(Kamino.CoruscantConfig.hostname)
    var databases = DatabasesConfig()
//    let mysql = MySQLDatabaseConfig(hostname: "10.0.1.9", port: 3306, username: "iamwire_carolyne", password: "carolyne", database: "vapor")
//    let mySQLdb = MySQLDatabase(config: mysql)
//    databases.add(database: mySQLdb, as: .mysql)
    databases.add(database: Kamino.Coruscant, as: .Coruscant)
    
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
//    migrations.add(model: Account.self, to: .Coruscant)
//    migrations.add(model: User.self, database: .Coruscant)
//    migrations.add(model: Token.self, database: .Coruscant)
//    migrations.add(model: Country.self, database: .Coruscant)
//    migrations.add(model: Zone.self, database: .Coruscant)
//    migrations.add(model: Event.self, database: .Coruscant)
//    migrations.add(model: TeamInvite.self, database: .Coruscant)
//    migrations.add(model: VerifyEmail.self, database: .Coruscant)
//    migrations.add(model: KaminoAttendeeRegistrationForm.self, database: .Coruscant)
//    migrations.add(migration: AddAccountId.self, database: .Coruscant)
//    migrations.add(migration: RenameAccountId.self, database: .Coruscant)
//    migrations.add(migration: EventAccountMigration.self, database: .Coruscant)
//    migrations.add(migration: AddAccountReferenceUser.self, database: .Coruscant)
//    migrations.add(migration: AddUserReferenceEvent.self, database: .Coruscant)
//    migrations.add(migration: AddAccountReferenceEvent.self, database: .Coruscant)
//    migrations.add(migration: AddUniqueIdEvent.self, database: .Coruscant)
//    migrations.add(migration: AddCreatedAtUpdateAtEvent.self, database: .Coruscant)
//    migrations.add(migration: AddLastUpdatedByUser.self, database: .Coruscant)
//    migrations.add(migration: AddIsOrganizer.self, database: .Coruscant)
    services.register(migrations)

    // Configure the rest of your application here
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}


