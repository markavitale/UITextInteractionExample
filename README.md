# UITextInteractionExample
A sample exploration of UITextInteraction

Licensed under the MIT License.

For an old Apple sample project that implements UITextInput, see [this link](https://developer.apple.com/library/archive/samplecode/SimpleTextInput/Introduction/Intro.html)

# UITextInteraction selection UI color isn't customizable, leads to low contrast UI

## SUMMARY
When using UITextInteraction to draw the selection of text, applications have no control over the color of the text selection UI. This means over certain background colors the text selection UI has extremely low contrast and is hard to see.

## STEPS TO REPRODUCE
1. Build and run this test app
2. Make a text selection on some of the text in the custom text label
3. Observer the color of the selection and the contrast against the background

## RESULTS
I would expect that the text selection UI would be visible on the text.
Since we are customizing the background color and foreground color, I would expect some ability to specify the color to use for the text selection UI.

A few potential approaches for supplying this customization:
- setting the tint color on the CustomTextLabel could apply that tint color to the text selection UI
- UITextInput could be extended to provide the desired text selection color for a given range of text.
- UITextInteractionDelegate could have a `func color(for textInteraction: UITextInteraction) -> UIColor` callback

## REGRESSION
I have written a UITextInteraction sample app to isolate this issue. Regardless of how the background color is set, I can find no way to modify the text selection ui color.As seen in this test app, when a custom text view has a blue color similar to that of the selection UI, the contrast is so low that it is almost unusable.

## NOTES
This affects Office's ability to use UITextInteraction, since the backgrounds of our documents, spreadsheet cells, slides, shapes, and more can be customized to a blue background color. The ability to detect these cases and provide text selection UI with sufficient contrast is necessary for our users. The issue is particularly bad since inserting shapes into Office documents by default result in blue shapes that have particularly low contrast.
