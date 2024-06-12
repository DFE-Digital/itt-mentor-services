module Gias
  class CsvTransformer
    include ServicePattern

    def initialize(input_file)
      @input_file = input_file
      @output_file = Tempfile.new
    end

    def call
      output_csv = CSV.new(output_file)

      CSV.new(input_file, headers: true, return_headers: true).each do |row|
        if row.header_row?
          output_csv << header_row(row)
        elsif school_in_scope?(row)
          output_csv << school_row(row)
        end
      end

      # Close the IO handle to the cs2cs process
      coordinate_transformer.close

      # Rewind the file so it's ready for reading
      output_file.rewind
      output_file
    end

    private

    attr_reader :input_file, :output_file

    def header_row(row)
      row.headers + %w[Latitude Longitude]
    end

    def school_row(row)
      coordinates = coordinate_transformer.transform(
        easting: row.fetch("Easting"),
        northing: row.fetch("Northing"),
      )

      row.fields + [coordinates[:latitude], coordinates[:longitude]]
    end

    def coordinate_transformer
      @coordinate_transformer ||= CoordinateTransformer.new
    end

    # The 'School Placements' and 'Funding Mentors' services only need to know
    # about schools in England. Closed schools and those outside of England can
    # be filtered out from the CSV.
    def school_in_scope?(row)
      school = School.new(row)
      school.open? && school.in_england?
    end

    class School
      # Code | EstablishmentStatus
      # 1    | Open
      # 3    | Open, but proposed to close
      OPEN_SCHOOL_CODES = %w[1 3].freeze
      # Code | Establishment type
      # 25   | Offshore schools
      # 30   | Welsh establishment
      # 37   | British schools overseas
      NON_ENGLISH_ESTABLISHMENTS = %w[25 30 37].freeze

      attr_reader :row

      def initialize(row)
        @row = row
      end

      def open?
        OPEN_SCHOOL_CODES.include? row.fetch("EstablishmentStatus (code)")
      end

      def in_england?
        !NON_ENGLISH_ESTABLISHMENTS.include? row.fetch("TypeOfEstablishment (code)")
      end
    end

    class CoordinateTransformer
      # GIAS provides coordinates in British National Grid Easting/Northing format.
      # https://epsg.io/27700
      SOURCE_CRS = "EPSG:27700".freeze

      # We need coordinates in WGS84 format, the standard Latitude/Longitude
      # coordinate system used in GPS and online mapping tools.
      # https://epsg.io/4326
      TARGET_CRS = "EPSG:4326".freeze

      attr_reader :cs2cs

      delegate :close, to: :cs2cs

      def initialize
        # cs2cs is provided as part of the PROJ library
        # Mac: brew install proj
        # Linux (Debian): apt-get install proj-bin
        # Usage: https://proj.org/en/9.4/apps/cs2cs.html
        @cs2cs = IO.popen(["cs2cs", "-d", "10", SOURCE_CRS, TARGET_CRS], "r+")
      end

      def transform(easting:, northing:)
        cs2cs.write "#{easting} #{northing}\n"
        output = cs2cs.gets.split(" ")
        { latitude: output[0], longitude: output[1] }
      end
    end
  end
end
