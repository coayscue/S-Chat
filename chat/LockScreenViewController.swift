//
//  LockScreenViewController.swift
//  chat
//
//  Created by Christian Ayscue on 12/17/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import UIKit

class LockScreenViewController: UIViewController, UITextFieldDelegate {
    
    var lockInfo: Dictionary<String, AnyObject>? = NSUserDefaults.standardUserDefaults().dictionaryForKey("lockInfo") as! Dictionary<String, AnyObject>?
    var wrongGuesses: Int = 0
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func checkPassword(sender: UIButton) {
        
        if password.text == lockInfo?["password"] as? String{
            self.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            
            UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                self.password.center = CGPointMake(self.password.center.x - 20, self.password.center.y)
                }, completion: { (poop) -> Void in
                    UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                        self.password.center = CGPointMake(self.password.center.x + 20, self.password.center.y)
                        }, completion: { (poop) -> Void in
                            UIView.animateWithDuration(0.1, animations: { () -> Void in
                                self.password.center = CGPointMake(self.password.center.x - 20, self.password.center.y)
                            })
                    })
            })
            
            password.text = ""
            wrongGuesses++
            if wrongGuesses == 2 {
                password.placeholder = lockInfo?["hint"] as? String
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        println(password)
        
        password.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        if password.text == lockInfo?["password"] as? String{
            
        } else {
            
            UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                self.password.center = CGPointMake(self.password.center.x - 20, self.password.center.y)
                }, completion: { (poop) -> Void in
                    UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: { () -> Void in
                        self.password.center = CGPointMake(self.password.center.x + 20, self.password.center.y)
                        }, completion: { (poop) -> Void in
                            UIView.animateWithDuration(0.1, animations: { () -> Void in
                                self.password.center = CGPointMake(self.password.center.x - 20, self.password.center.y)
                            })
                    })
            })
            
            password.text = ""
            wrongGuesses++
            if wrongGuesses == 2 {
                password.placeholder = lockInfo?["hint"] as? String
            }
        }

        return false
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
