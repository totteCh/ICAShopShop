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



@interface ShoppingListDetailsViewController: UIViewController
@property(retain, nonatomic) ShoppingList *shoppingList;
@end

%hook ShoppingListDetailsViewController

- (void)viewDidLoad {
	if (self.shoppingList == nil && lastShoppingList != nil) {
		self.shoppingList = lastShoppingList;
	}
	%orig;
}

%end
