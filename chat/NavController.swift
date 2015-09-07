//
//  NavController.swift
//  chat
//
//  Created by Christian Ayscue on 1/1/15.
//  Copyright (c) 2015 coayscue. All rights reserved.
//

import UIKit

class NavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.tintColor = UIColor.cyanColor()
        
        //makes the bar transparent
        var rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
        var color = UIColor.clearColor()//.colorWithAlphaComponent(1.0) //desired color and alpha
        color.setFill()
        UIRectFill(rect);
        var image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UINavigationBar.appearance().setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
        
        
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
