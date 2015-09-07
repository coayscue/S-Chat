//
//  LockMenuViewController.swift
//  chat
//
//  Created by Christian Ayscue on 12/17/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import UIKit

class LockMenuViewController: UIViewController, UITextFieldDelegate {
    
    var lockInfo = NSUserDefaults.standardUserDefaults().dictionaryForKey("lockInfo") as Dictionary<String, AnyObject>?
    

    @IBOutlet weak var lockSwitch: UISwitch!
    
    @IBOutlet weak var password1: UITextField!
    
    @IBOutlet weak var password2: UITextField!
    
    @IBOutlet weak var hint: UITextField!

    @IBAction func save(sender: AnyObject) {
        println("saved")
        saveIt()
    }
    
    func saveIt(){
        
        if password1.text == password2.text{
            
            var lockInfo: [String: AnyObject] = ["locked":lockSwitch.on, "password": password1.text, "hint": hint.text]
            
            NSUserDefaults.standardUserDefaults().setObject(lockInfo, forKey: "lockInfo")

            self.navigationController?.popViewControllerAnimated(true)

            
        }else{
            password1.placeholder = "*Passwords did not match"
            password2.placeholder = "*Passwords did not match"
            password1.text = ""
            password2.text = ""
            
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()

        password1.delegate = self
        password2.delegate = self
        hint.delegate = self
        
        password1.text = lockInfo?["password"] as String
        password2.text = lockInfo?["password"] as String
        lockSwitch.on = lockInfo?["locked"] as Bool
        hint.text = lockInfo?["hint"] as String
        
        

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.isEqual(password1) {
            password2.becomeFirstResponder()
        }else if textField.isEqual(password2) {
            hint.becomeFirstResponder()
        }else{
            saveIt()
        }
        return true
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
