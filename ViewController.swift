//
//  ViewController.swift
//  Broadcaster
//
//  Created by Bruno Chroniaris on 11/19/15.
//  Copyright © 2015 UNIUM. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import ysocket

class ViewController: UIViewController, NSStreamDelegate {

    @IBOutlet weak var button: UIButton!
    private var inputStream: NSInputStream!
    private var outputStream: NSOutputStream!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.createConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendData(){
        //let response = "Hello World!!\r\n"
        //let data = NSData(data: response.dataUsingEncoding(NSASCIIStringEncoding)!)
        //println("response: \(response) data.length: \(data.length)")
        
        //outputStream?.write(UnsafePointer<UInt8>(data.bytes) , maxLength: data.length)
        
        
        //GCDAsyncUdpSocket().sendData(("Hello World!" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!, toAddress: address, withTimeout: 2.0, tag: 6)
        GCDAsyncUdpSocket().sendData(("Hello World!" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!, toHost: "255.255.255.255", port: 8760, withTimeout: 20.0, tag: 6)
        let client: UDPClient = UDPClient(addr: "255.255.255.255", port: 8760)
        let result = client.send(str: "Hello World!")
        print(result)
    }
    @IBAction func connectPressed(sender: AnyObject) {
        self.createConnection()
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        self.sendData()
    }
    
    func createConnection() {
        var readStream: Unmanaged<CFReadStreamRef>?
        var writeStream: Unmanaged<CFWriteStreamRef>?
        CFStreamCreatePairWithSocketToHost(nil, "255.255.255.255" as CFStringRef, 8760, &readStream, &writeStream)
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch eventCode{
        case NSStreamEvent.OpenCompleted:
            print("Stream opened")
            break
        case NSStreamEvent.HasSpaceAvailable:
            if outputStream == aStream{
                print("outputstream is ready!")
            }
            break
        case NSStreamEvent.HasBytesAvailable:
            print("has bytes")
            if aStream == inputStream{
                var buffer: UInt8 = 0
                var len: Int!
                
                while (inputStream?.hasBytesAvailable != nil){
                    len = inputStream?.read(&buffer, maxLength: 1024)
                    if len > 0{
                        var output = NSString(bytes: &buffer, length: len, encoding: NSASCIIStringEncoding)
                        
                        if nil != output{
                            print("Server said: \(output)")
                            output = output?.substringFromIndex(11)
                        }
                    }
                }
            }
            break
        case NSStreamEvent.ErrorOccurred:
            print("Can not connect to the host!")
            break
        case NSStreamEvent.EndEncountered:
            outputStream.close()
            outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            outputStream = nil
            print("EndEncountered")
            break
        default:
            print("Unknown event")
        }
    }
}

