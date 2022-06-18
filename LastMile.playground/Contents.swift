import Foundation
import PlaygroundSupport
import LastMile


// https://github.com/jbelkins/LastMile-iOS


// This code example is discussed in this project's README file.
// See the discussion there for more info.


struct Person {
    let id: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let height: Double?
}


extension Person: APIDecodable {
    static var idKey: String? { return "person_id" }

    init?(from decoder: APIDecoder) {
        // Decode the required values into variables
        let id =          decoder["person_id"]                    --> Int.self
        let firstName =   decoder["first_name"]                   --> String.self
        let lastName =    decoder["last_name"]                    --> String.self

        // Decode the optional values into variables
        let phoneNumber = decoder["contact_info"]["phone_number"] --> String?.self
        let height =      decoder["height"]                       --> Double?.self

        // Check to see if all required values were able to be decoded, fail initializer if not
        guard decoder.succeeded else { return nil }

        // Delegate to memberwise initializer to finish initialization
        self.init(id: id!, firstName: firstName!, lastName: lastName!, phoneNumber: phoneNumber, height: height)
    }
}


let validJSONObject: [String: Any] = [
    "person_id": 8675309,
    "first_name": "Mary",
    "last_name": "Smith",
    "contact_info": [
        "phone_number": "(312) 555-1212"
    ],
    "height": 72.5
]

tryDecoding(name: "Valid", object: validJSONObject)


let validWithErrorJSONObject: [String: Any] = [
    "person_id": 8675309,
    "first_name": "Mary",
    "last_name": 456,           // Last name is expected to be a String
    "contact_info": [
        "phone_number": "(312) 555-1212"
    ],
    "height": 72.5
]

tryDecoding(name: "Valid, but with 1 error", object: validWithErrorJSONObject)


let invalidJSONObject: [String: Any] = [
    "person_id": 123.4,         // id is expected to be an Int
    // First name is a required field and is missing
    "last_name": "Smith",
    "contact_info": [
        "phone_number": "(312) 555-1212"
    ],
    "height": 72.5
]

tryDecoding(name: "Invalid, with 2 errors", object: invalidJSONObject)


// Helper method
func tryDecoding(name: String, object: Any) {
    let data = try! JSONSerialization.data(withJSONObject: object)
    let result = APIDataDecoder().decode(data: data, to: Person.self)

    print("~~~~~~~~~~~~~~~ \(name) ~~~~~~~~~~~~~~~")
    if let record = result.value {
        print("Parsed record: \(record)")
    } else {
        print("Nil record")
    }
    if result.errors.count > 0 {
        print("Errors:\n  \(result.errors.map(\.description).joined(separator: "\n  "))")
    } else {
        print("No errors")
    }
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    print()
    print()
}
