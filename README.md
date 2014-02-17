# MPO Tools

## Synopsis
This gem provides some simple utility methods for working with MPO format 3D image files. This file format is used in 3D cameras such as the [Nintendo 3DS](http://en.wikipedia.org/wiki/Nintendo_3ds) and the [Fujifilm FinePix W3](http://en.wikipedia.org/wiki/Fujifilm_FinePix_Real_3D_W3). 

ImageMagick does not support this file type and, as a consequence, I found the format difficult to work with when I needed to process images in bulk (for example when creating 3D timelapses). This gem is intended to make that process easier.

The gem can be used to extract the EXIF data or the left and right images themselves from an MPO file. It can also be used to convert MPO files into a number of different (2D display friendly) viewing formats.

Supported output formats include:

| Name       | Format        | Description                                    |
| ---------- | ------------- | ---------------------------------------------- |
| Stereogram | `:stereo`     | left/right side by side                        |
| Cross-eyed | `:cross_eyed` | right/left side by side                        |
| Analglyph  | `:analglyph`  | red and blue (for use with coloured glasses)   |
| Wiggle GIF | `:wiggle`     | animated gif (cycles between left/right image) |

Also included is a binary for converting MPO files on the command line.

The mechanism for extracting the left and right images from the MPO is based on the exiftool usage example described in [this article](http://brainwagon.org/2009/11/04/fujifilm-real-3d-w1-camera/) by Mark VandeWettering.


## Install the gem

Install it with [RubyGems](https://rubygems.org)

```ruby
gem install mpo_tools
```

or add this to your Gemfile if you use [Bundler](http://gembundler.com)

```ruby
gem 'mpo_tools'
```

MPO Tools is dependent on [exiftool](http://www.sno.phy.queensu.ca/~phil/exiftool/), to install this on Ubuntu run

    sudo apt-get install libimage-exiftool-perl

## Getting Started

Here's an example of how you might convert a whole directory of MPO image files to analglyphs and resize them to 320x240 pixels.

```ruby
require 'mpo_tools'
path = '/home/bob/3d_pictures/*.MPO'
dest = '/home/bob/analglyphs/'
Dir.glob(path).each do |mpo|
  # path_to_mpo, output_path, format, scale/resolution
  MpoTools.convert mpo, dest, :analglyph, [320,240]
end
```

For information on how to use the command line tool run

    $ mpo_convert -h

For more information please take a look at the rdoc documentation.

## License
Copyright (c) 2014 Will Brown

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
