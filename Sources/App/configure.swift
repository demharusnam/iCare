import Fluent
import Vapor
import Leaf
import FluentSQLiteDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    if !app.environment.isRelease {
        LeafRenderer.Option.caching = .bypass
    }
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    
    app.migrations.add(CreateEmployee())
    app.migrations.add(CreatePatient())
    
    app.logger.logLevel = .debug
    
    LeafFileMiddleware.defaultMediaType = .html
    LeafFileMiddleware.processableExtensions = ["leaf", "html", "css", "js"]
    LeafFileMiddleware.contexts = [
        .css: [
            "background": "#eee",
            "padding": "16px",
        ],
        .html: [
            "title": "Hello world!"
        ],
    ]
    if let lfm = LeafFileMiddleware(publicDirectory: app.directory.publicDirectory){
        app.middleware.use(lfm)
    }
    
    try app.autoMigrate().wait()
    app.views.use(.leaf)

    // register routes
    try routes(app)
}  
