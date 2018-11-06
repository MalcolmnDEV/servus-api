//
//  Response.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/15.
//

import Foundation

struct Response{
    private var success:Bool
    private var message:String
    private var data:Any
    
    init(withSuccess: Bool, responseMessage: String, returnedData: Any) {
        self.success = withSuccess
        self.message = responseMessage
        self.data = returnedData
    }
}
