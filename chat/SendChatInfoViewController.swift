//
//  SendChatInfoViewController.swift
//  chat
//
//  Created by Christian Ayscue on 12/30/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import UIKit
import MessageUI

class SendChatInfoViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate {

    var chatsInfo: Dictionary<String, Dictionary<String, AnyObject>>?
    var chatInfo: [String: AnyObject]
    var chatID: String
    var chatPassword: String
    
    required init(coder aDecoder: NSCoder) {
        
        chatInfo = NSUserDefaults.standardUserDefaults().dictionaryForKey(selectedChat) as Dictionary<String, AnyObject>
        chatID = selectedChat
        chatPassword = chatInfo["Password"] as String
        super.init(coder: aDecoder)
    }

    @IBAction func done(sender: AnyObject) {
        self.performSegueWithIdentifier("doneSendingInfo", sender: self)
    }
    
    @IBOutlet weak var textField: UITextView!

    @IBAction func SendInfo(sender: AnyObject) {
        if MFMessageComposeViewController.canSendText(){
            var picker = MFMessageComposeViewController()
            picker.messageComposeDelegate = self
            picker.body = "1. Download S-Quack: link.com\n2. Click: +\n3. Choose: \"Enter a chat\"\n______________________\nChat ID:  \(chatID)\nPassword:  \(chatPassword)"
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendByMail(sender: AnyObject) {
        
        if MFMailComposeViewController.canSendMail(){
            var picker = MFMailComposeViewController()
            picker.setSubject("Private Messaging")
            picker.setMessageBody("1. Download S-Quack: link.com\n2. Click: +\n3. Choose: \"Enter a chat\"\n______________________\nChat ID:  \(chatID)\nPassword:  \(chatPassword)", isHTML: false)
            picker.mailComposeDelegate = self
            self.presentViewController(picker, animated: true, completion: nil)
            
        }
    }
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()
        
        textField.text = "1. Download S-Quack: link.com\n2. Click: +\n3. Choose: \"Enter a chat\"\n______________________\nChat ID:  \(chatID)\nPassword:  \(chatPassword)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //set navigationbar background
        var colorView = UIImageView(image: UIImage(named: "grayGround.png")?.applyTintEffectWithColor(UIColor.blackColor().colorWithAlphaComponent(0.7)))
        
        colorView.frame = CGRectMake(0,0,self.view.frame.width, self.navigationController!.navigationBar.frame.height+UIApplication.sharedApplication().statusBarFrame.height)
        self.view.addSubview(colorView)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.resignFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
