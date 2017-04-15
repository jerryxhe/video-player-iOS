//
//  ViewController.swift
//
//  Created by Jerry He on 2/25/16.
//  Copyright © 2016 Jerry He. All rights reserved.
//

// Note that this is Swift2 syntax, works in Xcode 7 but will not work on Xcode 8

import UIKit
import MediaPlayer

func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
    let c = list.count
    if c < 2 { return list }
    for i in 0..<(c - 1) {
        let j = Int(arc4random_uniform(UInt32(c - i))) + i
        if(i != j) {
          swap(&list[i], &list[j])
        }
    }
    return list
}

class ViewController: UIViewController {
   var moviePlayer:MPMoviePlayerController!
   var ii=0;
   let vidCollection: [String] = [
    ]
    
   let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
    @IBOutlet weak var arrowLeft: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let url = NSURL(string: "")!
        let localUrl = self.documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        moviePlayer = MPMoviePlayerController(contentURL: localUrl)
        //moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        moviePlayer.view.frame = CGRect(x: 20, y: 100, width: 400, height: 200)
        
        self.view.addSubview(moviePlayer.view)
        moviePlayer.fullscreen = true
        
        moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        
        NSNotificationCenter.defaultCenter().addObserverForName(MPMoviePlayerPlaybackDidFinishNotification,object: nil, queue: nil) { note in
            let nvid = self.vidCollection.count
            self.moviePlayer.pause()
            self.ii += 1
            self.ii = abs(self.ii % nvid)
            let currentURL = NSURL(string: self.vidCollection[self.ii])!
            let localUrl = self.documentsUrl.URLByAppendingPathComponent(currentURL.lastPathComponent!)
            let checkValidation = NSFileManager.defaultManager()
            let localUrlStr = "\(localUrl)"
            print("looking for local File",localUrlStr)
            if (checkValidation.fileExistsAtPath(localUrl!.path!)) {
                self.moviePlayer.contentURL = localUrl
                print("found local file "+localUrl!.path!)
            }
            else {
                self.moviePlayer.contentURL = currentURL
                self.downloadFile(currentURL)
            }
            self.moviePlayer.play()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func arrowRight(sender: UIButton) {
        let nvid = vidCollection.count
        moviePlayer.pause()
        ii=ii+1
        ii = abs(ii % nvid)
        let currentURL = NSURL(string: vidCollection[ii])!
        let localUrl = self.documentsUrl.URLByAppendingPathComponent(currentURL.lastPathComponent!)
        let checkValidation = NSFileManager.defaultManager()
        let localUrlStr = "\(localUrl)"
        print("looking for local File",localUrlStr)
        if (checkValidation.fileExistsAtPath(localUrl!.path!)) {
            moviePlayer.contentURL = localUrl
            print("found local file "+localUrl!.path!)
        }
        else {
            moviePlayer.contentURL = currentURL
            downloadFile(currentURL)
        }
        moviePlayer.play()
    }
    
    @IBAction func arrowLeft(sender: UIButton) {
        let nvid = vidCollection.count
        moviePlayer.pause()
        ii=ii-1
        ii = abs(ii % nvid)
        let currentURL = NSURL(string: vidCollection[ii])!
        let localUrl = self.documentsUrl.URLByAppendingPathComponent(currentURL.lastPathComponent!)
        let checkValidation = NSFileManager.defaultManager()
        if (checkValidation.fileExistsAtPath(localUrl!.path!)) {
            moviePlayer.contentURL = localUrl
            print("found local file "+localUrl!.path!)
        }
        else {
            moviePlayer.contentURL = currentURL
            downloadFile(currentURL)
        }
        moviePlayer.play()
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadFile(url: NSURL){
        print("Started downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                let destinationUrl = self.documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
                data.writeToURL(destinationUrl!, atomically: true);
                print("Finished downloading \"\(destinationUrl)\".")
            }
        }
    }

}


