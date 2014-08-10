//
//  NMEProjectViewController.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

const double SECONDS_PER_MIN = 60.0;

#import "NMEProjectViewController.h"
#import "NMEProjectTableViewCell.h"
#import "NMEAppDelegate.h"
#import "NMEDataManager.h"

@interface NMEProjectViewController () 

//Control Button links
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;

@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;

@property (strong, nonatomic) IBOutlet UITableView  *tableView;

//Player information
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

//Audio Info
@property (nonatomic) int bpm;
@property (nonatomic) int numBeats;

//Storage for audio parts
@property (nonatomic, strong) NSMutableArray *urlArray;
@property (nonatomic, strong) NSMutableArray *playerArray;

//For naming .caf files
@property int count;

//Audio info
@property (nonatomic) NSTimeInterval recordingDuration;

@property (nonatomic, strong) NSMutableArray *loopObjects;
@property (nonatomic, strong) NSMutableArray *rawSoundData;

@end

@implementation NMEProjectViewController

- (IBAction)recordButtonPressed:(id)sender {
    _playButton.enabled = NO;
    _stopButton.enabled = NO;
    _recordButton.enabled  = NO;
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
- (IBAction)playButtonPressed:(id)sender {
    _stopButton.enabled = YES;
    _recordButton.enabled = NO;
    
    [self prepareForPlay];
    [self playSounds];
}
- (IBAction)pressedStopButton:(id)sender {
    _stopButton.enabled = NO;
    _playButton.enabled = YES;
    _recordButton.enabled = YES;
    
    for (AVAudioPlayer *player in _playerArray){
        if (player.playing){
            [player stop];
        }
    }
}

- (void)startRecorder
{
    [_audioRecorder recordForDuration:_recordingDuration];
}

- (IBAction)stopRecordingAudio:(id)sender {
    _stopButton.enabled = NO;
    _playButton.enabled = YES;
    _recordButton.enabled = YES;
    
    for (AVAudioPlayer *player in _playerArray){
        if (player.playing){
            [player stop];
        }
    }
}

- (void)playSounds
{
    if ([_playerArray count] > 0){
        NSTimeInterval shortStartDelay = 0.01;            // seconds
        NSTimeInterval now = [[_playerArray firstObject] deviceCurrentTime];
        
        for (AVAudioPlayer *player in _playerArray){
            [player playAtTime: now + shortStartDelay];
        }
    }
}

- (void)prepareForPlay
{
    //Empty the player array to not double everything
    [_playerArray removeAllObjects];
//    
//    for (NSString *urlstring in _urlArray){
//        NSURL *url = [self NSURLfrom:urlstring];
//        
//        //Load from Data
//        NSString *path = [url path];
//        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];

    for (NSData *data in self.rawSoundData){
        AVAudioPlayer *player = [self newAudioPlayerWithData:data];
        
        //AVAudioPlayer *player = [self newAudioPlayerWithURL:url];
        [player prepareToPlay];
        NSLog(@"adding5");
        [_playerArray addObject:player];
        NSLog(@"finadding5");
    }
}

- (NSURL *)NSURLfrom:(NSString *)nsstring
{
    NSString *urlString = [NSString stringWithFormat:@"%@", nsstring];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return url;
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
    self.projectNameLabel = self.project[@"name"];

    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView reloadData];
    
    [self getAudioFromParse];
    
    _count = 1; //For initial .caf file
    _urlArray = [[NSMutableArray alloc] init];
    _playerArray = [[NSMutableArray alloc] init];
    //Pull username and display it
    
    //THESE SHOULD BE SET WHEN THIS IS CALLED - OR SET FROM THE PROJECT
    _bpm = 60;
    _numBeats = 1;
    
    [self setupRecordingDuration];
    
    _stopButton.enabled = NO;
    
    _audioRecorder = [self newAudioRecorderWithFileName:@"0.caf"];
}

