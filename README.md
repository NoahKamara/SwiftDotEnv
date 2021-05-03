# SwiftDotEnv

Swift 5 library for accessing environment variables from .env files



## Installation

Install using [Swift Package Manager](https://swift.org/package-manager/).

Add Dependency:
```swift
.package(name: "SwiftDotEnv", url: "https://github.com/noahkamara/swiftdotenv", from: "1.0.0")
```


## Usage

```swift
import SwiftDotEnv

let envPath = ".env" // or absolute path
let env = DotEnv(withFile: envPath)

// Retrieve variable 'VAR' and default to "DEFAULTVALUE"
let var = env.value("VAR", "DEFAULTVALUE")
```

### Getter Methods:

```swift 
value(_ key: String, _ default: String? = nil) -> String? 
```
> Returns the value for`key` in the environment, returning `default` if not present
> - Parameter `key`: Variable key
> - Parameter `default`: Default value



```swift
int(for key: String, _ default: Int? = nil) -> Int?
```
> Returns the integer value for `key` in the environment, returning `default` if not present
> - Parameter `key`: Variable key
> - Parameter `default`: Default value


```swift 
bool(for key: String, _ default: Bool? = nil) -> Bool?
```
> Returns the boolean value for `key` in the environment, returning `default` if not present
> - Parameter `key`: Variable key
> - Parameter `default`: Default value

### Subscript Access:
You can also access variables by subscript (this will return a string!)
```swift
let var = env["VAR"]
```


## The `.env`-file
This is an example for a .env file and also all supported types:
```env
# COMMENT
STRING=ThisIsAString # Inline Comment
STRING_QUOTMARK="String with"
INT=69
BOOL_TRUE=true
BOOL_TRUE_INT=1
BOOL_TRUE_STR=yes
BOOL_FALSE=false
BOOL_FALSE_INT=0
BOOL_FALSE_STR=no
```

## Support for Values-Types
*Comments*
```env
# This is a comment
KEY=VALUE
```

*Inline Comments*
```env
KEY=VALUE # Inline Comment
```

*Strings*
```env
STRING=ThisIsASupportedString
QUOTES="This is also a supported String"
```

*Integers*
```env
INTEGER=42
```

*Booleans*
```env
# Will be evaluated as true:
BOOL1=true
BOOL2=1
BOOL3=yes

# Will be evaluated as false
BOOL4=false
BOOL5=0
BOOL6=no
```
