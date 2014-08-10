//
//  NomeRecordSoundViewController.m
//  Nome
//
//  Created by Matt Brenman on 8/9/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

const double SECONDS_PER_MIN = 60.0;

#import "NomeRecordSoundViewController.h"
#import <Parse/Parse.h>

@interface NomeRecordSoundViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) NSMutableArray *urlArray;
@property (nonatomic, strong) NSMutableArray *playerArray;
@property int count;

@property (nonatomic) NSTimeInterval recordingDuration;
@end

@implementation NomeRecordSoundViewController

- (IBAction)startRecordingAudio:(id)sender {
    _playButton.enabled = NO;
    _stopButton.enabled = NO;
    _recButton.enabled  = NO;
    if (!_audioRecorder){
        //Remake the recorder for a different file url
        _audioRecorder = [self newAudioRecorderWithFileName:[[NSString stringWithFormat:@"%d", _count++] stringByAppendingString:@".caf"]];
    }
    if (!_audioRecorder.recording)
    {
        [_audioRecorder setDelegate:self];
        
        //Prepare to play and record
        [self prepareForPlay];
        [_audioRecorder prepareToRecord];
        
        //Play and Record
        [self playSounds];
        [_audioRecorder recordForDuration:_recordingDuration];
    }
}

- (void)startRecorder
{
    [_audioRecorder recordForDuration:_recordingDuration];
}

- (IBAction)stopRecordingAudio:(id)sender {
    _stopButton.enabled = NO;
    _playButton.enabled = YES;
    _recButton.enabled = YES;
    
    for (AVAudioPlayer *player in _playerArray){
        if (player.playing){
            [player stop];
        }
    }
}

- (IBAction)playAudioClick:(id)sender {
    _stopButton.enabled = YES;
    _recButton.enabled = NO;
    
    [self prepareForPlay];
    [self playSounds];
}

- (void)playSounds
{
    if ([_playerArray count] > 0){
        NSTimeInterval shortStartDelay = 0.01;            // seconds
        NSTimeInterval now = [[_playerArray firstObject] deviceCurrentTime];
        
        for (AVAudioPlayer *player in _playerArray){
            NSLog([player description]);
            NSLog([[player settings] description]);
            [player playAtTime: now + shortStartDelay];
        }
    }
}

- (void)prepareForPlay
{
    //Empty the player array to not double everything
    [_playerArray removeAllObjects];
    
    for (NSString *urlstring in _urlArray){
        NSLog(urlstring);
        NSURL *url = [self NSURLfrom:urlstring];
        
        //Load from Data
        NSString *path = [url path];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        
        NSLog([data description]);
        
        AVAudioPlayer *player = [self newAudioPlayerWithData:data];
        
        //AVAudioPlayer *player = [self newAudioPlayerWithURL:url];
        [player prepareToPlay];
        [_playerArray addObject:player];
    }
}

- (NSURL *)NSURLfrom:(NSString *)nsstring
{
    NSString *urlString = [NSString stringWithFormat:@"%@", nsstring];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return url;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _count = 0;
    _urlArray = [[NSMutableArray alloc] init];
    _playerArray = [[NSMutableArray alloc] init];
    //Pull username and display it
    [_nameLabel setText:[[PFUser currentUser] username]];
    
    
    //THESE SHOULD BE SET WHEN THIS IS CALLED - OR SET FROM THE PROJECT
    _bpm = 60;
    _numBeats = 8;
    
    [self setupRecordingDuration];
    
    _playButton.enabled = NO;
    _stopButton.enabled = NO;
    
    _audioRecorder = [self newAudioRecorderWithFileName:@"sound.caf"];
}

- (void)setupRecordingDuration
{
    double beatLen = SECONDS_PER_MIN/((double)_bpm);
    _recordingDuration = beatLen * _numBeats;
}

- (AVAudioRecorder *)newAudioRecorderWithFileName:(NSString *)fileName
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:fileName];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    AVAudioRecorder *audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordSettings
                      error:&error];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }
    return audioRecorder;
}

- (AVAudioPlayer *)newAudioPlayerWithURL: (NSURL *)url
{
    NSError *error;
    
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]
                    initWithContentsOfURL:url
                    error:&error];
    
    audioPlayer.delegate = self;
    
    if (error)
        NSLog(@"Error: %@", [error localizedDescription]);
    
    return audioPlayer;
}

- (AVAudioPlayer *)newAudioPlayerWithData:(NSData *)data
{
    NSError *error;
    
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]
                                  initWithData:data
                                  error:&error];
    
    audioPlayer.delegate = self;
    
    if (error)
        NSLog(@"Error: %@", [error localizedDescription]);
    
    return audioPlayer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Audio Delegate Methods
-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _recButton.enabled = YES;
    _stopButton.enabled = NO;
}

-(void)audioPlayerDecodeErrorDidOccur:
(AVAudioPlayer *)player
                                error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}

-(void)audioRecorderDidFinishRecording:
(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag
{
    NSString *url = [[NSString alloc] initWithString:[_audioRecorder.url absoluteString]];
    [_urlArray addObject:url];
    _audioRecorder = nil;
    [self stopRecordingAudio:nil];
}

-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

@end
