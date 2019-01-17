//
//  Endpoint.swift
//  App
//
//  Created by Malcolmn Roberts on 2019/01/17.
//

import Reset

internal struct Endpoint {
    enum API {}
    enum Backend {}
}

// MARK: API

internal extension Endpoint.API {
    private static let api = "/api"
    
    enum Users {
        private static let users = api + "/user"
        
        enum ResetPassword {
            private static let resetPassword = users + "/reset-password"
            static let request = resetPassword + "/request"
            static let renderReset = resetPassword
            static let reset = resetPassword
        }
    }
}

// MARK: Reset

internal extension ResetEndpoints {
    internal static var apiPrefixed: ResetEndpoints {
        return .init(
            resetPasswordRequest: Endpoint.API.Users.ResetPassword.request,
            renderResetPassword: Endpoint.API.Users.ResetPassword.renderReset,
            resetPassword: Endpoint.API.Users.ResetPassword.reset
        )
    }
}
