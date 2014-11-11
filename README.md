Transform3DTest
===============

Test for CATransform3D in iOS 8. Seems like there's an issue when you try 3D transforming layers when in landscape mode beyond a certain threshold.

This test creates a full screen view controller and rotatable view. 

* Pan your finger left and right to see the view rotate. 
* Debug the view with Xcode to see printouts of the view frame, the layer, and the CATransform3D used.
* The view resets after 1 second, or will reset when you start a new pan.

To see the issue that I'm encountering, rotate the device to landscape mode, and then rotate the view toward you as if you were opening a door toward you. (Basically, touch down and slide your finger to the left). You'll notice that after a specific threshold, the view frames become essentially (-8.98847e+307 -8.98847e+307; 1.79769e+308 1.79769e+308), an unusable frame.
