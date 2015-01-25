//
//  NMEProjectViewController.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

typedef enum : NSUInteger {
    playingState,
    loopingPlayState,
    recordingState,
    defaultState,
} state;

const double SECONDS_PER_MIN = 60.0;
const double INDICATOR_SIDE_LENGTH = 20;

#import "NMERecorderViewController.h"
#import "NMERecorderTableViewCell.h"
#import "NMEAppDelegate.h"

@interface NMERecorderViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *indicator;

//Control Button links
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *loopButton;

@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;

@property (strong, nonatomic) IBOutlet UITableView  *tableView;

//Player information
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

//Storage for audio parts
@property (nonatomic, strong) NSMutableArray *urlArray;
@property (nonatomic, strong) NSMutableArray *playerArray;
@property (nonatomic, strong) NSMutableArray *metronomeArray;

//For naming .caf files
@property int count;

//Audio info
@property (nonatomic) NSTimeInterval recordingDuration;
@property (nonatomic) NSInteger bpm;
@property (nonatomic) NSInteger numBeats;

@property (nonatomic, strong) NSMutableArray *loopObjects;
@property (nonatomic, strong) NSMutableArray *rawSoundData;

//State
@property (nonatomic) state currentState;

//For loading icon and blocking clicks
@property (nonatomic,strong) UIView *blockerView;

@end

@implementation NMERecorderViewController

//KVO for button fading
- (void)setCurrentState:(state)currentState{
    _currentState = currentState;
    switch (currentState) {
        case playingState:
            [self enterPlayingState];
            break;
        case loopingPlayState:
            [self enterLoopingState];
            break;
        case recordingState:
            [self enterRecordingState];
            break;
        case defaultState:
            [self enterDefaultState];
            break;
        default:
            break;
    }
}

- (void)enterRecordingState{
    _playButton.enabled = NO;
    _stopButton.enabled = NO;
    _recordButton.enabled  = NO;
    _loopButton.enabled  = NO;
    
    if (!_audioRecorder) {
        //Remake the recorder for a different file url
        _audioRecorder = [self newAudioRecorderWithFileName:[[NSString stringWithFormat:@"%d", _count++] stringByAppendingString:@".caf"]];
    }
    if (!_audioRecorder.recording) {
        [_audioRecorder setDelegate:self];
        
        //Prepare to play and record
        [self prepareForPlay];
        [_audioRecorder prepareToRecord];
        
        //Create metronome
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"claveHit" ofType:@"caf"]];
        AVAudioPlayer *player = [self newAudioPlayerWithURL: url];
        [player prepareToPlay];
        NSTimeInterval now = [player deviceCurrentTime];
        now = [self createMetronome:now];
        
        //Play and Record
        for (AVAudioPlayer *player in _playerArray){
            [player playAtTime: now];
        }
        [_audioRecorder recordAtTime:now forDuration:self.recordingDuration];
    }
}

- (void)enterPlayingState{
    _stopButton.enabled = YES;
    _playButton.enabled = NO;
    _recordButton.enabled = NO;
    _loopButton.enabled = NO;
    
    //Create metronome
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"claveHit" ofType:@"caf"]];
    AVAudioPlayer *player = [self newAudioPlayerWithURL: url];
    [player prepareToPlay];
    NSTimeInterval now = [player deviceCurrentTime];
    
    [self prepareForPlay];

    now = [self createMetronome:now];

    //Play all loops
    for (AVAudioPlayer *player in _playerArray){
        [player playAtTime: now];
    }
}

- (void)enterLoopingState{
    _stopButton.enabled = YES;
    _playButton.enabled = NO;
    _recordButton.enabled = NO;
    _loopButton.enabled = NO;
    
    //Create metronome
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"claveHit" ofType:@"caf"]];
    AVAudioPlayer *player = [self newAudioPlayerWithURL: url];
    NSTimeInterval now = [player deviceCurrentTime];

    [self prepareForPlay];
    
    //Play all loops until stopped
    for (AVAudioPlayer *player in _playerArray){
        [player setNumberOfLoops:-1];
        [player playAtTime: now];
    }
}

