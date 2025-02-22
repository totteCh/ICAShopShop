#import <CoreData/CoreData.h>



// prevent popular recipe categories from loading
%hook RecipePuffsController

- (void)fetchDataIncludingImages:(BOOL)arg1 {}
- (void)fetchData {}

%end



%hook RecipesViewController

- (id)createActivityIndicatorView {
	UIActivityIndicatorView *activityIndicator = %orig;
	activityIndicator.alpha = 0; // hide loading indicator
	return activityIndicator;
}

%end



@interface MenuItemsController: UITableViewController
@end

%hook MenuItemsController

- (void)loadInitialData {
	%orig;

	// show list of shopping lists
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
		});
	});
}

%end



// disable menu offers carousel
%hook MenuOffersPageViewController

- (void)setCarouselItemsArray:(NSArray *)carouselItemsArray {}

%end



// push down placeholder image to make status bar readable
@interface MenuOffersView : UIView
@end

%hook MenuOffersView

- (void)styleMenuOffersView:(id)arg1 {
	%orig;

	CGRect frame = self.frame;
	frame.size.height += 20;
	self.frame = frame;

	NSLayoutConstraint *imageXConstraint = (NSLayoutConstraint *)self.constraints[3];
	imageXConstraint.constant = 20;

	self.backgroundColor = [UIColor colorWithRed:0.937 green:0.173 blue:0.114 alpha:0.85];
}

%end



@interface ShoppingList: NSManagedObject
@end

ShoppingList *lastShoppingList;



@interface ShoppingListsViewController: UITableViewController
@end

%hook ShoppingListsViewController

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	%orig;

	if (lastShoppingList == nil && controller.fetchedObjects.count > 0) {
		ShoppingList *shoppingList = controller.fetchedObjects[0];
		lastShoppingList = shoppingList;
		[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	}
}

%end



@interface ShoppingListDetailsHeaderViewController: UIViewController
@property(weak, nonatomic) UIToolbar *toolbar;
@end

@interface ShoppingListDetailsViewController: UIViewController
@property(retain, nonatomic) ShoppingList *shoppingList;
@property(retain, nonatomic) UIView *tableHeaderView;
@property(retain, nonatomic) ShoppingListDetailsHeaderViewController *headerViewController;
@end

%hook ShoppingListDetailsViewController

- (void)viewDidLoad {
	if (self.shoppingList == nil && lastShoppingList != nil) {
		self.shoppingList = lastShoppingList;
	}
	%orig;
}

- (void)showHeaderViewIfNeeded {
	%orig;

	// hide "Add a recipe" button
	NSLayoutConstraint *heightConstraint = self.tableHeaderView.constraints[0];
	heightConstraint.constant = self.headerViewController.toolbar.frame.size.height;
}

%end



// disable Estimote beacon fetching
%hook ESTRequestManager

- (void)sendRequests {
	%log;
}

%end
