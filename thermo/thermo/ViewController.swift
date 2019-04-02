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
    
    var grav = CGFloat(1.0)
    
    var recentX = CGFloat(0)
    var recentY = CGFloat(0)

    var swimmerCount = 10
    
    var traceArray = [CAShapeLayer]()
    var traceCount = 1000
    var traceSize = CGFloat(4)
    var traceColor = UIColor.red.cgColor
    
    var timeInterval    = 0.0//00001
    var timeCount = Double(0)
    var countRatio      = 0.00001
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        circleRadius = screenSize.width/8
        
        ogX = screenSize.width/2
        ogY = screenSize.height*1/4
    
//        for i in 0...swimmerCount-1
//        {
//            makeSwimmer(myXPos: CGFloat(arc4random_uniform(UInt32(screenSize.width))), myYPos: CGFloat(arc4random_uniform(UInt32(screenSize.height))), myName: String(i), size: Int(circleRadius/4))//Int(arc4random_uniform(UInt32(circleRadius))))
////            makeSwimmer(myXPos: ogX, myYPos: ogY, myName: String(i), size: Int(circleRadius/2))
//        }
        makeSwimmer(myXPos: ogX, myYPos: ogY, myName: String("t"), size: Int(circleRadius/2))
        makeSwimmer(myXPos: ogX, myYPos: screenSize.height - ogY, myName: String("t"), size: Int(circleRadius/2))
        
        
        worldSetup()
        
        let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateGravity), userInfo: nil, repeats: true)
    }
    func makeSwimmer(myXPos: CGFloat, myYPos: CGFloat, myName: String, size: Int)
    {
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: size, height: size))
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
        var desiredX = CGFloat(0)
        var desiredY = CGFloat(0)
        
        var massX = CGFloat(0)
        var massY = CGFloat(0)
        var density = CGFloat(10)
        
        for i in 0...labelArray.count-1
        {
            desiredX += labelArray[i].center.x*4/3*CGFloat.pi*pow(labelArray[i].frame.width*density, 3)
            desiredY += labelArray[i].center.y*4/3*CGFloat.pi*pow(labelArray[i].frame.height*density, 3)
            massX += 4/3*CGFloat.pi*pow(labelArray[i].frame.width*density, 3)
            massY += 4/3*CGFloat.pi*pow(labelArray[i].frame.height*density, 3)
        }
        
        desiredX = desiredX/massX //CGFloat(labelArray.count)
        desiredY = desiredY/massY //CGFloat(labelArray.count)
        
        for i in 0...labelArray.count-1
        {
            var currentX = labelArray[i].center.x
            var currentY = labelArray[i].center.y
            
            var dX = (desiredX - currentX)
            var dY = (desiredY - currentY)
            
            if(dX.magnitude > dY.magnitude)
            {
                dY = dY / dX.magnitude
                dX = dX / dX.magnitude
            }
            else
            {
                dX = dX / dY.magnitude
                dY = dY / dY.magnitude
            }
            dX *= grav
            dY *= grav
            dX = round(dX)
            dY = round(dY)
//            dX *= pow(labelArray[i].frame.width/circleRadius, 3)
//            dY *= pow(labelArray[i].frame.height/circleRadius, 3)
            
            gravityArray[i].gravityDirection = CGVector(dx: dX, dy: dY)
            
            // Draw trails
            timeCount += 1.0
            if(Int(timeCount) >= traceCount/labelArray.count)
            {
                if(Int(timeCount) >= traceCount)
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
            gravityNew.gravityDirection = CGVector(dx: 0.0, dy: 0.0)
            gravityArray.append(gravityNew)
            
            collision = UICollisionBehavior(items: [labelArray[i]])
            collision.translatesReferenceBoundsIntoBoundary = true
            animatorArray[i].addBehavior(collision)
            bounce = UIDynamicItemBehavior(items: [labelArray[i]])
            bounce.elasticity = 1.0
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
