
import Foundation
import Firebase
import FirebaseDatabase

class UsersData {

    var uid: String
    var email: String
    var password: String
    var location: String

    let ref: DatabaseReference?

    //This is an initualization for my products
    init(uid: String, email: String, password: String, location: String) {
        self.uid = uid
        self.email = email
        self.password = password
        self.location = location
        self.ref = nil
    }
    //new
    init(snapshotFunction: DataSnapshot) {
        let snapshotValue = snapshotFunction.value as! [String: AnyObject]
        uid = snapshotValue["uid"] as! String
        email = snapshotValue["email"] as! String
        password = snapshotValue["password"] as! String
        location = snapshotValue["location"] as! String
        ref = (snapshotValue["ref"] as? DatabaseReference?)!
    }

    func toAnyObject() -> Any {
        return [
            "uid": uid,
            "email": email,
            "password": password,
            "location": location
        ]
    }
}



