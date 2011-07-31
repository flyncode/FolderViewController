[original_blog]: http://iphone2020.wordpress.com/2011/02/17/ios-open-folder-animation/

# 1.  Introduction

This project came about as I was designing an iPad App, and wanted a control which would optionally let the user choose from a list of options, similar to the old-school ComboBox control.  Plus, I really really like the iOS folder animation.

I search Google to try to find something where someone else did most of the dirty work, and found [this blog post][original_blog], which was an enormous head-start.  I can't thank the original author, @icode2020, enough.

The coding style didn't fit my own, and there were some ideas of how I could try to improve on the original, so the first thing I did was refactor the existing code.  Then I did some more refactoring.  A little extending, a little refactoring.

# 2.  Usage

There are two main artifacts of this project: the FolderViewController and TabFolderViewController.  The different is in the "arrow" of the folder:  the FolderViewController uses the original iOS-style arrow, while the TabFolderViewController stretches the arrow out behind the activating control to create a "tab".

Both classes can be used one of two ways:  subclassing or delegation.  Subclassing is probably the easier of the two methods, and is demonstrated is the *FirstViewController* and *SecondViewController* objects in the sample project.  Delegation has it's own sample object, the *DelegateTestController*, but if you know how Cocoa-style delegation works, you probably won't need to.

Since you could have multiple controllers, each showing different content UIViews, the control that invoked the opening of the folder is passed as the "handle" to identify the content view.

The content of the folder view is requested by the same method, either in your subclass or in the delegate you provide:

	- (UIView*)folderView:(FolderViewController*)viewController needsContentForControl:(id)control;
	
The return value should be a UIView that is inserted into our folder, placed in the UI heirarchy, and animated into view.

# 3. Credits

Starting source code: [original_blog][]

Lined-paper texture: (~Dioma)[http://dioma.deviantart.com/art/Textures-Paper-58028330]