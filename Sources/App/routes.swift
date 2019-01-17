import Vapor
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("/") { req in
        return "Welcome to serv.us backend .... coming soon"
    }
    
    let userController = UserController()
    let organisationController = OrganisationController()
    let invoiceController = InvoiceController()
    let menuController = MenuController()
    let orderController = OrderController()
    let storeController = StoreController()
    let tableController = TableController()
    let cmsController = CMSController()
    let restaurantController = RestaurantController()
    
    try router.register(collection: userController)
    try router.register(collection: organisationController)
    try router.register(collection: invoiceController)
    try router.register(collection: menuController)
    try router.register(collection: orderController)
    try router.register(collection: storeController)
    try router.register(collection: tableController)
    try router.register(collection: cmsController)
    try router.register(collection: restaurantController)
}
