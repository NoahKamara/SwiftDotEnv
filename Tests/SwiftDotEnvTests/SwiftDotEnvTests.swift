import XCTest
@testable import SwiftDotEnv

final class SwiftDotEnvTests: XCTestCase {
    let path = FileManager.default.currentDirectoryPath + "/.env"
    var env: DotEnv!
    
    override func setUpWithError() throws {
        let envContent =
        """
        # COMMENT
        STRING=ThisIsAString # Inline Comment
        STRING_QUOTMARK="String with"
        INT=69
        BOOL_TRUE=true
        BOOL_TRUE_INT=1
        BOOL_TRUE_STR=yes
        
        \r\n
        \n
        \t
        
        BOOL_FALSE=false
        BOOL_FALSE_INT=0
        BOOL_FALSE_STR=no
        """
        
        FileManager.default.createFile(atPath: path, contents: envContent.data(using: .utf8))
        
        try env = DotEnv(fileAt: path)
    }
    
    // Test initializer relative path
    func test_init_absolute_succeeds() {
        do {
            _ = try DotEnv(fileAt: path)
        } catch {
            print(error)
            XCTFail()
        }
        
        let fakePath = FileManager.default.currentDirectoryPath + "/.notexistenv"
        do {
            _ = try DotEnv(fileAt: fakePath)
        } catch {
            switch error {
                case DotEnv.Errors.FileNotFound: break
                default: XCTFail()
            }
        }
    }
        
    // Test initializer relative path
    func test_init_relative() {
        do {
            _ = try DotEnv(fileAt: ".env")
        } catch {
            print(error)
            XCTFail()
        }
        
        let fakePath = ".notexistenv"
        do {
            _ = try DotEnv(fileAt: fakePath)
        } catch {
            switch error {
                case DotEnv.Errors.FileNotFound: break
                default: XCTFail()
            }
        }
    }
    
    /// Test get value by subscript
    func test_subscript() {
        let result = env["STRING"]
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "ThisIsAString")
    }
    
    /// Test get value
    func test_value() {
        let result = env.value("STRING")
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "ThisIsAString")
    }
    
    
    /// Test get value - with default
    func test_value_default() {
        var result = env.value("STRING", "DEFAULT")
        XCTAssertNotNil(result)
        XCTAssertNotEqual(result!, "DEFAULT")
        
        result = env.value("UNKNOWN", "DEFAULT")
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "DEFAULT")
    }
    
    
    /// Test get integer
    func test_int() {
        let result = env.int(for: "INT")
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 69)
    }
    
    /// Test get integer - with default
    func test_int_default() {
        var result = env.int(for: "UNKNOWN", 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
        
        result = env.int(for: "INT", 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 69)
        
        result = env.int(for: "STRING", 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
    }
    
    
    /// Test get bool (true/false)
    func test_bool_bool() {
        func test(_ result: Bool?, _ v: Bool, _ description: String) {
            XCTAssertNotNil(result)
            XCTAssertEqual(result, v)
        }
        
        // value: true
        var result = env.bool(for: "BOOL_TRUE")
        test(result, true, "Bool True")
        
        // value: false
        result = env.bool(for: "BOOL_FALSE")
        test(result, false, "Bool False")
    }
    
    
    /// Test get bool (1/0)
    func test_bool_int() {
        func test(_ result: Bool?, _ v: Bool, _ description: String) {
            XCTAssertNotNil(result)
            XCTAssertEqual(result, v)
        }
        
        // value: 1
        var result = env.bool(for: "BOOL_TRUE_INT")
        test(result, true, "Bool True Int")
        
        // value: 0
        result = env.bool(for: "BOOL_FALSE_INT")
        test(result, false, "Bool False Int")
    }
    
    
    /// Test get bool (yes/no)
    func test_bool_str() {
        func test(_ result: Bool?, _ v: Bool, _ description: String) {
            XCTAssertNotNil(result)
            XCTAssertEqual(result, v)
        }
        
        // value: yes
        var result = env.bool(for: "BOOL_TRUE_STR")
        test(result, true, "Bool True Str")
        
        // value: no
        result = env.bool(for: "BOOL_FALSE_STR")
        test(result, false, "Bool False Str")
    }
    
    
    /// Test get bool - with default
    func test_bool_default() {
        func test(_ result: Bool?, _ v: Bool, _ description: String) {
            XCTAssertNotNil(result)
            XCTAssertEqual(result, v)
        }
        
        var result = env.bool(for: "UNKNOWN")
        XCTAssertNil(result)
        
        result = env.bool(for: "UNKNOWN", true)
        test(result, true, "Bool Default")
        
        result = env.bool(for: "UNKNOWN", false)
        test(result, false, "Bool Default")
        
        result = env.bool(for: "STRING", false)
        test(result, false, "String Not Bool")
    }
    
    
    /// Test if comments where stripped
    func test_comment_stripping() {
        let result = env.value("# COMMENT")
        XCTAssertNil(result)
    }
    
    /// Test if empty lines where stript
    func test_emptyline_stripping() {
        var result = env.value("\r\n")
        XCTAssertNil(result)
        
        result = env.value("\n")
        XCTAssertNil(result)
    }
    
    
    /// Test if all variables where parsed
    func test_allVariablesContained() {
        let allVars = env.all()
        
        let variables = [
            "STRING",
            "STRING_QUOTMARK",
            "INT",
            "BOOL_TRUE",
            "BOOL_TRUE_INT",
            "BOOL_TRUE_STR",
            "BOOL_FALSE",
            "BOOL_FALSE_INT",
            "BOOL_FALSE_STR",
        ]
        
        variables.forEach { variable in
            XCTAssertTrue(allVars.contains(where: { $0.key == variable }), "Contains /(variable)")
        }
    }
}