- (void)enterDefaultState{
    NSArray *loops = self.project[@"loops"];
    
    _stopButton.enabled = NO;
    _recordButton.enabled = YES;
    
    if ([loops count] > 0 || [_urlArray count] > 0){
        _playButton.enabled = YES;
        _loopButton.enabled  = YES;
    } else {
        _playButton.enabled = NO;
        _loopButton.enabled  = NO;
    }
    
    //Stop all music from playing
    for (AVAudioPlayer *player in self.playerArray){
        if (player.playing){
            [player stop];
        }
    }
    
    //Stop all metronomes
    for (AVAudioPlayer *player in self.metronomeArray){
        if (player.playing){
            [player stop];
        }
    }
}

- (IBAction)recordButtonPressed:(id)sender {
    self.currentState = recordingState;
}
- (IBAction)playButtonPressed:(id)sender {
    self.currentState = playingState;
}
- (IBAction)pressedStopButton:(id)sender {
    self.currentState = defaultState;
}
- (IBAction)pressedLoopButton:(id)sender {
    self.currentState = loopingPlayState;
}

- (IBAction)addCollaboratorClick:(id)sender {
    //Create popup to prompt username input
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"New Bandmate" message:@"Who's joining the team?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    //Show the prompt
    [av show];
}

- (NSTimeInterval)createMetronome:(NSTimeInterval) now
{
    //Find length of each beat
    double beatLen = SECONDS_PER_MIN/((double)self.bpm);
    
    //Clear current metronomes
    [self.metronomeArray removeAllObjects];
    
    NSInteger beatsPerMeasure = [self.project[@"beatsPerMeasure"] intValue];
    
    //Create lead-in clicks and a click for all beats
    //TODO: rename beatsPerMeasure to totalBeats, since it is misleading now
    for (int i=0; i<=(self.numBeats + beatsPerMeasure); i++) {
        //Create click sound
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"claveHit" ofType:@"caf"]];
        AVAudioPlayer *player = [self newAudioPlayerWithURL: url];
        
        [player prepareToPlay];
        [player setVolume:.5f];
        
        [self.metronomeArray addObject:player];
        
        //Play when it should be played (calculated for each beat)
        [player playAtTime:now + ((i + 1) * beatLen)];
    }
    
    //Return time after the count in (when the loops start)
    return now + (beatsPerMeasure + 1)*beatLen;
}

- (void)prepareForPlay
{
    //Empty the player array to not double everything
    [_playerArray removeAllObjects];
    
    for (int i = 0; i < self.rawSoundData.count; i++) {
        NSData *data = [self.rawSoundData objectAtIndex:i];

        //Create audio players as needed
        AVAudioPlayer *player = [self newAudioPlayerWithData:data];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        NMERecorderTableViewCell *cell = (NMERecorderTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        //Set volume based on the associated slider
        player.volume = cell.volumeSlider.value;
        
        [player prepareToPlay];
        
        //Add object to array of to-be-played objects
        [_playerArray addObject:player];
    }
}

- (IBAction)volumeValueChanged:(UISlider *)sender {
    [[self.playerArray objectAtIndex:sender.tag] setVolume:sender.value];
}

/*
 * This function allows the audio to always play through the speakers, even
 * when recording, and it comes from this Stack Overflow link:
 *
 * http://stackoverflow.com/questions/18807157/how-do-i-route-audio-to-speaker-without-using-audiosessionsetproperty/18808124#18808124
 */
 - (void)setToPlayThroughSpeakers
{
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    //set the audioSession category.
    //Needs to be Record or PlayAndRecord to use audioRouteOverride:
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                             error:&error];
    
    if (!success) {
        NSLog(@"AVAudioSession error setting category:%@",error);
    }
    
//    //set the audioSession override
//    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
//                                         error:&error];
//    if (!success) {
//        NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
//    }
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success) {
        NSLog(@"AVAudioSession error activating: %@",error);
    } else {
        NSLog(@"audioSession active");
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
    NSInteger bpm = [[_project[@"bpm"] description] intValue];
    NSInteger numBeats = [[_project[@"totalBeats"] description] intValue];
    
    double beatLen = SECONDS_PER_MIN/((double)bpm);
    _recordingDuration = beatLen * numBeats;
    _bpm = bpm;
    _numBeats = numBeats;
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
    
    if (error) {
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
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
        
    return audioPlayer;
}

- (AVAudioPlayer *)newAudioPlayerWithData:(NSData *)data
{
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]
                                  initWithData:data
                                  error:&error];
    
    audioPlayer.delegate = self;
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    return audioPlayer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Blocks any clicking until data is pulled from Parse
    [self beginLoadingAnimation];
    
    [self.navigationItem setTitle:self.project[@"projectName"]];
    
    //Do we want this? Users with headphones should be able to use them
    //Changing may mess up playing while recording
    [self setToPlayThroughSpeakers];
    
    //Disable buttons initially
    _playButton.enabled = NO;
    _stopButton.enabled = NO;
    _recordButton.enabled = NO;
    _loopButton.enabled = NO;
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView reloadData];

    [self getAudioFromParse];
    
    _count = 1; //For initial .caf file
    _urlArray = [[NSMutableArray alloc] init];
    _playerArray = [[NSMutableArray alloc] init];
    
    [self setupRecordingDuration];
    
    //Set up initial recorder
    _audioRecorder = [self newAudioRecorderWithFileName:@"0.caf"];
}

