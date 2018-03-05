require "csv"
require "open-uri"
require "set"

module SHD
  class DiffAnalyzer
    attr_reader :head, :base, :report

    def initialize(head:, base:)
      @head = head
      @base = base
      @report = {
        columns:  {
          added:   [],
          removed: [],
        },
        stations: {
          added:   [],
          removed: [],
          changed: [],
        },
      }
    end

    def run
      all_ids               = Set.new
      all_columns           = Set.new
      stations_before       = fetch_stations(base)
      stations_after        = fetch_stations(head)
      stations_before_by_id = group_by_id(stations_before, all_ids)
      stations_after_by_id  = group_by_id(stations_after, all_ids)

      Logger.info "Analyzing the diff..."

      # Columns added/removed
      all_columns += stations_before.headers
      all_columns += stations_after.headers

      report[:columns][:added]   = stations_after.headers - stations_before.headers
      report[:columns][:removed] = stations_before.headers - stations_after.headers

      # Stations
      all_ids.each do |id|
        before = stations_before_by_id[id]
        after  = stations_after_by_id[id]

        # station was removed
        if before && !after
          report[:stations][:removed] << before
        # station was added
        elsif after && !before
          report[:stations][:added] << after
        # station was updated
        elsif before.to_s != after.to_s
          changeset = {}

          all_columns.each do |attribute|
            # Column removed? print nothing
            if report[:columns][:removed].include?(attribute)
              next
            end

            # Column added? report only if a value was supplied
            if report[:columns][:added].include?(attribute) && !after[attribute].nil? && !after[attribute].empty?
              changeset[attribute] = {
                before: "",
                after:  after[attribute],
              }
            # Otherwise, report only if different
            elsif before[attribute] != after[attribute]
              changeset[attribute] = {
                before: before[attribute],
                after:  after[attribute],
              }
            end
          end

          # Add common information for the reporting
          if changeset.any?
            changeset['id']    = after["id"]
            changeset['_name'] = after["name"]

            report[:stations][:changed] << changeset
          end
        end
      end

      report
    end

    private

    def fetch_stations(params)
      url = "https://raw.githubusercontent.com/#{params['repo']['full_name']}/#{params['sha']}/stations.csv"

      Logger.info "Fetching and parsing #{url} ..."

      raw = open(url).read
      CSV.parse(raw, CSV_PARAMETERS)
    end

    def group_by_id(stations, all_ids)
      stations.each_with_object({}) do |station, hash|
        hash[station["id"]] = station
        all_ids << station["id"]

        hash
      end
    end
  end
end
