//
//  CCViewController.m
//  VideoEditDemo
//
//  Created by mr.cao on 14-6-13.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//  CMTimeMake和CMTimeMakeWithSeconds 详解
/*CMTimeMake(a,b)    a当前第几帧, b每秒钟多少帧.当前播放时间a/b
 
 CMTimeMakeWithSeconds(a,b)    a当前时间,b每秒钟多少帧.
 
 CMTimeMake
 
 CMTime CMTimeMake (
 int64_t value,
 int32_t timescale
 );
 CMTimeMake顧名思義就是用來建立CMTime用的,
 但是千萬別誤會他是拿來用在一般時間用的,
 CMTime可是專門用來表示影片時間用的類別,
 他的用法為: CMTimeMake(time, timeScale)
 
 time指的就是時間(不是秒),
 而時間要換算成秒就要看第二個參數timeScale了.
 timeScale指的是1秒需要由幾個frame構成(可以視為fps),
 因此真正要表達的時間就會是 time / timeScale 才會是秒.
 
 簡單的舉個例子
 
 CMTimeMake(60, 30);
 CMTimeMake(30, 15);
 在這兩個例子中所表達在影片中的時間都皆為2秒鐘,
 但是影隔播放速率則不同, 相差了有兩倍.*/


#import "CCViewController.h"
#import "CommonHelper.h"
@implementation CCViewController