- (void)getAudioFromParse
{
    [self.project fetchIfNeeded];
    
    NSArray *loopDictionaries = self.project[@"loops"];
    
    self.loopObjects = [[NSMutableArray alloc] init];
    
    for (PFObject* object in loopDictionaries) {
        [self.loopObjects addObject:@" "];
    }
    
    for (int i = 0; i < self.loopObjects.count; i++) {
        PFObject *object = [loopDictionaries objectAtIndex:i];
        PFObject *objectPointer = object[@"id"];
        
        if ([objectPointer objectId]){
            PFQuery *query = [PFQuery queryWithClassName:@"loopObject"];
            [query whereKey:@"objectId" equalTo:[objectPointer objectId]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [self.loopObjects setObject:object atIndexedSubscript:i];
            }];
            [self.tableView reloadData];
        }
    }
    
    //This should be able to be done more elegantly
    //Don't rely un async calls to finish before this is called
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadFiles];
    });
}

- (void)loadFiles{
    _rawSoundData = [[NSMutableArray alloc] init];
    
    for (PFObject* object in self.loopObjects) {
        [self.rawSoundData addObject:[[object objectForKey:@"file"] getData]];
    }
    [self prepareForPlay];
    
    [self endLoadingAnimation];
    
    self.currentState = defaultState;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.indicator];
    [self.view bringSubviewToFront:self.blockerView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0., 0., 320, 320);
    self.tableView.backgroundColor =[UIColor colorWithWhite:.7 alpha:1.];
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.4 alpha:1.];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NMERecorderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recorderTableCell"];
    
    if (!cell) {
        cell = [[NMERecorderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"projectTableCell"];
    }
    
    PFObject *currentProject = self.project;
    
    NSDictionary *loop = [currentProject[@"loops"] objectAtIndex:indexPath.row];
    
    cell.loopNameLabel.text = [loop objectForKey:@"name"];
    
    cell.loopNameLabel.font = [UIFont fontWithName:@"Avenir" size:18];
    cell.loopNameLabel.textColor = [UIColor colorWithWhite:.35 alpha:1.];
    
    cell.backgroundColor = [UIColor colorWithWhite:.7 alpha:1.];
    
#warning set volume from parse data
    cell.volumeSlider.maximumValue = 1.f;
    cell.volumeSlider.minimumValue = 0.f;
    cell.volumeSlider.backgroundColor = [UIColor colorWithWhite:.3 alpha:1.];
    cell.volumeSlider.tag = indexPath.row;
    
    return cell;
}

- (void)beginLoadingAnimation
{
    CGRect fullscreen = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    //Cover the screen with transparent screen (no clicks)
    self.blockerView = [[UIView alloc] initWithFrame:fullscreen];
    self.blockerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.blockerView];
    
    //Create loading icon
    CGRect indicatorFrame = CGRectMake((self.view.frame.size.width - INDICATOR_SIDE_LENGTH)/2,
                                       (self.view.frame.size.width - INDICATOR_SIDE_LENGTH)/2,
                                       INDICATOR_SIDE_LENGTH,
                                       INDICATOR_SIDE_LENGTH);
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                      UIActivityIndicatorViewStyleWhiteLarge];
    
    self.indicator.frame = indicatorFrame;
    
    //Add and start the loading icon
    [self.view addSubview:self.indicator];
    [self.indicator startAnimating];
}

