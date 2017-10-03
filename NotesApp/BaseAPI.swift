//
//  NoteAPI.swift
//  NotesApp
//
//  Created by Carmen Popa on 16/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import Foundation
import Alamofire

class BaseAPI: NSObject {
    
    internal let NOTE_URL = "http://188.241.116.20:8000"
    
    internal func isFailure(response: DataResponse<Any>, failure: (_ error: String) -> ()) -> Bool {
        if response.result.value == nil {
            failure("API not working")
            return true
        }
        
        if (response.response!.statusCode == 401) {
            failure("Authentication expired")
            return true
        }
        
        return false
    }
    
}
