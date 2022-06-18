# LastMile [![CircleCI](https://circleci.com/gh/jbelkins/LastMile-iOS.svg?style=shield)](https://circleci.com/gh/jbelkins/LastMile-iOS)
Robust decoding of model objects, tailored for use with JSON APIs

- Type-safe, easy access to JSON from Swift
- Simple, clean, safe syntax for initializing model objects
- Collects errors detailing abnormalities in JSON
- Built-in decoding for common Swift types

## LastMile vs. Swift Codable
LastMile aims to tackle these important problems in decoding API JSON responses, which are weaknesses of decoding with Swift Codable:
- Building model objects easily, safely, and consistently from JSON that does not match the structure of models
- Salvaging as much data as possible when a decoding error occurs
- Generating rich error information that allows the developer to immediately pinpoint problems in either the data model or data itself

Continue to use Codable for internal serialization/deserialization, the role at which it is best suited, and use LastMile to create models from JSON received over the API.

LastMile decoding is different from Swift Codable decoding in these important ways:
- LastMile decoding can still succeed even if there are errors encountered while decoding the JSON.
- LastMile can return multiple errors for a single decoding operation.
- LastMile salvages and returns whatever it can when a decoding error occurs, while Swift Codable fails immediately.

Things LastMile gives you that Swift Codable doesn't:
- _Flexibility._ LastMile reaches through multiple levels of JSON effortlessly, so you can build model objects whose structure doesn't closely mirror the JSON.  If you need to reach deep into nested JSON to get `response["items"][0]["values"][0]["name"]`, for instance, just say so.  Swift Decodable isn't suited to pick values out of JSON that doesn't match the structure of your internal models. 
- _Resilience._ Swift Decodable throws an error and quits decoding when it hits an unexpected type or unexpectedly missing value.  LastMile keeps on decoding past the error, returning whatever it can salvage from JSON that has missing or mistyped fields.  If you decode an array of 100 values and one is malformed, LastMile will still give you an array with the other 99 plus an error object describing why that bad element failed to decode.  Codable will throw an error and return no part of the response.
- _Visibility._ LastMile makes a note of everything that is unexpectedly missing or in a different type than expected in your API response, and returns a list of everything wrong in the form of a collection of error objects, whether or not decoding is successful.  You can take these errors and record them in the crash / error reporting software of your choice.  The info from error objects can cut hours off of debugging and production downtime by leading you to the exact problem immediately.  By contrast, Swift Decodable will throw as soon as it encounters one error and dispose of everything it has decoded so far.

## Using LastMile

### With Cocoapods
Add it to your `Podfile`:
```
  pod 'LastMile'
```

### With Swift Package Manager
Add it to your `Package.swift` or to your Xcode project's Package Dependencies:
```
  .package("LastMile", url: "https://github.com/jbelkins/LastMile-iOS", version: "1.0.0")
```

### Code
_Note that this code is also demo'd in the Swift Playground included in this project._

Here is a sample model object:

    struct Person {
        let id: Int
        let firstName: String
        let lastName: String
        let phoneNumber: String?
        let height: Double?
    }

`id`, `firstName`, and `lastName` are required fields.  `phoneNumber` and `height` are optional.

Here is the JSON we will decode this object from:

    {
        "person_id": 8675309,
        "first_name": "Mary",
        "last_name": "Smith",
        "contact_info": {
	        "phone_number": "(312) 555-1212"
    	},
        "height": "really tall"
    }

(note that the value for `"height"` is unexpectedly a String instead of a number, as expected.)

And here is an `APIDecodable` extension for `Person` that will create a new instance:

    extension Person: APIDecodable {
	    static var idKey: String? { return "person_id" }

	    init?(from decoder: APIDecoder) {
	        // 1a
	        let id =          decoder["person_id"]                    --> Int.self
	        let firstName =   decoder["first_name"]                   --> String.self
	        let lastName =    decoder["last_name"]                    --> String.self

	        // 1b
	        let phoneNumber = decoder["contact_info"]["phone_number"] --> String?.self
	        let height =      decoder["height"]                       --> Double?.self

	        // 2
	        guard decoder.succeeded else { return nil }

	        // 3
	        self.init(id: id!, firstName: firstName!, lastName: lastName!, phoneNumber: phoneNumber, height: height)
	    }
	}

There are three steps to this initializer:

1) The decoder is used to create all of the values required to initialize a `DemoStruct`.  Using one or more subscripts on the decoder lets you safely access JSON subelements, then you use the `-->` operator with either a type that is (1a) `APIDecodable` or (1b) an optional `APIDecodable`.

2) The initializer fails by returning `nil` if `decoder.succeeded` is false.  This will happen whenever any non-optional value is not present.

3) Finally, the structure is initialized by calling the memberwise initializer.  Required values `id`, `firstName`, and `lastName` may be force-unwrapped safely since `decoder.succeeded` was true.

(The `static var idKey: String?` declaration helps to identify the specific data record that caused a decoding error.)

Since the value for `"height"` in the JSON above was unexpectedly a String instead of a number, an error object will be generated describing the problem and its location.  The error is stored in the `decoder` and may be accessed after decoding completes.

## Decoding

To decode a `Person` from a data object containing JSON received by HTTP:

    let decodeResult = APIDataDecoder().decode(data: data, to: Person.self)
    print(decodeResult.value ?? "nil")
    // prints:
    // Person(id: 8675309, firstName: "Mary", lastName: "Smith", phoneNumber: Optional("(312) 555-1212"), height: nil)

To see the errors generated while decoding:

    decodeResult.errors.forEach { print($0) }
    // prints:
    // root(Person person_id=8675309) > "height"(Double) : Unexpectedly found a string