- (void)endLoadingAnimation
{
    [self.blockerView removeFromSuperview];
    self.blockerView = nil;
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
    self.indicator = nil;
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
    return [loops count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //Don't allow users to delete or edit when recording or playing
    if (self.currentState == defaultState) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) { 
        NSInteger row = indexPath.row;
        
        //Delete files
        [self.loopObjects removeObjectAtIndex:row];
        [self.rawSoundData removeObjectAtIndex:row];

        //Remove with animation (disallows double click)
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        NSLog(@"%@",[self.project valueForKey:@"loops"] );
        
        //Remove on Parse as well
        self.project[@"loops"] = self.loopObjects;
        [self.project saveInBackground];
    }
}

#pragma mark - Audio Delegate Methods
-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSURL *calvUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"claveHit" ofType:@"caf"]];

    NSString *claveURLString = [[calvUrl filePathURL] description];
    NSString *otherURLString = [[[player url] filePathURL] description];
    
    //claveHit ends with every beat, so only end when the actual recording ends
#warning see TODO
    //TODO: If we don't have any loops, we never enter the default state again
    if (![claveURLString isEqualToString:otherURLString]){
        self.currentState = defaultState;
    }
}

-(void)audioPlayerDecodeErrorDidOccur: (AVAudioPlayer *)player
                                error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag
{
    NSString *url = [[NSString alloc] initWithString:[_audioRecorder.url absoluteString]];
    //Save the object
    [_urlArray addObject:url];

    //Ask if user wants to keep it
    [self showAlert];
}

- (void)showAlert
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Title"
                                                 message:@"Please name your loop!"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Keep", nil];
    
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView title]  isEqual: @"New Bandmate"]){
        //Add username to project
        if (buttonIndex == 0){
            //Clicked cancel
            NSLog(@"no new bandmate");
        } else {

            NSString *bandmate = [[alertView textFieldAtIndex:0] text];
            
            //Make sure the bandmate is not an empty string
            if (bandmate.length > 0){
            
                NSMutableArray *collabs = _project[@"collaborators"];
                
                //Only add the bandmate if they're not in the project
                if (![collabs containsObject:bandmate]){
                    [collabs addObject:bandmate];
                    [_project saveInBackground];
                } else {
                    NSLog(@"Bandmate already in project");
                }
                
            } else {
                NSLog(@"empty bandmate");
            }
        }
    } else {
        if (buttonIndex == 1){
            //User wants to save and name their loop
            NSString *loopTitle = [[alertView textFieldAtIndex:0] text];
            NSString *loopLocalFile = [_audioRecorder.url absoluteString];
            NSURL *url = [self NSURLfrom:loopLocalFile];
        
            //Load from Data
            NSString *path = [url path];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        
            PFObject *loopDataObject = [self createLoopObjectWithData:data];
        
            //Redownload loops and project to avoid overwriting friends data

            [self.project fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                self.project = object;
            
                NSMutableArray *loops = [[NSMutableArray alloc] initWithArray:_project[@"loops"]];
                NSString *username = [[PFUser currentUser] username];
            
                [loops addObject:@{@"name" : loopTitle, @"creator" : username, @"id": loopDataObject}];
            
                self.loopObjects = loops;
                self.project[@"loops"] = self.loopObjects;
            
                NSLog(@"loop array length %@", _project[@"loops"]);

                [self.project saveInBackground];
                [loopDataObject saveInBackground];
            
                //Reload table to see new tracks
                [self.tableView reloadData];
                [self.rawSoundData addObject:data];
            }];
         
            _audioRecorder = nil;
            self.currentState = defaultState;
        }
    }
}

-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder error:(NSError *)error
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

- (NSMutableArray *)metronomeArray{
    if (!_metronomeArray) {
        _metronomeArray = [[NSMutableArray alloc] init];
    }
    return _metronomeArray;
}

@end
