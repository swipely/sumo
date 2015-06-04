module Sumo
  # This class is used to un-paginate results from the API. Specifically, this
  # is currently used to page through records and messages returned by the API.
  class Collection
    include Enumerable
    include Error

    attr_reader :offset

    # Create a new collection.
    def initialize(hash = {})
      @offset = hash[:offset] || 0
      @get_values = hash[:get_values]
      @get_status = hash[:get_status]
      @count_key = hash[:count_key]
    end

    # Iterate through each member of the collection, lazily making HTTP requests
    # to get the next member. If no block is given, an `Enumerator` is returned.
    def each(&block)
      return enum_for(:each) if block.nil?
      page.each { |value| block.call(value) }
      remaining.each { |value| block.call(value) } if next_page?
      self
    end

    private

    def values(hash)
      @get_values.call(hash)
    end

    def status
      @status ||= load_status
    end

    def load_status
      stat = { 'state' => '', @count_key => @offset }
      until (@offset < stat[@count_key]) || stat['state'].start_with?('DONE')
        stat = @get_status.call
        sleep 1
      end
      stat
    end

    def total
      status[@count_key]
    end

    def state
      status['state']
    end

    def page
      @page ||= results? ? values(offset: offset, limit: limit) : []
    end

    def results?
      limit > 0
    end

    def limit
      @limit ||= begin
        natural_limit = total - offset
        (natural_limit <= 1000) ? natural_limit : 1000
      end
    end

    def next_page?
      ['GATHERING RESULTS', 'NOT STARTED'].include?(state)
    end

    def remaining
      @remaining ||= Collection.new(
        offset: offset + limit,
        get_values: @get_values,
        get_status: @get_status,
        count_key: @count_key
      )
    end
  end
end
