require 'mpo_tools'

describe MpoTools do
  before :all do
    path = Pathname.new(__FILE__).realpath.parent + 'example_data' + 'sample.mpo'
    @source = path.realpath.to_s
    @destination = '/tmp/'
  end

  describe '.convert' do
    
    context 'format is :stereo' do
      it 'exports a jpg image' do
        output_file = MpoTools.convert @source, @destination, :stereo, 1
        img = Magick::Image.read(output_file).first
        x_size, y_size = img.columns, img.rows
        exif = MpoTools.exif_data @source
        x_size.should eq(exif['ImageWidth']*2)
        y_size.should eq(exif['ImageHeight'])
        FileUtils.rm output_file if File.exists?(output_file)
      end
    end
    
    context 'format is :cross_eyed' do
      it 'exports a jpg image' do
        output_file = MpoTools.convert @source, @destination, :cross_eyed, 1
        img = Magick::Image.read(output_file).first
        x_size, y_size = img.columns, img.rows
        exif = MpoTools.exif_data @source
        x_size.should eq(exif['ImageWidth']*2)
        y_size.should eq(exif['ImageHeight'])
        FileUtils.rm output_file if File.exists?(output_file)
      end
    end
    
    context 'format is :analglyph' do
      it 'exports a jpg image' do
        output_file = MpoTools.convert @source, @destination, :analglyph, 1
        img = Magick::Image.read(output_file).first
        x_size, y_size = img.columns, img.rows
        exif = MpoTools.exif_data @source
        x_size.should eq(exif['ImageWidth'])
        y_size.should eq(exif['ImageHeight'])
        FileUtils.rm output_file if File.exists?(output_file)
      end
    end
    
    context 'format is :wiggle' do
      it 'exports a gif image' do
        output_file = MpoTools.convert @source, @destination, :wiggle, 1
        img = Magick::Image.read(output_file).first
        x_size, y_size = img.columns, img.rows
        exif = MpoTools.exif_data @source
        x_size.should eq(exif['ImageWidth'])
        y_size.should eq(exif['ImageHeight'])
        FileUtils.rm output_file if File.exists?(output_file)
      end
    end
    
    context 'scale is .5' do
      it 'exports an image 50% of the size of the original' do
        output_file = MpoTools.convert @source, @destination, :stereo, 0.5
        img = Magick::Image.read(output_file).first
        x_size, y_size = img.columns, img.rows
        exif = MpoTools.exif_data @source
        x_size.should eq(exif['ImageWidth'])
        y_size.should eq(exif['ImageHeight']/2)
        FileUtils.rm output_file if File.exists?(output_file)
      end
    end
    
    context 'scale is [640,480]' do
      it 'exports an image with a resolution of 640x480' do
        output_file = MpoTools.convert @source, @destination, :stereo, [640,480]
        img = Magick::Image.read(output_file).first
        x_size, y_size = img.columns, img.rows
        x_size.should eq(1280)
        y_size.should eq(480)
        FileUtils.rm output_file if File.exists?(output_file)
      end
    end

  end

  describe '.exif_data' do
    it 'correctly interprets the EXIF data of .mpo files' do
      exif = MpoTools.exif_data @source
      exif["ImageWidth"].should eq(640)
      exif["ImageHeight"].should eq(480)
      exif["ColorSpace"].should eq("sRGB")
      exif["NumberOfImages"].should eq(2)
    end
  end
  
  describe '.extract_images' do
    it 'returns two RMagick::Image objects' do
      left, right = MpoTools.extract_images @source
      left.should be_a(Magick::Image)
      right.should be_a(Magick::Image)
    end
  end

end
