# LMViews
LMViews is a set of IBDesignable UIView subclasses with IBInspectable properties for commonly used features, like rounded corners, borders or shadows.
I'll be adding more features as I need them.

# LMPageViewController
There is no easy way to set the pages of a page vc in storyboard. 
LMPageViewController attempts to solve this (or at least to make it easier to add pages).
You can set the ids of the view controllers you want as pages with the Page Ids property. Use commas to add more, but make sure you don't use spaces.
Also set the Storyboard Name property to the name of the storyboard where you have the pages.