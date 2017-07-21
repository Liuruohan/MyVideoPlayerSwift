//
//  LHAVPlayerLayer.swift
//  MyVideoPlayerSwift
//
//  Created by 刘恒 on 2017/6/29.
//  Copyright © 2017年 YunRuiJiTuan. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
class LHAVPlayerView: UIView {
    
    private var player:AVPlayer?
    
    private var playerLayer:AVPlayerLayer?
    
    private let durationLabel = UILabel()
    
    private let clickButton = UIButton(type: UIButtonType.custom)
    
    private let progressSlider = UISlider()
    
    private var totalSecond:Float64 = 0.0
    
    private var timeObserve:Any?
    
    private let buttomView = UIView()
    
    private let backimageView = UIImageView()
    
    private var isBeginPlayButtonClick = false
    
    private let backView = UIView()
    
    init(frame: CGRect,videoURLString:String,backImage:UIImage) {
        //如果URL不能解析，不初始化对象
        guard let videoURL = URL.init(string: videoURLString)  else {
            super.init(frame: frame)
            print("链接无效");
            //可以写一些链接无效的layer
            return
        }
        super.init(frame: frame) //调用super后self才算被真正初始化
        
        let playerItem = AVPlayerItem.init(url: videoURL) // item主要为控制播放速度的，及获取当前播放时间和跳转到指定时间
        player = AVPlayer.init(playerItem: playerItem)//player主要控制视频的播放，暂停，继续播放。
        playerLayer = AVPlayerLayer.init(player: player)//layer主要是展示视频的图像
        playerLayer!.frame = frame
        //AVLayerVideoGravityResizeAspect       按照宽高等比例缩小
        //AVLayerVideoGravityResizeAspectFill   按照宽高等比例放大
        //AVLayerVideoGravityResize     充满屏幕，不保持宽高比，造成视频变形
        playerLayer!.videoGravity = AVLayerVideoGravityResize
        
        self.layer.addSublayer(self.playerLayer!)
        self.initSubViews()   //在playerLayer上添加进度条等
        //初始化背景图片
        
        backimageView.image = backImage
        backimageView.isUserInteractionEnabled = true
        self.addSubview(backimageView)
        backimageView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        let beginPlayButton = UIButton.init(type: UIButtonType.custom)
        beginPlayButton.tag = 1;
        beginPlayButton.setImage(UIImage(named:"largePlayButton"), for: UIControlState.normal)
        beginPlayButton.addTarget(self, action: #selector(beginPlayButtonClick), for: UIControlEvents.touchUpInside)
        backimageView.addSubview(beginPlayButton)
        beginPlayButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(64)
            make.center.equalTo(backimageView)
        }
        
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(videoHasFinished(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer!.frame = self.bounds
        backView.frame = self.bounds
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //设置下面进度条等界面
    private func initSubViews(){
        
        backView.frame = self.frame
        backView.backgroundColor = UIColor.clear
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backViewClick(_:)))
        backView.addGestureRecognizer(gesture)
        self.addSubview(backView)
        
        let fullScreenbutton = UIButton(type: UIButtonType.custom)
        fullScreenbutton.setImage(UIImage(named: "fullscreen"), for: UIControlState.normal)
        fullScreenbutton.setImage(UIImage(named: "nonfullscreen"), for: UIControlState.selected)
        fullScreenbutton.addTarget(self, action: #selector(videoFullScreen(_:)), for: UIControlEvents.touchUpInside)
        backView.addSubview(fullScreenbutton)
        fullScreenbutton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(backView).offset(5)
            make.right.equalTo(backView).offset(-10)
            make.width.height.equalTo(15)
        }

        buttomView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        buttomView.isHidden = true
        backView.addSubview(buttomView)
        buttomView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(backView).offset(0)
            make.bottom.equalTo(backView).offset(0)
            make.height.equalTo(30)
            make.right.equalTo(backView).offset(0)
        }
        
        self.durationLabel.backgroundColor = UIColor.clear
        self.durationLabel.textColor = UIColor.white
        self.durationLabel.font = UIFont.systemFont(ofSize: 11)
        buttomView.addSubview(self.durationLabel)
        
        self.durationLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(buttomView).offset(0)
            make.right.equalTo(buttomView).offset(-10)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        self.clickButton.setImage(UIImage(named: "stopButton"), for: UIControlState.normal)
        self.clickButton.setImage(UIImage(named: "playButton"), for: UIControlState.selected)
        self.clickButton.isSelected = true
        self.clickButton.addTarget(self, action: #selector(playButtonClick(_:)), for: UIControlEvents.touchUpInside)
        buttomView.addSubview(self.clickButton)
        self.clickButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(buttomView).offset(0)
            make.left.equalTo(buttomView).offset(0)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        self.progressSlider.setThumbImage(UIImage(named:"dotImage"), for: UIControlState.normal)
        self.progressSlider.minimumTrackTintColor = UIColor.blue
        self.progressSlider.addTarget(self, action: #selector(playProgressToSeek(_:)), for: UIControlEvents.touchUpInside)
        buttomView.addSubview(self.progressSlider);
        self.progressSlider.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(buttomView).offset(0)
            make.left.equalTo(buttomView).offset(35)
            make.right.equalTo(buttomView).offset(-65)
            make.height.equalTo(30)
        }
    }
    //私有方法，外部不能调用
    //dynamic 修饰的方法为动态方法，和@objc修饰类似
    //@objc修饰符并不意味着这个方法或者属性会变成动态派发，Swift依然可能会将其优化为静态调用;但是在施展一些像动态替换方法或者运行时再决定实现这样的 "黑魔法" 的时候，我们就需要用到dynamic修饰符了
    
    @objc private func beginPlayButtonClick(){
        self.isBeginPlayButtonClick = true
        if self.player!.currentItem!.status.rawValue == AVPlayerStatus.readyToPlay.rawValue{
            self.backimageView.removeFromSuperview()
            self.player!.play()
        }else{
            //可以加个旋转的等待图
        }
    }
    //点击屏幕显示底部按钮和进度
    @objc private func backViewClick(_ tapGestrure:UITapGestureRecognizer){
        if buttomView.isHidden{
            buttomView.isHidden = false
            unowned let uself = self
            DispatchQueue.main.asyncAfter(deadline: .now()+7) {
                uself.buttomView.isHidden = true
            };
        }
    }
    //控制播放器的播放和停止
    @objc private func playButtonClick(_ button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected{
            player!.play()
        }
        else{
            player!.pause()
        }
    }
    //进度条播放进度
    @objc private func playProgressToSeek(_ slider:UISlider){
        self.player!.currentItem?.seek(to: CMTimeMakeWithSeconds(Float64(slider.value), 1))
    }
    //视频播放结束
    @objc private func videoHasFinished(_ notification:NSNotification){
        let button = backimageView.viewWithTag(1) as! UIButton
        button.isSelected = false
        NotificationCenter.default.post(name: NSNotification.Name("fullScreenBtnClickNotice"), object: button)
        
        self.addSubview(backimageView)
        backimageView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        unowned let uself = self
        self.player!.seek(to: kCMTimeZero) { (finish) in
            uself.progressSlider.value = 0.0
        }
    }
    
    @objc private func videoFullScreen(_ button:UIButton){
        button.isSelected = !button.isSelected
        NotificationCenter.default.post(name: NSNotification.Name("fullScreenBtnClickNotice"), object: button)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath=="status" {
            let status = Int(String(describing: change![NSKeyValueChangeKey.newKey]!))
            switch status!{
            case AVPlayerStatus.unknown.rawValue:
                break;
            case AVPlayerStatus.readyToPlay.rawValue:
                if isBeginPlayButtonClick{
                    self.backimageView.removeFromSuperview()
                    self.player!.play()
                }
                let duration = self.player!.currentItem!.duration
                self.totalSecond = CMTimeGetSeconds(duration)
                self.progressSlider.maximumValue = Float(totalSecond) //将进度条的最大值设为总时间
                self.showDurationInLabel(secondTotal: 0.0)
                unowned let uself = self   //对self进行无主引用（无主引用是在初始化后不能被赋值为nil的实例；弱引用是在初始化后能被赋值为nil的实例）
                timeObserve =  self.player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main, using: { (time:CMTime) in
                    let currentSecond = CMTimeGetSeconds(time)
                    uself.showDurationInLabel(secondTotal: currentSecond)
                    uself.progressSlider.value = Float(currentSecond)
                })
                break;
            case AVPlayerStatus.failed.rawValue:
                break;
            default:
                break;
            }
        }
    }
    private func showDurationInLabel(secondTotal:Float64){
        let leftSecond = totalSecond - secondTotal
        let hour = Int(leftSecond/60/60)
        let minute = Int(leftSecond/60)-hour*60
        let second = Int(leftSecond) - hour*60*60-minute*60
        self.durationLabel.text = String.localizedStringWithFormat("%.2d:%.2d:%.2d", hour,minute,second);
    }
    
    deinit{
        self.player!.removeTimeObserver(timeObserve!)  //记得将observer进行remove
        self.player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}