- (void)viewDidUnload
{
    [self setJsVideoScrubber:nil];
    
    
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeAllFiles];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    originViedoWidth=0;
    originViedoHeight=0;
    originDuration=0;
    originViedoFPS=0;

    self.view.backgroundColor=[UIColor darkGrayColor];
    self.jsVideoScrubber=[[JSVideoScrubber alloc]initWithFrame:CGRectMake(0, 44,ViewWidth,50)];
    [self.view addSubview:self.jsVideoScrubber];
    self.duration=[[UILabel alloc]initWithFrame:CGRectMake(ViewWidth-32, self.jsVideoScrubber.frame.origin.y+self.jsVideoScrubber.frame.size.height, 30, 20)];
    self.duration.textAlignment=NSTextAlignmentRight;
    self.duration.font=[UIFont fontWithName:@"Helvetica-bold" size:10];
    //self.duration.backgroundColor=[UIColor greenColor];
    self.duration.textColor=[UIColor blueColor];
    self.duration.text = [NSString stringWithFormat:@"%02d:%02d", 0, 0];
    [self.view addSubview:self.duration];
    
    
    self.offset=[[UILabel alloc]initWithFrame:CGRectMake(0, self.jsVideoScrubber.frame.origin.y+self.jsVideoScrubber.frame.size.height, 30, 20)];
    self.offset.textAlignment=NSTextAlignmentLeft;
    self.offset.font=[UIFont fontWithName:@"Helvetica-bold" size:10];
   // self.offset.backgroundColor=[UIColor greenColor];
    self.offset.textColor=[UIColor blueColor];
    self.offset.text= [NSString stringWithFormat:@"%02d:%02d", 0, 0];
    [self.view addSubview:self.offset];
    
    
    
    self.endoffset=[[UILabel alloc]initWithFrame:CGRectMake(ViewHeight-32, self.jsVideoScrubber.frame.origin.y+self.jsVideoScrubber.frame.size.height, 30, 20)];
    self.endoffset.textAlignment=NSTextAlignmentLeft;
    self.endoffset.font=[UIFont fontWithName:@"Helvetica-bold" size:10];
    // self.offset.backgroundColor=[UIColor greenColor];
    self.endoffset.textColor=[UIColor blueColor];
    self.endoffset.text= [NSString stringWithFormat:@"%02d:%02d", 0, 0];
    [self.view addSubview:self.offset];

    
    
    _viedoEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _viedoEditButton.frame=CGRectMake(ViewWidth/2-256*0.2, [UIScreen mainScreen].bounds.size.height/2-100, 256*0.4, 256*0.4);
    //_viedoEditButton.backgroundColor=[UIColor grayColor];
    //[_viedoEditButton setImage:[UIImage imageNamed:@"play.png"]  forState:UIControlStateNormal];
    [_viedoEditButton addTarget:self action:@selector(testCompressionSession) forControlEvents:UIControlEventTouchUpInside];
    _viedoEditButton.layer.cornerRadius=5;
    _viedoEditButton.layer.borderWidth=5;
    [_viedoEditButton setTitle:@"开始剪辑" forState:UIControlStateNormal];
    _viedoEditButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    
    [self.view addSubview:_viedoEditButton];
    
    
    
    
    _viedoaddMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _viedoaddMusicButton.frame=CGRectMake(ViewWidth/2-256*0.2, [UIScreen mainScreen].bounds.size.height/2+20, 256*0.4, 256*0.4);
   // _viedoaddMusicButton.backgroundColor=[UIColor grayColor];
    //[_viedoEditButton setImage:[UIImage imageNamed:@"play.png"]  forState:UIControlStateNormal];
    [_viedoaddMusicButton addTarget:self action:@selector(addMusicToViedo:) forControlEvents:UIControlEventTouchUpInside];
      _viedoaddMusicButton.layer.cornerRadius=5;
    _viedoaddMusicButton.layer.borderWidth=5;
    [_viedoaddMusicButton setTitle:@"添加背景音乐" forState:UIControlStateNormal];
    _viedoaddMusicButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    
    [self.view addSubview:_viedoaddMusicButton];

    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //创建一个UIActivityIndicatorView对象：_activityIndicatorView，并初始化风格。
    _activityIndicatorView.frame = CGRectMake(ViewWidth/2, ViewHeight/2,0, 0);
    _activityIndicatorView.color = [UIColor redColor];

    //_activityIndicatorView.hidesWhenStopped = NO;

    [self.view addSubview:_activityIndicatorView];

    

    
    AVURLAsset* asset = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Green" ofType:@"mov"];
    NSURL* url = [NSURL fileURLWithPath:filePath];
    asset = [AVURLAsset URLAssetWithURL:url options:nil];
    __weak CCViewController *ref = self;

    
    NSArray *keys = [NSArray arrayWithObjects:@"tracks", @"duration", nil];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^(void) {
        
        [ref.jsVideoScrubber setupControlWithAVAsset:asset];
        
        double total = CMTimeGetSeconds(ref.jsVideoScrubber.duration);
        
        int min = (int)total / 60;
        int seconds = (int)total % 60;
        ref.duration.text = [NSString stringWithFormat:@"%02d:%02d", min, seconds];
        
        [ref updateOffsetLabel:self.jsVideoScrubber];
        [ref.jsVideoScrubber addTarget:self action:@selector(updateOffsetLabel:) forControlEvents:UIControlEventValueChanged];
       // ref.currentSelection = indexPath;
    }];

    [self extractFrames];
    
    
    
    
}
- (void) updateOffsetLabel:(JSVideoScrubber *) scrubber
{
    NSLog(@"%f",self.jsVideoScrubber.offset);
    int min = (int)self.jsVideoScrubber.offset / 60;
    int seconds = (int)self.jsVideoScrubber.offset % 60;
    CGFloat offsetx=(self.jsVideoScrubber.offset-2)/CMTimeGetSeconds(self.jsVideoScrubber.duration)*ViewWidth;
    self.offset.text = [NSString stringWithFormat:@"%02d:%02d", min, seconds];
    self.offset.frame=CGRectMake(offsetx, 94, 30, 20);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
-(IBAction)addMusicToViedo:(id)sender
{
    _activityIndicatorView.hidesWhenStopped = NO;
    [_activityIndicatorView startAnimating];
    [self CompileFilesToMakeMovie:nil withMovie:nil withAudio:nil];
}
- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    /*CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
     CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
     CGImageGetHeight(image)), image);
     CGColorSpaceRelease(rgbColorSpace);*/
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}
- (IBAction)testCompressionSession
{
    _activityIndicatorView.hidesWhenStopped = NO;
    [_activityIndicatorView startAnimating];
    
    //self.hud=[[CommonHelper sharedInstance]showHud:self title:@"视频剪辑中..."  selector:@selector(reloadMainUIInThread) arg:nil targetView:self.view];


    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    docDir= [NSString stringWithFormat:@"%@/%@%@",docDir,@"video",@".mp4"];
    //CGSize size = CGSizeMake(640,480);//定义视频的大小
    CGSize size=CGSizeMake(originViedoWidth, originViedoHeight);
    
    
    [self writeMovieAtPath:docDir withSize:size inDuration:originDuration byFPS:originViedoFPS withStartTime:10 withEndTime:30];
}
//根据起止时间合成视频
- (void) writeMovieAtPath:(NSString *) path withSize:(CGSize) size
               inDuration:(float)duration byFPS:(int32_t)fps withStartTime:(NSTimeInterval)starttime  withEndTime:(NSTimeInterval)endtime
{
    
    //int __block  frameCount = 0;
    
    
    NSError *error = nil;
    
    //—-initialize compression engine 视频格式支持类型：AVFileTypeQuickTimeMovie , AVFileTypeMPEG4，AVFileTypeAMR
    AVAssetWriter  __block  *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                                     fileType:AVFileTypeQuickTimeMovie
                                                                        error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error = %@", [error localizedDescription]);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
        NSLog(@"");
    else
        NSLog(@"");
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
    int __block frame = 0;
    int start=0;
    start=[_imageArry count]/duration *starttime;
    int end=[_imageArry count];
    end=[_imageArry count]/duration *endtime;
    NSMutableArray *newArray=[[NSMutableArray alloc]initWithCapacity:2];
    for(int i=start;i<end;i++)
    {
        [newArray addObject:[_imageArry objectAtIndex:i]];
    }
    //int imagesCount = [_imageArry count];
    //float averageTime = duration/imagesCount;
    
    //int averageFrame = (int)(averageTime * fps);
    //NSLog(@"newcount:%d",newArray.count);
    __weak CCViewController *ref=self;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while ([writerInput isReadyForMoreMediaData])
        {
            if(++frame >= [newArray count])
            {
                [writerInput markAsFinished];
                //[videoWriter finishWriting];
                [videoWriter finishWritingWithCompletionHandler:^{
                    videoWriter=nil;
                    
                    [ref.activityIndicatorView stopAnimating];
                    ref.activityIndicatorView.hidesWhenStopped = YES;
                    /*UIAlertView *recorderSuccessful = [[UIAlertView alloc] initWithTitle:@"" message:@"视频录制成功"
                                                                                delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [recorderSuccessful show];*/
                    
                    
                }];
                break;
            }
            
            CVPixelBufferRef buffer = NULL;
            
            int idx = frame;
            if(idx<[newArray count])
            {
                buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[newArray objectAtIndex:idx] CGImage] size:size];
                
                if (buffer)
                {
                    //CMTime frameTime = CMTimeMake(frameCount,(int32_t) fps);
                    //float frameSeconds = CMTimeGetSeconds(frameTime);
                   // NSLog(@"frameCount:%d,kRecordingFPS:%d,frameSeconds:%f,%d",frameCount,fps,frameSeconds,frame);
                    // if(![adaptor appendPixelBuffer:buffer withPresentationTime:frameTime])
                    if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame*fps, [_imageArry count]/duration*fps)])
                        NSLog(@"FAIL");
                    else
                        NSLog(@"sucess");
                }
                CFRelease(buffer);
            }
            else
            {
                break;
            }
            //frameCount = frameCount + averageFrame;
            
        }
    }];
    
    
    
    
}
- (void)extractFrames
{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Green" ofType:@"mov"];
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    
    //setting up generator & compositor
    self.generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    //    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    self.generator.requestedTimeToleranceBefore = kCMTimeZero;
    self.generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    _generator.appliesPreferredTrackTransform = YES;
    self.composition = [AVVideoComposition videoCompositionWithPropertiesOfAsset:asset];
    
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    NSTimeInterval frameDuration = CMTimeGetSeconds(_composition.frameDuration);
    CGFloat totalFrames = round(duration/frameDuration);
    
    //[lblFrames setText:[NSString stringWithFormat:@"%.2f Frames",totalFrames]];
    //[lblVideoLength setText:[NSString stringWithFormat:@"Video Duration : %f",duration]];
    
    NSMutableArray * times = [[NSMutableArray alloc] init];
    _imageArry=[[NSMutableArray alloc]initWithCapacity:2];
    NSLog(@"timescale:%d",_composition.frameDuration.timescale);
    originViedoFPS=_composition.frameDuration.timescale;//获取每秒视频帧数
    originDuration=duration;
    // *** Fetch First 200 frames only  test ok ***
    /*for (int i=0; i<1528; i+=5) {
     NSValue * time = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(i*frameDuration, composition.frameDuration.timescale)];
     [times addObject:time];
     }*/
    
    
    for (int i=0; i<(int)totalFrames; i+=1) {
        NSValue * time = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(i*frameDuration*3, _composition.frameDuration.timescale*3)];
        [times addObject:time];
    }
    
    
    __block NSInteger count = 0;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        // If actualTime is not equal to requestedTime image is ignored
        if(CMTimeCompare(actualTime, requestedTime) == 0)
        {
            if (result == AVAssetImageGeneratorSucceeded) {
                //                NSLog(@"%.02f     %.02f", CMTimeGetSeconds(requestedTime), CMTimeGetSeconds(actualTime));
                // Each log have differents actualTimes.
                // frame extraction is here...
                NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *filePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.jpg",CMTimeGetSeconds(requestedTime)]];
                [UIImageJPEGRepresentation([UIImage imageWithCGImage:im], 0.8f) writeToFile:filePath atomically:YES];
                //[_imageArry addObject:[UIImage imageWithContentsOfFile:filePath]];
                //因为拿到的是个路径 把它加载成一个data对象
                NSData *data=[NSData dataWithContentsOfFile:filePath];
                //直接把该 图片读出来
                UIImage *img=[UIImage imageWithData:data];
                
                [_imageArry addObject:img];
                
                count++;
                NSLog(@"filepath:%@,%d,%zu,%zu",filePath,count,CGImageGetWidth(im),CGImageGetHeight(im));
                originViedoWidth=CGImageGetWidth(im);
                originViedoHeight=CGImageGetHeight(im);
                //[self performSelector:@selector(updateStatusWithFrame:) onThread:[NSThread mainThread] withObject:[NSString stringWithFormat:@"%d Processing %d of %.0f",count,count,totalFrames] waitUntilDone:NO];
                
            }
            else if(result == AVAssetImageGeneratorFailed)
            {
                //[lblFileStatus setText:@"Failed to Extract"];
            }
            else if(result == AVAssetImageGeneratorCancelled)
            {
                //[lblFileStatus setText:@"Process Cancelled"];
            }
        }
    };
    
    _generator.requestedTimeToleranceBefore = kCMTimeZero;
    _generator.requestedTimeToleranceAfter = kCMTimeZero;
    [_generator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
    
}

- (void)removeAllFiles
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        // NSLog(@"file:%@",[NSString stringWithFormat:@"%@/%@", directory, file]);
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
}
//视频添加背景音乐
-(void)CompileFilesToMakeMovie:(NSString *)toPath withMovie:(NSString *)moviePath withAudio:(NSString *)audioPath
{
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSString* audio_inputFileName = @"sound.caf";
    NSString* audio_inputFilePath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], audio_inputFileName] ;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"布谷鸟" ofType:@"caf"];

    NSURL*    audio_inputFileUrl = [NSURL fileURLWithPath:filePath];
    
    NSString* video_inputFileName = @"video.mov";
    NSString* video_inputFilePath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], video_inputFileName] ;
    NSURL*    video_inputFileUrl = [NSURL fileURLWithPath:video_inputFilePath];
    
    NSString* outputFileName = @"outputVeido.mov";
    NSString* outputFilePath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], outputFileName] ;
    NSURL*    outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    __weak CCViewController *ref = self;

    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         //ref.activityIndicatorView.hidesWhenStopped = NO;
         [ref.activityIndicatorView stopAnimating];
         ref.activityIndicatorView.hidesWhenStopped = YES;
     }
     ];
    
    
}
@end



