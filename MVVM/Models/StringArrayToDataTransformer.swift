import Foundation

public class StringArray: NSObject {
    var strings = [String]()
}

class StringArrayToDataTransformer: NSSecureUnarchiveFromDataTransformer {
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return StringArray.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
        }
        return super.transformedValue(data)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let strings = value as? StringArray else {
            fatalError("Wrong data type: value must be a NSArray object; received \(type(of: value))")
        }
        return super.reverseTransformedValue(strings)
    }
}

extension NSValueTransformerName {
    static let stringArrayToDataTransformer = NSValueTransformerName(rawValue: "StringArrayToDataTransformer")
}
