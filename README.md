# LastMile [![CircleCI](https://circleci.com/gh/jbelkins/LastMile-iOS.svg?style=shield)](https://circleci.com/gh/jbelkins/LastMile-iOS)
Robust decoding of model objects, tailored for use with JSON APIs

- Type-safe access to JSON from Swift
- Simple, clean syntax for decoding model objects
- Collects errors detailing abnormalities in the received JSON
- Built-in decoding for common Swift types

## LastMile vs. Swift Codable
LastMile aims exclusively to tackle the problem of building model objects from your API's JSON easily and consistently.  LastMile's not a substitute for Swift Codable, nor is Swift Codable a substitute for LastMile.  Rather, the two can be used side-by-side on the same model objects but for different purposes.

- _Harmonious coexistence._ You can use LastMile and Swift Codable independently on the same type.  Using LastMile for decoding API responses allows you to use Codable exclusively for internal serialization needs, resulting in cleaner, simpler, more focused code.
- _Flexibility._ LastMile reaches through multiple levels of JSON effortlessly.  If you need to reach deep into nested JSON to get `["items"][0]["values"][0]["name"]`, just say so.  Swift Decodable excels at decoding data that Swift encoded with Encodable on the same type, but it's not suited to pick values out of JSON that doesn't match the structure of your internal models. 
- _Resilience._ Swift Decodable throws an error and quits decoding when it hits an unexpected value, because such errors are unlikely when decoding data that was encoded internally.  LastMile keeps on decoding past the error, returning whatever it can salvage from JSON that has missing or mistyped fields.  If you decode an array of 100 values and one is malformed, LastMile will give you an array with the other 99 plus error objects describing why that bad element failed.  Codable will throw an error and return no part of the response.
- _Accountability._ LastMile makes a note of everything that is unexpectedly missing or in a different type than expected in your API response, and returns a list of everything wrong in the form of a collection of error objects, whether or not a response is returned.  The info from error objects can cut hours off of debugging and production downtime by leading you to the problem faster.  By contrast, Swift Decodable will give you one error per API response: the one that made it quit decoding.

## Using LastMile
(See test file [PersonTests.swift](https://github.com/jbelkins/LastMile-iOS/blob/master/LastMileTests/PersonTests.swift) in the project to see this demo code in operation.)

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
        "phone_number": "(312) 555-1212",
        "height": "really tall"
    }

(note that the value for `"height"` is unexpectedly a String instead of a number, as expected.)

And here is an `APIDecodable` extension for `Person` that will create a new instance:

    extension Person: APIDecodable {
	    static var idKey: String? { return "person_id" }

	    init?(from decoder: APIDecoder) {
	        // 1a
	        let id =          decoder["person_id"]    --> Int.self
	        let firstName =   decoder["first_name"]   --> String.self
	        let lastName =    decoder["last_name"]    --> String.self

	        // 1b
	        let phoneNumber = decoder["phone_number"] --> String?.self
	        let height =      decoder["height"]       --> Double?.self

	        // 2
	        guard decoder.succeeded else { return nil }

	        // 3
	        self.init(id: id!, firstName: firstName!, lastName: lastName!, phoneNumber: phoneNumber, height: height)
	    }
	}

There are three steps to this initializer:

1) The decoder is used to create all of the values required to initialize a `DemoStruct`.  Using one or more subscripts on the parser lets you safely access JSON subelements, then you use the `-->` operator with either a type that is (1a) `APIDecodable` or (1b) an optional `APIDecodable`.

2) The initializer fails by returning `nil` if `decoder.succeeded` is false.  This will happen whenever any non-optional value is not present.

3) Finally, the structure is initialized by calling the memberwise initializer.  Required values `id`, `firstName`, and `lastName` may be force-unwrapped safely if `decoder.succeeded` was true.

Since the value for `"height"` in the JSON above was unexpectedly a String instead of a number, an error object will be generated describing the problem and its location.

## Decoding

To decode a `Person` from a data object containing JSON received by HTTP:

    let decodeResult = APIDataDecoder().decode(data: data, to: Person.self)
    print(decodeResult.value ?? "nil")
    // prints:
    // Person(id: 8675309, firstName: "Mary", lastName: "Smith", phoneNumber: Optional("(312) 555-1212"), height: nil)

    decodeResult.errors.forEach { print($0) }
    // prints:
    // root(Person person_id=8675309) > "height"(Double) : Unexpectedly found a string
