//
//  NoteAPI.swift
//  NotesApp
//
//  Created by Carmen Popa on 16/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import Foundation
import Alamofire

class NoteAPI: BaseAPI {
    
    func requestAuthentication(userID: String,
                          success: @escaping (_ token: String) -> (),
                          failure: @escaping (_ error:String) -> ()) {
        let parameters = ["id": userID]
        Alamofire.request(NOTE_URL+"/authentication", method: .get,  parameters: parameters).responseJSON
            { (response) in
                if (super.isFailure(response: response, failure: failure)) {
                return
                }
                let responseJson = response.result.value as! [String: AnyObject]
                let data = responseJson["data"]
                let token = data?["token"]
                success(token as! String)
        }
    }
    
    func requestAllNotes(token: String,
                  success: @escaping (_ noteArray: [[String: AnyObject]]) -> (),
                  failure: @escaping (_ error:String) -> ()) {
        
        let headers = ["x-auth-token": token]
        Alamofire.request(NOTE_URL+"/notes", method: .get, headers: headers).responseJSON
            { (response) in
                if (super.isFailure(response: response, failure: failure)) {
                    return
                }
                let responseJson = response.result.value as! [String: AnyObject]
                let apiNotesArray = responseJson["data"] as! [[String: AnyObject]]
                
                success(apiNotesArray)
        }
    }
    
    func requestDeleteNote(token: String, lastUpdated: Int64, id: String,
                    success: @escaping () -> (),
                    failure: @escaping (_ error: String) -> ()) {
        let headers = ["x-auth-token": token,
                       "x-last-sync": String(describing:lastUpdated),
                       "x-note-id": id] as [String : String]
        
        let parameters = ["id": id] as [String : Any]
        
        Alamofire.request(NOTE_URL+"/notes", method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if (super.isFailure(response: response, failure: failure)) {
                return
            }
            success() 
        }
    }
    
    func requestUpdateNote(token: String, note: NoteModel,
                    success: @escaping () -> (),
                    failure: @escaping (_ error: String) -> ()) {
        
        let headers = ["x-auth-token": token,
                       "x-last-sync": String(describing:note.lastUpdate)] as [String: String]
        
        let parameters = ["id": note.id,
                          "title": note.title ?? "",
                          "lastUpdate": note.lastUpdate,
                          "content": note.detail ?? "",
                          "isArchived" : 0,
                          "attachments": []
                        ] as [String : Any]
        
        Alamofire.request(NOTE_URL+"/notes", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
           
            if (super.isFailure(response: response, failure: failure)) {
                return
            }
            success()
        }
    }
}
