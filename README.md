# UITextInteractionExample
A sample exploration of UITextInteraction

Licensed under the MIT License.

For an old Apple sample project that implements UITextInput, see [this link](https://developer.apple.com/library/archive/samplecode/SimpleTextInput/Introduction/Intro.html)

# UITextInteraction doesn't handle rotated text

## SUMMARY
UITextInteraction doesn't have any way of handling rotated text for drawing text selection UI. 

## STEPS TO REPRODUCE
1. Build and run this test app
2. Observe the rotated text drawn
3. Interact with the text, first setting the caret
4. Next make a selection (double tapping on a line of text)

## RESULTS
Note that the caret is rendered as a circle and not as a straight line. We would expect some way to indicate the angle of the text and have the caret draw as a straight thin line.

Note that selection rects are not rotated alongside the text and instead are unrotated rectangles that contain the full word. We would expect a way to have the selection rectangle draw along the same angle of the text and look almost identical to regular text, just rotated.

We need some way to specify that the text itself is drawn rotated without actually applying a rotation transform on the view itself.

FYI: There are some slight issues with the UITextInput implementation of this rotated text and the geometry related UITextInput methods aren't perfect in this test app, but they are close enough to demonstrate the issues. Within Office, we're able to reproduce the issues more perfectly with our text in rotated shapes that conform to UITextInput.

## REGRESSION
We've isolated the UITextInteraction into this sample application and are unable to find any APIs that would allow us to achieve the expected behavior of a text selection and UI that are rotated along with the text that is drawn rotated.

## NOTES
We also tested purely rotating the custom text label view after it had been created in the correct coordinate space. This worked as expected for the selection drawing but did have an unexpected square/rectangular pointer shape as opposed to the expected beam shape when using a pointer device.

Unfortunately, even if we could work around the pointer shape issue, it's not feasible to rewrite Office's text rendering engine to apply CGTransforms to our custom text layers after the fact as opposed to drawing the text pre-rotated. 
