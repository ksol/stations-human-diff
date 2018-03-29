module SHD
  class ReportFormatter
    attr_reader :report

    def self.run(report)
      new(report).run
    end

    def initialize(report)
      @report = report
    end

    def run
      Logger.info "Formatting the diff for pretty-printing..."

      strings = []

      if report[:columns][:added].any?
        strings << ":heavy_plus_sign: Columns added: #{format_columns(report[:columns][:added])}"
      end

      if report[:columns][:removed].any?
        strings << ":heavy_minus_sign: Columns removed: #{format_columns(report[:columns][:removed])}"
      end

      if report[:stations][:added].any?
        strings << "#### :heavy_plus_sign: Stations added"
        report[:stations][:added].each do |station|
          strings += format_station(station)
        end
      end

      if report[:stations][:removed].any?
        strings << "#### :heavy_minus_sign: Stations removed"

        report[:stations][:removed].each do |station|
          strings << "— **#{station['id']} – #{station['name']}**"
        end
      end

      if report[:stations][:changed].any?
        strings << "#### Stations changed"
        report[:stations][:changed].each { |changeset| strings += format_changeset(changeset) }
      end

      strings.join("\n")
    end

    ## Formatter helpers
    def format_columns(columns)
      columns.join(', ')
    end

    def format_station(station)
      relevant = station.to_hash.compact.reject do |k, v|
        %w(id name slug).include?(k) || v == "f"
      end

      strings = [
        "- **#{station['id']} – #{station['name']} (`#{station['slug']}`)**",
      ]

      relevant.each do |key, value|
        if %w(t f).include?(value)
          strings << "    - `#{key}` is #{bool_to_word(value)}"
        else
          strings << "    - `#{key}` is `#{value}`"
        end
      end

      strings
    end

    def format_changeset(changeset)
      strings = ["- **#{changeset['id']} – #{changeset['_name']}**"]

      changeset.each do |key, value|
        next if (key == "id") || (key == "_name")

        if value[:before].nil? || value[:before].empty?
          strings << "    - :heavy_plus_sign: `#{key}` was added, value is `#{value[:after]}`"
        elsif value[:after].nil? || value[:after].empty?
          strings << "    - :heavy_minus_sign: `#{key}` was removed, value was `#{value[:before]}`"
        elsif key.end_with?("_is_enabled")
          strings << "    - `#{key}` is now #{bool_to_word(value[:after])}"
        else
          strings << "    - `#{key}` was changed from `#{value[:before]}` to `#{value[:after]}`"
        end
      end

      strings
    end

    private

    def bool_to_word(column)
      column == "t" ? "enabled :white_check_mark:" : "disabled :x:"
    end
  end
end
