import Vapor
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("/") { req in
        return "Welcome to serv.us backend .... coming soon"
    }
    
    let userController = UserController()
    let organisationController = OrganisationController()
    
    try router.register(collection: userController)
    try router.register(collection: organisationController)
}
