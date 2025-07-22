package {

    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;

    public class SWFToSpriteSheetExporter extends MovieClip {

        // Path where output PNG and JSON will be saved
        private static const PATH:String = "C:/Users/Hyoizab/Test UI 3/Assets/Resources/Body/";

        // Public reference to the MovieClip containing avatar parts (assumed to be set in the FLA)
        public var avatar:MovieClip;

        public function TestSWFToSpriteSheet() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            reorderChildren(avatar, 50, 2048);

            const parts:Array = []; // Array to store metadata for each part

            var totalWidth:Number = 0;
            var totalHeight:Number = 0;

            for (var j:int = 0; j < avatar.numChildren; j++) {
                var currentChild:DisplayObject = avatar.getChildAt(j);

                // Calculate anchor point for pivot
                var pivot:Point = getAnchorPoint(currentChild)

                trace(pivot.x, pivot.y, currentChild.name);

                parts.push({
                    linkage: currentChild.name,
                    x: currentChild.x,
                    y: currentChild.y,
                    w: currentChild.width,
                    h: currentChild.height,
                    x_pivot: pivot.x,
                    y_pivot: pivot.y
                });

                // Update total size needed for sprite sheet
                totalWidth = Math.max(totalWidth, currentChild.x + currentChild.width);
                totalHeight = Math.max(totalHeight, currentChild.y + currentChild.height);
            }

            totalWidth = getNextPowerOfTwo(totalWidth);
            totalHeight = getNextPowerOfTwo(totalHeight);

            const spriteSheetBitmapData:BitmapData = new BitmapData(totalWidth, totalHeight, true, 0x00000000);
            spriteSheetBitmapData.draw(avatar); // Render avatar to bitmap

            saveImage(spriteSheetBitmapData);
            saveJson(parts, spriteSheetBitmapData);
        }

        private function saveJson(parts:Array, spriteSheetBitmapData:BitmapData):void {
            const jsonFile:File = new File(PATH + "Human.json");
            const jsonStream:FileStream = new FileStream();

            jsonStream.open(jsonFile, FileMode.WRITE);
            jsonStream.writeUTFBytes(JSON.stringify({
                meta: {
                    w: spriteSheetBitmapData.width,
                    h: spriteSheetBitmapData.height
                },
                parts: parts
            }, null, 2));

            jsonStream.close();

            trace("Sprite sheet data saved successfully");
        }

        // Save the rendered sprite sheet as a PNG image
        private function saveImage(spriteSheetBitmapData:BitmapData):void {
            const pngFile:File = new File(PATH + "Human.png");
            const pngStream:FileStream = new FileStream();
            pngStream.open(pngFile, FileMode.WRITE);

            const pngBytes:ByteArray = PNGEncoder.encode(spriteSheetBitmapData);
            pngStream.writeBytes(pngBytes);
            pngStream.close();

            trace("Sprite sheet image saved successfully");
        }

        // Reorders and lays out children within a container to fit in a texture atlas grid
        private function reorderChildren(container:DisplayObjectContainer, padding:Number, maxWidth:Number):void {
            var sortedChildren:Array = [];

            // Copy all children into a new array for sorting
            for (var i:int = 0; i < container.numChildren; i++) {
                sortedChildren.push(container.getChildAt(i));
            }

            // Sort children by height descending, then width
            sortedChildren.sort(function (a:DisplayObject, b:DisplayObject):int {
                var boundsA:Rectangle = a.getBounds(a.parent);
                var boundsB:Rectangle = b.getBounds(b.parent);

                if (boundsA.height != boundsB.height) {
                    return boundsB.height - boundsA.height;
                } else {
                    return boundsB.width - boundsA.width;
                }
            });

            // Layout children in a grid-like structure with padding
            var currentX:Number = padding;
            var currentY:Number = padding;
            var currentLineHeight:Number = 0;

            for (var j:int = 0; j < sortedChildren.length; j++) {
                var child:DisplayObject = sortedChildren[j];
                var pivot:Point = getAnchorPoint(child);

                // Wrap to next row if current width exceeds max
                if (currentX + child.width > maxWidth) {
                    currentX = padding;
                    currentY += currentLineHeight + padding;
                    currentLineHeight = 0;
                }

                // Position child relative to anchor point
                child.x = currentX + pivot.x;
                child.y = currentY + pivot.y;

                // Advance current X position for next child
                currentX += child.width + padding;
                if (child.height > currentLineHeight) {
                    currentLineHeight = child.height;
                }
            }
        }

        // Utility function to return the next power of two for texture dimensions
        private function getNextPowerOfTwo(value:Number):int {
            var power:int = 1;

            while (power < value) {
                power *= 2;
            }

            return power;
        }

        // Calculates the pivot (anchor point) for a DisplayObject
        private function getAnchorPoint(o:DisplayObject):Point {
            const p:DisplayObject = o.parent;
            const onStage:Boolean = o.stage != null;

            // Temporarily add to stage if not already added, to calculate bounds
            if (!onStage) {
                stage.addChild(o);
            }

            const res:Point = new Point();
            const rect:Rectangle = o.getRect(o); // Get bounds in its own coordinate space

            res.x = -1 * rect.x; // Anchor is the negative top-left corner
            res.y = -1 * rect.y;

            // Remove from stage if it was temporarily added
            if (!onStage) {
                stage.removeChild(o);

                if (p) {
                    MovieClip(p).addChild(o); // Reattach to original parent
                }
            }

            return res;
        }

    }

}
