//
//  ViewController.swift
//  lab01
//
//  Created by Użytkownik Gość on 12.10.2016.
//  Copyright © 2016 Użytkownik Gość. All rights reserved.
//
import Foundation;
import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    var songs : [Song] = []
    var currentIndex : Int = 0;
    var item : NSDictionary?;
    
    @IBOutlet weak var artisTxtField: UITextField!
    @IBOutlet weak var titleTxtField: UITextField!
    @IBOutlet weak var genreTxtField: UITextField!
    @IBOutlet weak var yearTxtField: UITextField!
    
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var pager: UILabel!
    
    // MARK: Properties

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.maximumValue = 5
        saveButton.enabled = false;
        
        artisTxtField.delegate = self;
        titleTxtField.delegate = self;
        genreTxtField.delegate = self;
        yearTxtField.delegate = self;
        
        
        let plistPath = NSBundle.mainBundle().pathForResource("songs", ofType: "plist")
        let list:NSArray = NSArray(contentsOfFile: plistPath!)!
        
        for song:NSDictionary in (list as NSArray as! [NSDictionary]) {
            let newSong = Song(
                title: song.valueForKey("title") as! String,
                artist: song.valueForKey("artist") as! String,
                genre: song.valueForKey("genre") as! String,
                year: song.valueForKey("date") as! Int,
                rating: song.valueForKey("rating") as! Int
            )
            
            songs.append(newSong!)
        }
        
        if (songs.first != nil) {
            setItemData(songs.first!)
        }
        
        prevButton.enabled = false;
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = true;
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setItemData(song : Song) {
        artisTxtField.text = song.artist
        titleTxtField.text = song.title
        genreTxtField.text = song.genre
        yearTxtField.text = String(song.year)
        rateLabel.text = String(song.rating);
        stepper.value = Double(rateLabel.text!)!;
        updatePager();
    }
    
    func clearDisplayingData(){
        artisTxtField.text = "";
        titleTxtField.text = "";
        genreTxtField.text = "";
        yearTxtField.text = "";
        rateLabel.text = "0";
        stepper.value = Double(rateLabel.text!)!;
    }
    
    
    @IBAction func changeStepperValue(sender: UIStepper) {
        rateLabel.text = String(Int(sender.value));
        saveButton.enabled = true;
    }
    
    
    @IBAction func prev(sender: UIButton) {
        if(currentIndex > 0){
            currentIndex -= 1;
        }
        
        if(currentIndex == 0){
            prevButton.enabled = false;
        }
        
        saveButton.enabled = false;
        nextButton.enabled = true
        deleteButton.enabled = true
        newButton.enabled = true
        
        setItemData(songs[currentIndex]);
    }

    @IBAction func next(sender: UIButton) {
        
        if(currentIndex < songs.count){
            currentIndex += 1;
        }
        
        if(currentIndex == songs.count){
            clearDisplayingData();
            nextButton.enabled = false;
            deleteButton.enabled = false;
            newButton.enabled = false;
            updatePager();
            return;
        }
        
        saveButton.enabled = false;
        
        setItemData(songs[currentIndex])
        updatePager()
    }
    
    
    func updatePager(){
        if currentIndex < songs.count {
            pager.text = "Record \(currentIndex+1) of \(songs.count)"
        }else {
            pager.text = "New Record"
        }
        
        
        if(currentIndex > 0) {
            prevButton.enabled = true
        }
        if(songs.count == 0) {
            deleteButton.enabled = false
        }
    }

    @IBAction func save(sender: UIButton) {
        let newSong = Song(
            title: titleTxtField.text! ?? "",
            artist: artisTxtField.text! ?? "",
            genre: genreTxtField.text! ?? "",
            year: Int(yearTxtField.text!)! ?? 0,
            rating: Int(ratingLabel.text!)! ?? 0
        )
        
        if currentIndex == songs.count {
            songs.append(newSong!)
        } else {
            songs[currentIndex] = newSong!
        }
        updatePager()
        saveButton.enabled = false;
        deleteButton.enabled = true;
        newButton.enabled = true;
        
        saveSongs()
    }
    
    
    @IBAction func remove(sender: AnyObject) {
        if currentIndex < songs.count {
            songs.removeAtIndex(currentIndex)
            currentIndex = currentIndex > 0 ? currentIndex-1 : 0
        }
        clearDisplayingData();
        if songs.count > 1 {
            setItemData(songs[currentIndex])
            
        }
        updatePager()
    }
    
    
    @IBAction func new(sender: AnyObject) {
        currentIndex = songs.count
        clearDisplayingData()
        deleteButton.enabled = false
        newButton.enabled = false
        nextButton.enabled = false;
        updatePager()
    }
    
    func saveSongs() {
        print("Save songs")
        let plistPath = NSBundle.mainBundle().pathForResource("songs", ofType: "plist")!
        print(plistPath)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let albumsDocPath = documentsPath.stringByAppendingString("/songs.plist")
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(albumsDocPath) {
            print("copy")
            try? fileManager.copyItemAtPath(plistPath, toPath: albumsDocPath)
        }
        
        let albums = Song.convertToNSMutableArray(songs)
        print(albumsDocPath)
        
        albums.writeToFile(plistPath, atomically: true)
    }
}

