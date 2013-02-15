//
//  ABViewController.m
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import "ABViewController.h"
#import "ABTestManager.h"
#import "ABTestCase.h"
#import "ABTestCaseOutcome.h"
#import "ABTestButton.h"

@interface ABViewController ()

@end

@implementation ABViewController
@synthesize testCaseButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    ABTestCase *testCase = [[ABTestCase alloc] initWithTestCase:@"next_button_text" andControlValue:@"No Test Case Used"];
    NSString *testCaseText = [testCase value];
    [self.testCaseButton setTitle:testCaseText forState:UIControlStateNormal];
    
  /*  ABTestButton *testButton = [[ABTestButton alloc] initWithTestName:@"next_button_text" andControlValue:@"No Tests Loaded"];
    [testButton setFrame:CGRectMake(68, 400, 196, 39)];
    NSString * t = [testButton titleForState:UIControlStateNormal];
    
    [[self view] addSubview:testButton];*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)refreshTestCases:(id)sender
{
    [[ABTestManager testManager] refreshTestCaseConfigurations];
}

-(IBAction)testCaseButtonTapped:(id)sender
{
    ABTestCaseOutcome *outcome = [[ABTestCaseOutcome alloc] initWithTestCase:@"next_button_text" andOutcomeResponse:ABPositiveResponse];
    [outcome send];
}

-(IBAction)IBTestCaseButtonTapped:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"This ran" message:@"The ABTestButton reporting code ran as well as the IBAction in the VC :)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
}

@end
