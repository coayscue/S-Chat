//
//  EnterChatViewController.swift
//  chat
//
//  Created by Christian Ayscue on 12/18/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import UIKit

class EnterChatViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var chatID: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func enter(sender: AnyObject) {
        enterChat()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(chatID){
            password.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            self.enterChat()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.isEqual(chatID){
            password.text = ""
        }
    }
    
    func enterChat(){
        
        password.resignFirstResponder()
        
        var chatsInfo = NSUserDefaults.standardUserDefaults().objectForKey("chatsInfo") as Dictionary<String,AnyObject>?
        
        //check if the chat exists
        var query = PFQuery(className: "Chat")
        query.whereKey("chatID", equalTo: chatID.text)
        var error = NSError()
        activityIndicator.startAnimating()
        query.getFirstObjectInBackgroundWithBlock { (chat, error) -> Void in
            self.activityIndicator.stopAnimating()
            //show an error alert if there was an error
            if error != nil{
                var alert = UIAlertController(title: "Error", message: "The network connection was lost.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {(action)->Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.navigationController?.popViewControllerAnimated(true)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            if chat != nil && error == nil{//if the chat was found
                if chat["password"] as NSString == self.password.text{ //if the password was correct, enter the chat
                    
                    
                    var peopleCount = chat["peopleCount"] as Int
                    chat["peopleCount"] = peopleCount + 1
                    var yourID: String = "P"+String(peopleCount + 1)
                    
                    chat.save()
                    
                    //creates peoplenames array
                    var peopleNames: String = "You"
                    for var i = 1; i <= peopleCount; i += 1{
                        peopleNames += (", P"+String(i))
                    }
                    
                    NSUserDefaults.standardUserDefaults().setObject(["People": peopleNames, "Messages": [String](), "YourID": yourID, "Password":chat["password"], "Seen":false], forKey: (chat["chatID"] as String))
                    
                    //insert the chat ID at the head of the charOrder array
                    var chatOrder = NSUserDefaults.standardUserDefaults().arrayForKey("chatOrder") as Array<String>!
                    chatOrder.insert(self.chatID.text, atIndex: 0)
                    NSUserDefaults.standardUserDefaults().setObject(chatOrder, forKey: "chatOrder")
                    
                    //registering for push notifications
                    var userNotificationTypes = (UIUserNotificationType.Alert |
                        UIUserNotificationType.Badge |
                        UIUserNotificationType.Sound);
                    var settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
                    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                    UIApplication.sharedApplication().registerForRemoteNotifications()
                    
                    // When users enter chat, we subscribe them to that channel.
                    var currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation.addUniqueObject(chat["chatID"], forKey:"channels")
                    var error = NSError()
                    currentInstallation.saveInBackgroundWithBlock(nil)
                    
                    //go back to table view
                    self.performSegueWithIdentifier("enterIt", sender: self)
                    
                }else{ //if the password was incorrect
                    self.chatID.placeholder = ""
                    self.password.placeholder = "*Incorrect password"
                    self.password.text = ""
                    self.password.becomeFirstResponder()
                    
                    UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                        self.password.center = CGPointMake(self.password.center.x - 15, self.password.center.y)
                        self.chatID.center = CGPointMake(self.chatID.center.x - 15, self.chatID.center.y)
                        }, completion: { (poop) -> Void in
                            UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                                self.password.center = CGPointMake(self.password.center.x + 15, self.password.center.y)
                                self.chatID.center = CGPointMake(self.chatID.center.x + 15, self.chatID.center.y)
                                }, completion: { (poop) -> Void in
                                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                                        self.password.center = CGPointMake(self.password.center.x - 15, self.password.center.y)
                                        self.chatID.center = CGPointMake(self.chatID.center.x - 15, self.chatID.center.y)
                                    })
                            })
                    })
                }
            }else if (error == nil){ //if the chat was not found
                self.chatID.placeholder = "*Chat not found"
                self.chatID.text = ""
                self.password.placeholder = ""
                self.password.text = ""
                self.chatID.becomeFirstResponder()
                
                UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                    self.password.center = CGPointMake(self.password.center.x - 15, self.password.center.y)
                    self.chatID.center = CGPointMake(self.chatID.center.x - 15, self.chatID.center.y)
                    }, completion: { (poop) -> Void in
                        UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                            self.password.center = CGPointMake(self.password.center.x + 15, self.password.center.y)
                            self.chatID.center = CGPointMake(self.chatID.center.x + 15, self.chatID.center.y)
                            }, completion: { (poop) -> Void in
                                UIView.animateWithDuration(0.1, animations: { () -> Void in
                                    self.password.center = CGPointMake(self.password.center.x - 15, self.password.center.y)
                                    self.chatID.center = CGPointMake(self.chatID.center.x - 15, self.chatID.center.y)
                                })
                        })
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //sets appearance of navigation bar
        var colorView = UIImageView(image: UIImage(named: "grayGround.png")?.applyTintEffectWithColor(UIColor.blackColor().colorWithAlphaComponent(0.7)))
        colorView.frame = CGRectMake(0,0,self.view.frame.width, self.navigationController!.navigationBar.frame.height+UIApplication.sharedApplication().statusBarFrame.height)
        self.view.addSubview(colorView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()
        
        chatID.becomeFirstResponder()
        
        activityIndicator.hidesWhenStopped = true
        
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
