//
//  AccountInfo.swift
//  Angelica Fighti
//
//  Created by Pablo  on 4/3/22.
//  Copyright © 2022 P.Cebrian. All rights reserved.
//

import Foundation
import SpriteKit

class AccountInfo{
    
    deinit{
        print("AccountInfo Deinitiated")
    }
    
    private struct Data{
        let fullPath:String
        let plist:NSMutableDictionary
        
        init(){
        
            guard let path = Bundle.main.path(forResource: "userinfo", ofType: "plist") else {
                fatalError("plist is nil - Check AccountInfo.swift")
            }
    
            fullPath = path
            
            guard let plist = NSMutableDictionary(contentsOfFile: fullPath) else {
                fatalError("plist is nil - Check AccountInfo.swift")
            }
            
            self.plist = plist
        }
    }
    
    private var level:Int
    private var currentToonIndex:Int
    private var characters:[Toon]
    private var gold:Int
    private var experience:CGFloat
    private var highscore:Int
    private let data:Data
    
    init(){
        //inventory = Bag()
        level = 0
        currentToonIndex = 0
        gold = 0
        experience = 0.0
        characters = [Toon(char: .Alpha), Toon(char: .Beta), Toon(char: .Celta), Toon(char: .Delta),Toon(char: .Jade),Toon(char: .Arcana),Toon(char: .Alice)]
      //  characters =  Toon.Character.allCases.map { Toon(char: $0)}
        highscore = 0
        data = Data()
        
    }
    
    func load() -> Bool{

        // Update Root
            level = data.plist.value(forKey: "Level") as! Int
            gold = data.plist.value(forKey: "Coin") as! Int
            experience = data.plist.value(forKey: "Experience") as! CGFloat
            highscore = data.plist.value(forKey: "Highscore") as! Int
            currentToonIndex = data.plist.value(forKey: "CurrentToon") as! Int
        
        
        
        let toondDict = data.plist.value(forKey: "Toons") as! NSDictionary
        
            characters[0].load(infoDict: toondDict.value(forKey: "Alpha") as! NSDictionary)
            characters[1].load(infoDict: toondDict.value(forKey: "Beta") as! NSDictionary)
            characters[2].load(infoDict: toondDict.value(forKey: "Celta") as! NSDictionary)
            characters[3].load(infoDict: toondDict.value(forKey: "Delta") as! NSDictionary)
            characters[4].load(infoDict: toondDict.value(forKey: "Jade") as! NSDictionary)
            characters[5].load(infoDict: toondDict.value(forKey: "Arcana") as! NSDictionary)
            characters[6].load(infoDict: toondDict.value(forKey: "Alice") as! NSDictionary)
        
        return true
    }
    
     func getGoldBalance() -> Int{
        return self.gold
    }
    
     func getCurrentToon() -> Toon{
        return characters[currentToonIndex]
    }
    
     func getCurrentToonIndex() -> Int{
        return currentToonIndex
    }
    
     func selectToonIndex(index: Int){
            currentToonIndex = index
            data.plist.setValue(index, forKey: "CurrentToon")
        
        if !data.plist.write(toFile: data.fullPath, atomically: false){
            print("Saving Error - AccountInfo.selectToonIndex")
        }
    }
    
     func upgradeBullet() -> (Bool, String){
        let level = characters[currentToonIndex].getBulletLevel()
        let cost = (level + 1) * 100
         

        if gold < cost {
            return (false, "Not enough gold balance: \(getGoldBalance())")
        }
        
        gold -= cost
        data.plist.setValue(gold, forKey: "Coin")
        
        if !data.plist.write(toFile: data.fullPath, atomically: false){
            return (false, "Saving error: AccountInfo.upgradeBullet[1]")
        }
        
        let toonDict = data.plist.value(forKey: "Toons") as! NSDictionary
        guard let currToonDict = toonDict.value(forKey: characters[currentToonIndex].getCharacter().string) as? NSMutableDictionary else{
            return (false, "Error: AccountInfo.upgradeBullet[2]")
        }
        
        if !characters[currentToonIndex].advanceBulletLevel(){
            return (false, "Max Level Achieved")
        }
        
        currToonDict.setValue(characters[currentToonIndex].getBulletLevel(), forKey: "BulletLevel")
        
        if !data.plist.write(toFile: data.fullPath, atomically: false){
            return (false, "Saving Error")
        }
        
        
        return (true, "Success")
    }
    
    // Update settings userinfo.plist
    func updateSettings(key:String) ->(Bool,String){
        
        guard let toondDict = data.plist.value(forKey: "Settings") as? NSMutableDictionary,
              let value = toondDict.value(forKey: key) as? Bool else {
            return (false,"Saving Error Guard")
        }
        
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fullPath = rootPath.appending("/userinfo.plist")

        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: fullPath) {
            return (false,"File userinfo.plist not found")
        }
        
        toondDict.setValue(!value, forKey: key)
      
        if !data.plist.write(toFile: fullPath, atomically: true) {
            return (false,"Saving Error")
        }
        return (true, "Success")
        
    }
    
    /// Get key value settings inside userinfo.plist    
    func getValueKeyUserInfo(key:String) -> Bool {
        
        guard let toondDict = data.plist.value(forKey: "Settings") as? NSMutableDictionary,
              let value = toondDict.value(forKey: key) as? Bool else {
            return false
        }
       
        return value
    }
    
    func upgradeLevel() -> Int {
        level += 1
        return level
    }
    func getLevel() -> Int {
        return level
    }
    
     func getToonDescriptionByIndex(index: Int) -> [String]{
        return characters[index].getToonDescription()
    }
     func getNameOfToonByIndex(index: Int) -> String{
        return characters[index].getToonName()
    }
     func getTitleOfToonByIndex(index: Int) -> String{
        return characters[index].getToonTitle()
    }
     func getBulletLevelOfToonByIndex(index: Int) -> Int{
        return characters[index].getBulletLevel()
    }
     func prepareToChangeScene(){
        characters.removeAll()
    }
    
}
