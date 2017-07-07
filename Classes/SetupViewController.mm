/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "BoardViewController.h"
#import "Options.h"
#import "SelectedPieceView.h"
#import "SetupBoardView.h"
#import "SetupViewController.h"
#import "SideToMoveController.h"

@implementation SetupViewController

@synthesize boardViewController;

- (id)initWithBoardViewController:(BoardViewController *)bvc
                              fen:(NSString *)aFen {
   if (self = [super init]) {
      [self setTitle: @"Board"];
      boardViewController = bvc;
      fen = aFen;
      [self setPreferredContentSize: CGSizeMake(320.0f, 418.0f)];
   }
   return self;
}


- (void)loadView {
   UIView *contentView;
   CGRect r = [[UIScreen mainScreen] applicationFrame];
   contentView = [[UIView alloc] initWithFrame: r];
   [self setView: contentView];
   [contentView setBackgroundColor: [UIColor colorWithRed: 0.934 green: 0.934 blue: 0.953 alpha: 1.0]];

   // Create a UISegmentedControl as a menu at the top of the screen
   NSArray *buttonNames = @[@"Clear", @"Cancel", @"Done"];
   menu = [[UISegmentedControl alloc] initWithItems: buttonNames];
   [menu setMomentary: YES];
   //[menu setSegmentedControlStyle: UISegmentedControlStyleBar];
   [menu setFrame: CGRectMake(0.0f, 0.0f, 300.0f, 20.0f)];
   [menu addTarget: self
            action: @selector(buttonPressed:)
         forControlEvents: UIControlEventValueChanged];
   [[self navigationItem] setTitleView: menu];
   
   BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

   // Selected piece view
   SelectedPieceView *spv;

   // I have no idea why, but the vertical view coordinates are different in
   // iOS 7 and iOS 8. We need to compensate for this to be able to handle both
   // OS versions correctly.
   BOOL isRunningiOS7 = [UIDevice currentDevice].systemVersion.floatValue < 8.0f;
   float sqSize;
   float dy = isIpad ? 50.0f : 64.0f;
   if (isIpad && isRunningiOS7) dy -= 34.0f;
   
   if (isIpad) {
      sqSize = 40.0f;
      spv = [[SelectedPieceView alloc] initWithFrame:CGRectMake(40.0f, 320.0f + dy, 240.0f, 80.0f)];
   } else {
      sqSize = [UIScreen mainScreen].applicationFrame.size.width / 8.0f;
      spv = [[SelectedPieceView alloc]
            initWithFrame:CGRectMake(40.0f, 8*sqSize + 74.0f, 6*sqSize, 2*sqSize)];
   }
   [contentView addSubview: spv];

   // Setup board view
   dy = isIpad ? 40.0f : 64.0f;
   if (isIpad && isRunningiOS7) dy -= 34.0f;
   boardView = [[SetupBoardView alloc]
         initWithController: self
         frame: CGRectMake(0.0f, dy, 8*sqSize, 8*sqSize)
         fen: fen
         phase: PHASE_EDIT_BOARD];
   [contentView addSubview: boardView];
   [boardView setSelectedPieceView: spv];

}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)buttonPressed:(id)sender {
   switch([sender selectedSegmentIndex]) {
   case 0:
      [boardView clear];
      break;
   case 1:
      [boardViewController editPositionCancelPressed];
      break;
   case 2:
      SideToMoveController *stmc = [[SideToMoveController alloc]
                                      initWithFen: [boardView fen]];
      [[self navigationController] pushViewController: stmc animated: YES];
      break;
   }
}


- (void)disableDoneButton {
   [menu setEnabled: NO forSegmentAtIndex: 2];
}


- (void)enableDoneButton {
   [menu setEnabled: YES forSegmentAtIndex: 2];
}




@end
