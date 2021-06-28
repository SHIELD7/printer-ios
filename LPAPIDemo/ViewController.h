#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView      *backgroundView;
//@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;


- (IBAction)scanPrinters:(id)sender;
- (IBAction)createLabel:(id)sender;
- (IBAction)printLabel:(id)sender;
- (IBAction)closePrinter:(id)sender;

@end
