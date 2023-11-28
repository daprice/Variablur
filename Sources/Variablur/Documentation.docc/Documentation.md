# ``Variablur``

Apply variable blur effects to SwiftUI views.

## Overview

With Variablur, you can create variable blur effects that you control with a mask. Because you draw the mask using a `GraphicsContext`, it can contain gradients, shapes, text, pre-rendered images, or anything else you can draw into a `GraphicsContext`.

You can create gradient or progressive blurs, vignettes, "blur shadows", or many other effects.

![Example of a blurred snowflake background behind some demo UI.](ui-background-example)

To see live examples of some of the effects you can make, look at the Xcode Previews included in `View+variableBlur.swift`.

## Topics

### Applying variable blur to a view

- ``SwiftUI/View/variableBlur(radius:maxSampleCount:verticalPassFirst:maskRenderer:)``
- ``SwiftUI/View/variableBlur(radius:maxSampleCount:verticalPassFirst:mask:)``

### Applying variable blur as a VisualEffect

- ``SwiftUI/VisualEffect/variableBlur(radius:maxSampleCount:verticalPassFirst:mask:isEnabled:)``
