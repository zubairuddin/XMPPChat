//
//  ViewController.swift
//  XMPPChat
//
//  Created by Zubair.Nagori on 22/11/18.
//  Copyright © 2018 Applligent. All rights reserved.
//

import UIKit
import XMPPFramework

class ViewController: UIViewController {

    var stream:XMPPStream!
    
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)

        stream = XMPPStream()
        stream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        stream.myJID = XMPPJID(string: "user1@localhost")
        stream.hostName = "localhost"
        stream.hostPort = 5222
        
        
        xmppRoster.activate(stream)
        
        do {
            try stream.connect(withTimeout: 30)
        }
            
        catch {
            print("error occured in connecting")
        }

    }
    @IBAction func sendMessage(_ sender: UIButton) {
        let message = "Test Message!"
        let senderJID = XMPPJID(string: "user2@localhost")
        let msg = XMPPMessage(type: "chat", to: senderJID)
        
        msg.addBody(message)
        stream.send(msg)

    }
}

extension ViewController: XMPPStreamDelegate {
    func xmppStreamWillConnect(_ sender: XMPPStream) {
        print("Will connect called.")
    }
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("Stream connect timeout.")
    }
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        print("Stream did connect")
        
        do {
            try sender.authenticate(withPassword: "123456")
        }
        catch {
            print("catch")
        }
    }
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("Stream authenticated successfully")
        sender.send(XMPPPresence())
    }
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("Stream failed to authenticate with error: \(error)")
    }
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        
        let presenceType = presence.type!
        let username = sender.myJID!.user
        let presenceFromUser = presence.from!.user

        if presenceFromUser != username  {
            if presenceType == "available" {
                print("available")
            }
            else if presenceType == "subscribe" {
                self.xmppRoster.subscribePresence(toUser: presence.from!)
            }
            else {
                print("presence type: \(presenceType)")
            }
        }
    }
}

