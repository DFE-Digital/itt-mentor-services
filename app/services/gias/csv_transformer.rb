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
        if row.header_row? || school_in_scope?(row)
          output_csv << row
        end
      end

      # Rewind the file so it's ready for reading
      output_file.rewind
      output_file
    end

    private

    attr_reader :input_file, :output_file

    # The 'School Placements' and 'Funding Mentors' services only need to know
    # about schools in England. Closed schools and those outside of England can
    # be filtered out from the CSV.
    def school_in_scope?(row)
      school = School.new(row)
      school.open? && school.in_england?
    end

    class School
      OPEN_SCHOOL = "1".freeze
      NON_ENGLISH_ESTABLISHMENTS = %w[8 10 25 24 26 27 29 30 32 37 49 56 57].freeze

      attr_reader :row

      def initialize(row)
        @row = row
      end

      def open?
        row.fetch("EstablishmentStatus (code)") == OPEN_SCHOOL
      end

      def in_england?
        !NON_ENGLISH_ESTABLISHMENTS.include? row.fetch("TypeOfEstablishment (code)")
      end
    end
  end
end
