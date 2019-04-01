//
//  ViewController.swift
//  thermo
//
//  Created by Cameron Krischel on 3/31/19.
//  Copyright © 2019 Cameron Krischel. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    let screenSize = UIScreen.main.bounds
    var circleRadius = CGFloat(0)
    
    var labelArray = [UILabel]()
    
    var animatorArray = [UIDynamicAnimator]()
    var gravity = UIGravityBehavior()
    var collision = UICollisionBehavior()
    var bounce = UIDynamicItemBehavior()
    
    var gravityArray = [UIGravityBehavior]()
    
    var ogX = CGFloat(0)
    var ogY = CGFloat(0)
    
    var grav = CGFloat(1)
    
    var recentX = CGFloat(0)
    var recentY = CGFloat(0)

    var swimmerCount = 10
    
    var traceArray = [CAShapeLayer]()
    var traceCount = 1000
    var traceSize = CGFloat(4)
    var traceColor = UIColor.red.cgColor
    
    var timeInterval    = 0.00001
    var timeCount = Double(0)
    var countRatio      = 0.0001
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        circleRadius = screenSize.width/16
        
        ogX = screenSize.width/2
        ogY = screenSize.height/2 - screenSize.height/4
        
        var centerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: circleRadius, height: circleRadius))
        centerLabel.center.x = screenSize.width/2
        centerLabel.center.y = screenSize.height/2
        centerLabel.text = ""
        centerLabel.textAlignment = .center
        centerLabel.layer.cornerRadius = centerLabel.frame.width/2
        centerLabel.layer.borderWidth = 1.0
        centerLabel.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(centerLabel)
        
        for i in 0...swimmerCount-1
        {
            makeSwimmer(myXPos: CGFloat(arc4random_uniform(UInt32(screenSize.width))), myYPos: CGFloat(arc4random_uniform(UInt32(screenSize.height))), myName: String(i))
//            makeSwimmer(myXPos: ogX, myYPos: ogY)
        }
        
        
        worldSetup()
        
        let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateGravity), userInfo: nil, repeats: true)
    }
    func makeSwimmer(myXPos: CGFloat, myYPos: CGFloat, myName: String)
    {
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: circleRadius, height: circleRadius))
        label.center.x = myXPos
        label.center.y = myYPos
        label.text = myName
        label.textColor = UIColor.white
        label.layer.backgroundColor = UIColor.black.cgColor
        label.textAlignment = .center
        label.layer.cornerRadius = label.frame.width/2
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.zPosition = 1
        labelArray.append(label)
        self.view.addSubview(label)
    }
    
    @objc func updateGravity()
    {
        for i in 0...labelArray.count-1
        {
            var currentX = labelArray[i].center.x
            var currentY = labelArray[i].center.y
            
            if(currentX == ogX && currentY == ogY)
            {
                print("RETURNED TO STARTING POSITION")
            }
            
            var desiredX = screenSize.width/2
            var desiredY = screenSize.height/2
            
            var dX = (desiredX - currentX)*(1)
            var dY = (desiredY - currentY)*(1)
            
            if(dX > 0)
            {
                dX = grav
            }
            else if(dX < 0)
            {
                dX = -1*grav
            }
            else
            {
                dX = 0
            }
            if(dY > 0)
            {
                dY = grav
            }
            else if(dY < 0)
            {
                dY = -1*grav
            }
            else
            {
                dY = 0
            }
            
            gravityArray[i].gravityDirection = CGVector(dx: dX, dy: dY)
            
            timeCount += 1.0
            if(timeInterval*timeCount >= countRatio)
            {
                if(timeInterval*timeCount >= countRatio*Double(gravityArray.count))
                {
                    timeCount = 0.0
                }
                if(true)//recentX != currentX || recentY != currentY)
                {
                    let layer = CAShapeLayer()
                    layer.path = UIBezierPath(roundedRect: CGRect(x: currentX - traceSize/2, y: currentY - traceSize/2, width: traceSize, height: traceSize), cornerRadius: traceSize/2).cgPath
                    layer.fillColor = traceColor
                    layer.zPosition = 0
                    view.layer.addSublayer(layer)
//                    recentX = currentX
//                    recentY = currentY
                    traceArray.append(layer)
                    if(traceArray.count > traceCount)
                    {
                        traceArray[0].removeFromSuperlayer()
                        traceArray.remove(at: 0)
                    }
                }
            }
        }
    }
    
    func worldSetup()
    {
        for i in 0...labelArray.count-1
        {
            var newAnim = UIDynamicAnimator(referenceView: self.view)
            animatorArray.append(newAnim)
            
            let gravityNew = UIGravityBehavior(items: [labelArray[i]])
            animatorArray[i].addBehavior(gravityNew)
            gravityArray.append(gravityNew)
            
            collision = UICollisionBehavior(items: [labelArray[i]])
            collision.translatesReferenceBoundsIntoBoundary = true
            animatorArray[i].addBehavior(collision)
            bounce = UIDynamicItemBehavior(items: [labelArray[i]])
            bounce.elasticity = 0
            animatorArray[i].addBehavior(bounce)
        }
    }
}
extension UIColor
{
    static var random: UIColor
    {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
