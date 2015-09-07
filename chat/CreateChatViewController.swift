//
//  CreateChatViewController.swift
//  chat
//
//  Created by Christian Ayscue on 12/21/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import UIKit


class CreateChatViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var chatID: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var password1: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func createChat(sender: AnyObject) {
        create()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.isEqual(chatID){
            password1.text = ""
            password2.text = ""
        }
    }
    
    func create(){
        
    password2.resignFirstResponder()
    password1.resignFirstResponder()
        
        if (password1.text == password2.text){
            
            activityIndicator.startAnimating()
            
            var chatQuery = PFQuery(className: "Chat")
            chatQuery.whereKey("chatID", equalTo: chatID.text)
            var error:NSError
            chatQuery.getFirstObjectInBackgroundWithBlock({ (chat, error) -> Void in
                
                if error != nil && chat != nil{
                    var alert = UIAlertController(title: "Error", message: "The network connection was lost.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: {(action)->Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                        self.navigationController?.popViewControllerAnimated(true)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                if chat != nil{
                    
                    self.activityIndicator.stopAnimating()
                    
                    self.password1.text = ""
                    self.password2.text = ""
                    self.chatID.text = ""
                    self.chatID.placeholder = "Chat Name taken"
                    UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                        self.chatID.center = CGPointMake(self.chatID.center.x - 15, self.chatID.center.y)
                        }, completion: { (poop) -> Void in
                            UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                                self.chatID.center = CGPointMake(self.chatID.center.x + 15, self.chatID.center.y)
                                }, completion: { (poop) -> Void in
                                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                                        self.chatID.center = CGPointMake(self.chatID.center.x - 15, self.chatID.center.y)
                                    })
                            })
                    })
                }else{
                    var chat = PFObject(className: "Chat")
                    
                    chat.saveInBackgroundWithBlock { (success, error) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        
                        if error != nil{
                            var alert = UIAlertController(title: "Error", message: "The network connection was lost.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: {(action)->Void in
                                self.dismissViewControllerAnimated(false, completion: nil)
                                self.navigationController?.popViewControllerAnimated(true)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                        if error == nil && success{
                            
                            //set all the atributes
                            chat["chatID"] = self.chatID.text
                            chat["password"] = self.password1.text
                            chat["peopleCount"] = 1
                            var date = NSDate().descriptionWithLocale(NSLocale.currentLocale())
                            chat["lastMessageDate"] = date
                            chat["messages"] = [[String:AnyObject]]()
                            chat.saveInBackgroundWithBlock(nil)
                            
                            NSUserDefaults.standardUserDefaults().setObject(["People": "You", "Messages": [], "YourID":"P"+String(1),"Password":self.password1.text, "Seen":false], forKey: self.chatID.text)
                            
                            //inserts the chat ID at the head of the charOrder array
                            var chatOrder = NSUserDefaults.standardUserDefaults().arrayForKey("chatOrder") as Array<String>!
                            
                            chatOrder.insert(self.chatID.text, atIndex: 0)
                            
                            NSUserDefaults.standardUserDefaults().setObject(chatOrder, forKey: "chatOrder")
                            
                            println(self.chatID.text)
                            println(self.password1.text)
                            
                            //registering for push notifications
                            var userNotificationTypes = (UIUserNotificationType.Alert |
                                UIUserNotificationType.Badge |
                                UIUserNotificationType.Sound);
                            var settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
                            
                            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                            UIApplication.sharedApplication().registerForRemoteNotifications()
                            
                            // When users enter chat, we subscribe them to that channel
                            var currentInstallation = PFInstallation.currentInstallation()
                            currentInstallation.addUniqueObject(chat["chatID"], forKey:"channels")
                            var error = NSError()
                            currentInstallation.saveInBackgroundWithBlock(nil)
                            
                            selectedChat = self.chatID.text
                            self.performSegueWithIdentifier("sendInfo", sender: self)
                        }
                    }
                }
            })
            
        }else{
            
            password1.placeholder = "*Passwords did not match"
            password2.placeholder = "*Passwords did not match"
            password1.text = ""
            password2.text = ""
            password1.becomeFirstResponder()
            
            UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                self.password1.center = CGPointMake(self.password1.center.x - 15, self.password1.center.y)
                self.password2.center = CGPointMake(self.password2.center.x - 15, self.password2.center.y)
                }, completion: { (poop) -> Void in
                    UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                        self.password1.center = CGPointMake(self.password1.center.x + 15, self.password1.center.y)
                        self.password2.center = CGPointMake(self.password2.center.x + 15, self.password2.center.y)
                        }, completion: { (poop) -> Void in
                            UIView.animateWithDuration(0.1, animations: { () -> Void in
                                self.password1.center = CGPointMake(self.password1.center.x - 15, self.password1.center.y)
                                self.password2.center = CGPointMake(self.password2.center.x - 15, self.password2.center.y)
                            })
                    })
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        var colorView = UIImageView(image: UIImage(named: "grayGround.png")?.applyTintEffectWithColor(UIColor.blackColor().colorWithAlphaComponent(0.7)))
        
        colorView.frame = CGRectMake(0,0,self.view.frame.width, self.navigationController!.navigationBar.frame.height+UIApplication.sharedApplication().statusBarFrame.height)
        self.view.addSubview(colorView)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.isEqual(chatID) {
            password1.becomeFirstResponder()
        }else if textField.isEqual(password1) {
            password2.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            create()
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()
        chatID.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
