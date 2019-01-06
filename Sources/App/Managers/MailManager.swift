//
//  MailManager.swift
//  App
//
//  Created by Malcolmn Roberts on 2019/01/06.
//

import Foundation
import MailCore
import Vapor

enum EmailType: String {
    case Info = "info@servus.co.za"
    case Support = "support@servus.co.za"
}

class MailManager: NSObject { 

    /// Singleton
    static let shared = MailManager()
    
    // MARK: - Initialisation
    override private init() {
        super.init()
    }
    
    func sendEmailTo(emailAddress: String, usingEmail: EmailType, usingRequest: Request) -> Future<HTTPStatus> {
        // send email to address given
        
        var subject: String = ""
        var text: String = ""
        
        switch usingEmail {
            
        case .Info:
            subject = "General Info"
            text = "Hello this just for lauches and giggles"
            
        case .Support:
            subject = "Support Info"
            text = "This is serious theres an issue"
            
        }
        
        let mail = Mailer.Message(from: emailAddress, to: usingEmail.rawValue, subject: subject, text: text)
        
        do {
            try usingRequest.mail.send(mail).always {
                
            }
        } catch {
            //handle error
            print(error)
        }
        
        return Future.map(on: usingRequest) { return HTTPStatus.ok }
    }
    
}
