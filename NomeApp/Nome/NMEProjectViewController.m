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

#import "NMEProjectViewController.h"
#import "NMEProjectTableViewCell.h"
#import "NMEAppDelegate.h"
#import "NMEDataManager.h"

@interface NMEProjectViewController () 

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

@end

@implementation NMEProjectViewController

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
            //Can we just make this the default case? Or does this function
            //randomly get called so that we need to code in a specific
            //name for when we actually want to switch?
            //
            //I think we should keep it this way, it self-documents and leaves
            //our options open for things like using a state stack later on
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

    for (AVAudioPlayer *player in _playerArray){
        [player playAtTime: now];
    }
}

- (void)enterLoopingState{
    _stopButton.enabled = YES;
    _playButton.enabled = NO;
    _recordButton.enabled = NO;
    _loopButton.enabled = NO;
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"claveHit" ofType:@"caf"]];
    AVAudioPlayer *player = [self newAudioPlayerWithURL: url];
    NSTimeInterval now = [player deviceCurrentTime];

    [self prepareForPlay];
    
    for (AVAudioPlayer *player in _playerArray){
        [player setNumberOfLoops:-1];
        [player playAtTime: now];
    }
}

- (void)enterDefaultState{
    _stopButton.enabled = NO;
    _playButton.enabled = YES;
    _recordButton.enabled = YES;
    _loopButton.enabled  = YES;
    
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
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Who's joining the team?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Keep", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    //    [av textFieldAtIndex:0].delegate = self;
    [av show];
}

- (NSTimeInterval)createMetronome:(NSTimeInterval) now
{
    double beatLen = SECONDS_PER_MIN/((double)self.bpm);
    [self.metronomeArray removeAllObjects];
    
    for (int i=0; i<=(self.numBeats + 5); i++) {
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"claveHit" ofType:@"caf"]];
        AVAudioPlayer *player = [self newAudioPlayerWithURL: url];
        
        NSLog(@"claveeee");
        
        [player prepareToPlay];
        
        [self.metronomeArray addObject:player];
        [player playAtTime:now + (i * beatLen)];
    }
    return now + 5*beatLen;
}

- (void)prepareForPlay
{
    //Empty the player array to not double everything
    [_playerArray removeAllObjects];
    
//    for (NSData *data in self.rawSoundData){
    
    for (int i = 0; i < self.rawSoundData.count; i++) {
        NSData *data = [self.rawSoundData objectAtIndex:i];
        
        AVAudioPlayer *player = [self newAudioPlayerWithData:data];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        NMEProjectTableViewCell *cell = (NMEProjectTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        player.volume = cell.volumeSlider.value;
        
        [player prepareToPlay];
        
        NSLog(@"adding5");
        [_playerArray addObject:player];
        NSLog(@"finadding5");
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
    
    if (!success)  NSLog(@"AVAudioSession error setting category:%@",error);
    
    //set the audioSession override
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                         error:&error];
    if (!success)  NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success) NSLog(@"AVAudioSession error activating: %@",error);
    else NSLog(@"audioSession active");
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

    [self setToPlayThroughSpeakers];
    
    _playButton.enabled = NO;
    _stopButton.enabled = NO;
    _recordButton.enabled = NO;
    _loopButton.enabled = NO;
    
    
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView reloadData];
    
//    self.donateButton.font = [UIFont fontWithName:@"Avenir-Light" size:16];
//    [self.donateButton setTitleColor:[UIColor colorWithHue:.32 saturation:.3 brightness:1. alpha:1.] forState:UIControlStateNormal];
    
    [self getAudioFromParse];
    
    _count = 1; //For initial .caf file
    _urlArray = [[NSMutableArray alloc] init];
    _playerArray = [[NSMutableArray alloc] init];
    //Pull username and display it
    
    NSLog(@"REC DURATION");
    [self setupRecordingDuration];
    
    _audioRecorder = [self newAudioRecorderWithFileName:@"0.caf"];
}

- (void)getAudioFromParse
{
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
            NSLog(@"got shit");
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadFiles];
    });
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
    _playButton.enabled = YES;
    _recordButton.enabled = YES;
    _loopButton.enabled = YES;
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
    NMEProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"projectTableCell"];
    
    if (!cell) {
        cell = [[NMEProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"projectTableCell"];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.'
    NSMutableArray *loops = self.project[@"loops"];
//    NSLog(@"COUNT! %u",[loops count]);

    return [loops count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentState == defaultState) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) { 
        NSInteger row = indexPath.row;
        [self.loopObjects removeObjectAtIndex:row];
        [self.rawSoundData removeObjectAtIndex:row];

        NSLog(@"%@",[self.project valueForKey:@"loops"] );
        
        self.project[@"loops"] = self.loopObjects;
        [self.project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.tableView reloadData];
            }
        }];
    }
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
    NSURL *calvUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"claveHit" ofType:@"caf"]];

    NSString *claveURLString = [[calvUrl filePathURL] description];
    NSString *otherURLString = [[[player url] filePathURL] description];

    if (![claveURLString isEqualToString:otherURLString]){
        self.currentState = defaultState;
    }
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
    if (buttonIndex == 1){
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

- (NSMutableArray *)metronomeArray{
    if (!_metronomeArray) {
        _metronomeArray = [[NSMutableArray alloc] init];
    }
    return _metronomeArray;
}


//- (void)playSoundsAndLoop:(BOOL) loop atTime:(NSTimeInterval) now
//{
//    if ([_playerArray count] > 0){
//        //        NSTimeInterval shortStartDelay = 0.05;            // seconds
//        //        NSTimeInterval now = [[_playerArray firstObject] deviceCurrentTime];
//
//        for (AVAudioPlayer *player in _playerArray){
//            if (loop){
//                [player setNumberOfLoops:-1];
//            }
//            [player playAtTime: now];
//
//        }
//    }
//}

@end
