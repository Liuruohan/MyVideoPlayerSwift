//
//  ViewController.swift
//  MyVideoPlayerSwift
//
//  Created by 刘恒 on 2017/6/29.
//  Copyright © 2017年 YunRuiJiTuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var avPlayer:LHAVPlayerView?
    private let mainWidth = UIScreen.main.bounds.width
    private let mainHieght = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        NotificationCenter.default.addObserver(self, selector: #selector(fullScreenButtonClick(_:)), name: NSNotification.Name("fullScreenBtnClickNotice"), object: nil)
        
        //avplayer是硬件解码，只支持mp4格式 
        //获取imageData时要异步处理，我就不写了，暂时放在主线程里了
        //使用try的进行处理异常的时候最好用guard判断一下imageData是否为空，我就不写了
        let imageData = try?Data(contentsOf: URL(string: "http://vimg1.ws.126.net/image/snapshot/2017/6/Q/4/VIMJ8VKQ4.jpg")!)
        var image:UIImage? = nil
        if (imageData == nil){
            //图片请求失败
            //可以放置背景图片
        }
        else{
            image = UIImage(data: imageData!, scale: UIScreen.main.scale)!
        }
        avPlayer = LHAVPlayerView.init(frame: CGRect(x: 0, y: (mainHieght-200)/2, width: mainWidth, height: 200), videoURLString: "http://flv2.bn.netease.com/videolib3/1706/22/CFaiZ5779/SD/CFaiZ5779-mobile.mp4",backImage:image!)
        self.view.addSubview(avPlayer!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func fullScreenButtonClick(_ notification:NSNotification) {
        let button = notification.object as! UIButton;
        print(button.isSelected);
        if button.isSelected{
            self.toFullScreen(interfaceOrientation: UIInterfaceOrientation.landscapeLeft)
        }
        else{
            self.toNormal()
        }
    }
    func toFullScreen(interfaceOrientation:UIInterfaceOrientation){
        if interfaceOrientation == UIInterfaceOrientation.landscapeLeft {
            avPlayer!.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))
        }
        else if interfaceOrientation == UIInterfaceOrientation.landscapeRight {
            avPlayer!.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        avPlayer!.frame = UIScreen.main.bounds;
    }
    func toNormal() {
        avPlayer!.transform = CGAffineTransform(rotationAngle: 0);
        avPlayer!.frame = CGRect(x: 0, y: (mainHieght-200)/2, width: 320, height: 200);
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("fullScreenBtnClickNotice"), object: nil)
    }

}

