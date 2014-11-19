Transform3DTest
===============

Test for CATransform3D in iOS 8. Seems like there's an issue when you try 3D transforming layers when in landscape mode beyond a certain threshold.

This test creates a full screen view controller and rotatable view. 

* Pan your finger left and right to see the view rotate. 
* Debug the view with Xcode to see printouts of the view frame, the layer, and the CATransform3D used.
* The view resets after 1 second, or will reset when you start a new pan.

To see the issue that I'm encountering, rotate the device to landscape mode, and then rotate the view toward you as if you were opening a door toward you. (Basically, touch down and slide your finger to the left). You'll notice that after a specific threshold, the view frames become essentially (-8.98847e+307 -8.98847e+307; 1.79769e+308 1.79769e+308), an unusable frame.


Note: I received a response from a great Apple Engineer with explanation of why this problem happens:
===============

This is intended behavior. The full explanation is quite technical and touches homogenous coordinates, triangles clipping done by GPU in clip space and external triangles, so instead I’ll
try to convince you using the log of rotationView’s frame when the layer is approaching the “infinite frame” angle:

2014-11-18 14:41:16.249 Transform3DTest[6698:693721] view: <UIView: 0x174198460; frame = (0 -16134.9; 26563.6 32644.8); 
2014-11-18 14:41:16.333 Transform3DTest[6698:693721] view: <UIView: 0x174198460; frame = (0 -19554; 31882.5 39483); 
2014-11-18 14:41:16.416 Transform3DTest[6698:693721] view: <UIView: 0x174198460; frame = (0 -24734.4; 39938.3 49843.9); 
2014-11-18 14:41:16.482 Transform3DTest[6698:693721] view: <UIView: 0x174198460; frame = (0 -33508; 53577.6 67391); 
2014-11-18 14:41:16.549 Transform3DTest[6698:693721] view: <UIView: 0x174198460; frame = (0 -51594.8; 81688.8 103565);
2014-11-18 14:41:16.616 Transform3DTest[6698:693721] view: <UIView: 0x174198460; frame = (0 -110584; 173358 221542); 
2014-11-18 14:41:16.683 Transform3DTest[6698:693721] view: <UIView: 0x174198460; frame = (-8.98847e+307 -8.98847e+307; 1.79769e+308 1.79769e+308); 

Before the threshold both the width and height of layer’s frame (which is a bounding box of all its corners) are extremely large. When you go past the threshold the frame is essential bogus, as the 4D triangle wraps around in 3D space. You can’t see that on the display, because GPU does the clipping to what essential can be displayed, but we give you full frame which past the threshold is basically infinite. If you’re interested in the details of what goes wrong here’s a nice overview:

http://www.gamasutra.com/view/news/168577/Indepth_Software_rasterizer_and_triangle_clipping.php

Why did your code work fine on iPhone 4S? Because the layer size is smaller than on iPhone 6 and it didn’t shoot out to infinity. When you make M34_PERSPECTIVE_DIVISOR equal to 20 you’ll see exactly the same problems on 4S. My advice is to simply increase the value of M34_PERSPECTIVE_DIVISOR for your iPhone 6 code (or for both devices). It will make the perspective look less “perspective’y”, but this exactly what you want in this case, as this will prevent the layer from shooting into infinity.

Thank you for making a great test project, it was really nicely done and made looking into the problem much easier!

Bartosz Ciechanowski
