## GeoTag for macOS -- macOS 14 or later

GeoTag is a free OS X single window application that allows you to update image
metadata with geolocation tags by selecting one or more images then panning and
zooming within a a map to the place the image was recorded. Clicking on the map
will add the location to the selected photos.  Clicking on a new location will
change the geolocation for the selected photos.  Zoom in on the map and fine
tune the location with a click.  The built in ExifTool utility is used to write
location data to the images when you save your changes.  ExifTool only modifies
image metadata -- your image pixels are not touched.

See <http://exiftool.org> for information about ExifTool.
**ExifTool is built in to GeoTag.**

GeoTag 5.2+ requires macOS Sonoma or later.  Use GeoTag 5.1 if running on
macOS Ventura.  Those running earlier versions of macOS can use GeoTag
version 4.15.

**NOTE**:

There is a map pin location issue when running on early versions of macOS
Sonoma. If you see a pin placed above the point you clicked/tapped you are
seeing this bug. Apple fixed the issue in version 14.4 (or perhaps it was
14.4.1). It is not a problem in the current version of Sonoma.

## GeoTag WIP

### Updates

- Pin view options now available in the Map context menu in addition to the
  View menu.
- Internal changes to meet Swift 6 strict concurrency requirements

### Bug Fixes

- If multiple GPX track logs contained timestamps within 6 hours of an image
  timestamp the image might have been assigned an incorrect location when
  the "Locn from track" function was used.

### See the file named *History* for earlier changes and bug fixes

---

### Operating Instructions:

*See <https://www.snafu.org/GeoTag/GeoTag5Help/> for more information.*

Run Program.  Use the Open command from the menu or ⌘O to select files to
modify. You can also drag files from the finder into the table on the left side
of the application window.  Or you may select images from your Photos
Library. File names shown in a light grey color are not recognized as valid
image files or are disabled for other reasons.  Such files can not be
modified. Dragging or opening a folder will add all the files in the folder
and any subfolders.

Select one or more images. When selecting multiple images one of the
images is considered the "most selected". The name of the most selected
image is shown in yellow using a bolder font.  The thumbnail of the most
selected image is displayed in the image well (upper right portion of the
window). Its location (if any) is marked on the map.

Click on the map to set or change the location of all selected images. Existing
location can be changed by clicking on the desired location. Hitting the delete
key will remove location information from all selected images.  You can
Undo/Redo image location changes.

Double click the map to zoom in. Option-double click to zoom out. Or use
pinch gestures to zoom in and out if using a touch pad.

Five map styles --- Standard, Imagery, Hybrid, Standard with traffic, and
Hybrid with traffic --- are supported. Right click on the map to select
the desired map style. If you find yourself working in a specific area of a
map you can save the location and zoom level by right clicking on the map
and selecting *Save map location*.  When GeoTag is launched the map will
load to the last saved location using the last map style selected.

You may cut or copy location information from a single image and then paste
that information into one or more images.  If you make an error you can
undo/redo your changes. You can undo all changes to all images by selecting
"Discard changes" from the "File" menu.  All Undo/Redo information is cleared
once changes are discarded or saved.

The original versions of images that have been updated are saved are in a
backup folder.  The backup folder may be changed using GeoTag Settings.
The first time GeoTag is run it will prompt you to select a backup folder.
Images updates can not be saved until a backup folder is selected or backups
are disabled (not recommended).

Cut, Copy, Paste, Delete, and Clear Image List can be accessed from
a pop up menu by right clicking on an entry in the list.

### Build Instructions for developers

* Get current sources from github -- https://github.com/marchyman/GeoTag
* Open the project in Xcode
* ⌘R will build and run, ⌘B to build only

Send all comments, bugs, requests, etc. to <marc@snafu.org>
