import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    //api endpoints
    let usersController = UsersController()
    try router.register(collection: usersController)
    try router.register(collection:  ZonesController())
    try router.register(collection:  CountryController())
    try router.register(collection: AccountController())
    try router.register(collection: KaminoAttendeeFormController())
    
    //website
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
    try router.register(collection:  WebsiteEventController())
}