- (void)getAudioFromParse
{
    NSArray *loopDictionaries = self.project[@"loops"];
    NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
    for (PFObject *object in loopDictionaries) {
        PFObject *objectPointer = object[@"id"];
        NSLog(@"adding1");
        NSLog([object description]);
        NSLog([objectPointer objectId]);
        NSLog(@"continuing");
        if ([objectPointer objectId]){
            [objectIDs addObject:[objectPointer objectId]];
        } else {
            NSLog(@"SKIPPED EMPTY");
        }
        NSLog(@"finadding1");
    }
    PFQuery *query = [PFQuery queryWithClassName:@"loopObject"];
    [query whereKey:@"objectId" containedIn:objectIDs];
//    [query includeKey:@"file"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loopObjects = [[NSMutableArray alloc] initWithArray: objects];
//        NSLog([NSString stringWithFormat:@"%@", objects]);
        [self.tableView reloadData];
        [self loadFiles];
    }];
}

- (void)loadFiles{
    _rawSoundData = [[NSMutableArray alloc] init];
    for (PFObject* object in self.loopObjects) {
        [[object objectForKey:@"file"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            NSLog(@"adding2");
            [self.rawSoundData addObject:data];
            NSLog(@"finadding2");

        }];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0., 0., 320, 320);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NMEProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"projectTableCell"];
    
    if (!cell) {
        cell = [[NMEProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"projectTableCell"];
    }
    
    PFObject *currentProject = self.project;
    
    //    cell.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];
    NSDictionary *loop = [currentProject[@"loops"] objectAtIndex:indexPath.row];
    
    cell.loopNameLabel.text = [loop objectForKey:@"name"];
    
    cell.loopNameLabel.font = [UIFont fontWithName:@"Avenir" size:18];
    cell.loopNameLabel.textColor = [UIColor colorWithWhite:.35 alpha:1.];
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.'
    NSMutableArray *loops = self.project[@"loops"];
    NSLog(@"COUNT! %u",[loops count]);

    return [loops count];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.clickedObject = [self.project objectAtIndex:indexPath.row];
//    [self performSegueWithIdentifier:@"projectsToProject" sender:self];
//}

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
    _recordButton.enabled = YES;
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
    NSLog(@"adding3");
    [_urlArray addObject:url];
    NSLog(@"finadding3");

    [self stopRecordingAudio:nil];
    [self showAlert];
}

- (void)showAlert
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Please name your loop!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Keep", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1){
        NSLog([[alertView textFieldAtIndex:0] text]);
        NSString *loopTitle = [[alertView textFieldAtIndex:0] text];
        NSString *loopLocalFile = [_audioRecorder.url absoluteString];
        NSLog(loopLocalFile);
        
        NSURL *url = [self NSURLfrom:loopLocalFile];
        
        //Load from Data
        NSString *path = [url path];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        
        PFObject *loopDataObject = [self createLoopObjectWithData:data];
        NSMutableArray *loops = [[NSMutableArray alloc] initWithArray:_project[@"loops"]];
        NSString *username = [[PFUser currentUser] username];
        NSLog(@"adding4");
        [loops addObject:@{@"name" : loopTitle, @"creator" : username, @"id": loopDataObject}];
        NSLog(@"finadding4");

        //Redownload loops to avoid overwriting friends data
        _project[@"loops"] = loops;
        [_project saveInBackground];
        [loopDataObject saveInBackground];
        
        //hold users from leaving until we sync data?
        
        _audioRecorder = nil;
    }
}

-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

#pragma mark - Parse Data Handling
- (PFObject *)createLoopObjectWithData:(NSData *)data
{
    PFObject *loopObject = [[PFObject alloc] initWithClassName:@"loopObject"];
    PFFile *loopFile = [PFFile fileWithName:@"audio.caf" data:data];
    loopObject[@"file"] = loopFile;
    return loopObject;
}



@end
