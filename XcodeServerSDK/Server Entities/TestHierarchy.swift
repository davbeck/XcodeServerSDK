//
//  TestHierarchy.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 15/07/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

let TestResultAggregateKey = "_xcsAggrDeviceStatus"

public class TestHierarchy : XcodeServerEntity {
    
    typealias TestResult = [String: Double]
    typealias AggregateResult = TestResult
    
    enum TestMethod {
        case Method(TestResult)
        case Aggregate(AggregateResult)
    }
    
    enum TestClass {
        case Class([String: TestMethod])
        case Aggregate(AggregateResult)
    }
    
    typealias TestTarget = [String: TestClass]
    typealias TestData = [String: TestTarget]
    
    let testData: TestData
    
    /*
    the json looks like this:
    {
        //target
        "XcodeServerSDKTest": {
            
            //class
            "BotParsingTests": {
                
                //method
                "testParseOSXBot()": {
    
                    //device -> number (bool)
                    "12345-67890": 1,
                    "09876-54321": 0
                },
                "testShared()": {
                    "12345-67890": 1,
                    "09876-54321": 1
                }
                "_xcsAggrDeviceStatus": {
                    "12345-67890": 1,
                    "09876-54321": 0
                }
            },
            "_xcsAggrDeviceStatus": {
                "12345-67890": 1,
                "09876-54321": 0
            }
        }
    }
    
    As a class and a method, there's always another key-value pair, with key "_xcsAggrDeviceStatus",
    which is the aggregated status, so that you don't have to iterate through all tests to figure it out yourself. 1 if all are 1, 0 otherwise.
    */
    
    public required init(json: [String:Any]) throws {
        
        //TODO: come up with useful things to parse
        //TODO: add search capabilities, aggregate generation etc

		self.testData = TestHierarchy.pullData(json: json)
        
        try super.init(json: json)
    }
    
    class func pullData(json: [String:Any]) -> TestData {
        
        var data = TestData()
        
        for (_targetName, _targetData) in json {
            let targetName = _targetName
            let targetData = _targetData as! [String:Any]
			data[targetName] = pullTarget(named: targetName, targetData: targetData)
        }
        
        return data
    }
    
    class func pullTarget(named targetName: String, targetData: [String:Any]) -> TestTarget {
        var target = TestTarget()
        
        for (_className, _classData) in targetData {
            let className = _className
            let classData = _classData as! [String:Any]
			target[className] = pullClass(named: className, classData: classData)
        }
        
        return target
    }
    
    class func pullClass(named className: String, classData: [String:Any]) -> TestClass {
        let classy: TestClass
        if className == TestResultAggregateKey {
            classy = TestClass.Aggregate(classData as! AggregateResult)
        } else {
            
            var newData = [String: TestMethod]()
            
            for (_methodName, _methodData) in classData {
                let methodName = _methodName
                let methodData = _methodData as! [String:Any]
				newData[methodName] = pullMethod(named: methodName, methodData: methodData)
            }
            
            classy = TestClass.Class(newData)
        }
        return classy
    }
    
    class func pullMethod(named methodName: String, methodData: [String:Any]) -> TestMethod {
        
        let method: TestMethod
        if methodName == TestResultAggregateKey {
            method = TestMethod.Aggregate(methodData as! AggregateResult)
        } else {
            method = TestMethod.Method(methodData as! TestResult)
        }
        return method
    }
}
