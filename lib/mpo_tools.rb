['pathname', 'json', 'RMagick'].each { |lib| require lib }

# Raised when the MPO file cannot be parsed or converted
class MpoError < StandardError; end

# The core library. This module provides methods for converting and extracing 
# data from MPO format 3D photographs. It uses imagemagick and exiftool to do
# this, so both libraries must be installed on your system for this code to work
module MpoTools

  # List of supported output formats
  FORMATS = [:stereo, :cross_eyed, :wiggle, :analglyph]

  # Convert the provided MPO file into the desired format
  # ==== Parameters
  # [source] The location of disk of the .mpo file
  # [destination] The desired output location of the new file (Optional)
  # [format] The desired output format. A list of valid formats can be found in
  #   the +FORMATS+ constant (Optional, defaults to :stereo)
  # [scale] The size of the outputted image. This can be provided as a scale
  #   with 1 representing the original size. Alternatively an array can be
  #   passed in with the format [x_size, y_size]
  #
  # ==== Returns
  # * The location on disk of the newly created output file.
  #
  # ==== Raises
  # * MpoError - Raised when the provided source file cannot be converted
  def self.convert(source, destination=nil, format=FORMATS.first, scale=1)
    raise MpoError.new "Invalid format: #{format}" if !FORMATS.include?(format)
    source, destination = validate_paths source, destination, format
    left, right = extract_images source
    left, right = scale_images left, right, scale unless scale == 1
    send "output_as_#{format}", left, right, destination
  end

  # Reads the source MPO file and returns a hash of exif data
  # ==== Parameters
  # [source] The location on disk of the .mpo file
  #
  # ==== Returns
  # * A ruby hash containing the file's exif meta data
  #
  # ==== Raises
  # * MpoError - Raised when exif data cannot be read from the source or when
  #     the exiftool application has not been installed
  def self.exif_data(source)
    exif = `exiftool -u -d "%Y-%m-%d %H:%M:%S" -json #{source}`
    return JSON.parse(exif).first
  rescue Errno::ENOENT => e
    raise MpoError.new "Please install 'exiftool' on your machine.\n  \"sudo apt-get install libimage-exiftool-perl\" on Ubuntu"
  rescue JSON::ParserError => e
    raise MpoError.new 'Unable to read exif data'
  end
  
  # Extracts two images from the MPO file
  # ==== Parameters
  # [source] The location on disk of the .mpo file
  #
  # ==== Returns
  # * The left eye image in +Magick::Image+ format
  # * The right eye image in +Magick::Image+ format
  #
  # ==== Raises
  # * MpoError - Raised when two images cannot be created based on the provided
  #     source file or when the exiftool application has not been installed
  def self.extract_images(source)
    left = Magick::Image.from_blob(`exiftool -trailer:all= #{source} -o -`)[0]
    right = Magick::Image.from_blob(`exiftool #{source} -mpimage2 -b`)[0]
    return left, right
  rescue Errno::ENOENT => e
    raise MpoError.new "Please install 'exiftool' on your machine.\n  \"sudo apt-get install libimage-exiftool-perl\" on Ubuntu"
  rescue Magick::ImageMagickError => e
    raise MpoError.new 'Unable to extract images'
  end

  private

  # Resizes both left and right images
  def self.scale_images left, right, scale
    if scale.is_a?(Array) && scale.length == 2
      return left.scale(*scale), right.scale(*scale)
    elsif scale.is_a?(Float) || scale.is_a?(Integer)
      return left.scale(scale), right.scale(scale)
    else
      raise MpoError.new 'Invalid scale'
    end
  end

  # Outputs the 3D image in stereo, left image on the left and right image
  # on the right
  def self.output_as_stereo(left, right, destination)
    destination = "#{destination}.jpg" unless destination =~ /.jpg$/i
    Magick::ImageList.new.push(left, right).append(false).write(destination)
    return destination
  end

  # Creates a reversed stereo image, which can be viewed by going cross-eyed
  def self.output_as_cross_eyed(left, right, destination)
    output_as_stereo right, left, destination
  end

  # Outputs as an analglyph that can be viewed with coloured glasses
  def self.output_as_analglyph(left, right, destination)
    destination = "#{destination}.jpg" unless destination =~ /.jpg$/i
    left.stereo(right).write(destination)
    return destination
  end

  # Outputs as a 'wiggle' gif. An animated gif that rapidly cycles between
  # left and right image
  def self.output_as_wiggle(left, right, destination)
    destination = "#{destination}.gif" unless destination =~ /.gif$/i
    gif = Magick::ImageList.new.push(left, right)
    gif.delay = 5
    gif.write(destination)
    return destination
  end

  # Validates the provided source and destination paths, builds the destination
  # path if a full file path has not been provided
  def self.validate_paths(source, destination, format)
    raise MpoError.new('Source not an mpo') unless source =~ /\.mpo$/i
    raise MpoError.new('Source not found') unless File.exists?(source)
    source = Pathname.new(source)
    if destination && File.directory?(destination)
      source_name = source.basename.to_s.gsub(/\.mpo$/, '')
      destination = Pathname.new(destination) + "#{source_name}_#{format}"
    elsif destination
      destination = Pathname.new(destination)
    else
      stripped_source = source.realpath.to_s.gsub(/\.mpo$/, '')
      destination = Pathname.new(stripped_source + "_#{format}")
    end
    return source.realpath.to_s, destination.to_s
  end
end
