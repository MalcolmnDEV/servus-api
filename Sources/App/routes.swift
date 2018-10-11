import Vapor
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let baseEndpoint = "/api/v1/"
    
    router.get("/") { req in
        return "Welcome to serv.us backend .... coming soon"
    }
    
    let userController = UserController()
    let organisationController = OrganisationController()
    
    //Views
    router.get("/register", use: userController.getRegisterView)
    router.get("/login", use: userController.getLoginView)
    
    //public
    router.post(baseEndpoint + "signup", use: userController.createUser)
    
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post(baseEndpoint + "login", use: userController.loginUser)
    
    let token = router.grouped(User.tokenAuthMiddleware())
    token.post(baseEndpoint + "user/index", use: userController.index)
    
    //    let userGroup = router.grouped(baseEndpoint + "user")// group all user/id etc endpoints
    //    userGroup.delete("delete", use: userController.delete)
    //    userGroup.get("index", use: userController.index)
    
    basic.group(baseEndpoint + "organisation") { (organisation) in
        organisation.post("create", use: organisationController.create)
    }
}
