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
#import "CastleRightsController.h"
#import "EpSquareController.h"
#import "SetupBoardView.h"
#import "SetupViewController.h"
#import "SideToMoveController.h"


@implementation SideToMoveController

- (id)initWithFen:(NSString *)aFen {
   if (self = [super init]) {
      fen = aFen;
      [self setPreferredContentSize: CGSizeMake(320.0f, 418.0f)];
   }
   return self;
}

- (void)loadView {
   UIView *contentView;
   CGRect r = [[UIScreen mainScreen] applicationFrame];
   [self setTitle: @"Side to move"];
   contentView = [[UIView alloc] initWithFrame: r];
   [self setView: contentView];
   [contentView setBackgroundColor: [UIColor colorWithRed: 0.934 green: 0.934 blue: 0.953 alpha: 1.0]];

   // [self setTitle: @"Side to move"];
   [[self navigationItem]
      setRightBarButtonItem: [[UIBarButtonItem alloc]
                                 initWithTitle: @"Done"
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(donePressed)]];

   BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
   BOOL isRunningiOS7 = [UIDevice currentDevice].systemVersion.floatValue < 8.0f;
   float sqSize = isIpad ? 40.0f : [UIScreen mainScreen].applicationFrame.size.width / 8.0f;
   CGRect frame;

   if (!isIpad) {
      frame = CGRectMake(0.0f, 64.0f, 8 * sqSize, 8 * sqSize);
   } else if (isRunningiOS7) {
      frame = CGRectMake(0.0f, 0.0f, 8 * sqSize, 8 * sqSize);
   } else {
      frame = CGRectMake(0.0f, 40.0f, 8 * sqSize, 8 * sqSize);
   }
   boardView = [[SetupBoardView alloc]
         initWithController: self
                      frame: frame
                        fen: fen
                      phase: PHASE_EDIT_STM];
   [contentView addSubview: boardView];

   // UISegmentedControl for picking side to move
   if (!isIpad) {
      frame = CGRectMake(20.0f, 8 * sqSize + 89.0f, 8 * sqSize - 40.0f, 50.0f);
   }  else if (isRunningiOS7) {
      frame = CGRectMake(20.0f, 340.0f, 280.0f, 50.0f);
   } else {
      frame = CGRectMake(20.0f, 380.0f, 280.0f, 50.0f);
   }
   NSArray *buttonNames = @[@"White to move", @"Black to move"];
   segmentedControl =
      [[UISegmentedControl alloc] initWithItems: buttonNames];
   segmentedControl.frame = frame;
   if ([boardView whiteIsInCheck]) {
      [segmentedControl setSelectedSegmentIndex: 0];
      [segmentedControl setEnabled: NO forSegmentAtIndex: 1];
   }
   else if ([boardView blackIsInCheck]) {
      [segmentedControl setSelectedSegmentIndex: 1];
      [segmentedControl setEnabled: NO forSegmentAtIndex: 0];
   }
   else [segmentedControl setSelectedSegmentIndex: -1];
   //[segmentedControl setSegmentedControlStyle: UISegmentedControlStylePlain];
   [contentView addSubview: segmentedControl];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)donePressed {
   NSLog(@"Done");
   if ([segmentedControl selectedSegmentIndex] == -1)
      [[[UIAlertView alloc] initWithTitle: @"Please select side to move!"
                                   message: @""
                                  delegate: self
                         cancelButtonTitle: nil
                         otherButtonTitles: @"OK", nil]
         show];
   else {
      if ([[boardView maybeCastleString] isEqualToString: @"-"]) {
         Square sqs[8];
         int i;
         i = [boardView epCandidateSquaresForColor:
                           (Color)[segmentedControl selectedSegmentIndex]
                                           toArray: sqs];
         if (i == 0) {
            BoardViewController *bvc =
               [(SetupViewController *)
                     [[self navigationController] viewControllers][0]
                  boardViewController];
            [bvc editPositionDonePressed:
                    [NSString stringWithFormat: @"%@%c %@ -",
                              [boardView boardString],
                              (([segmentedControl selectedSegmentIndex] == 0)?
                               'w' : 'b'),
                              [boardView maybeCastleString]]];
         }
         else {
            EpSquareController *epc =
               [[EpSquareController alloc]
                  initWithFen: [NSString stringWithFormat: @"%@%c %@ -",
                                         [boardView boardString],
                                         (([segmentedControl selectedSegmentIndex] == 0)? 'w' : 'b'),
                                         [boardView maybeCastleString]]];
            [[self navigationController] pushViewController: epc animated: YES];
         }
      }
      else {
         CastleRightsController *crc =
            [[CastleRightsController alloc]
               initWithFen: [NSString stringWithFormat: @"%@%c %@ -",
                                      [boardView boardString],
                                      (([segmentedControl selectedSegmentIndex] == 0)? 'w' : 'b'),
                                      [boardView maybeCastleString]]];
         [[self navigationController] pushViewController: crc animated: YES];
      }
   }
}




@end
