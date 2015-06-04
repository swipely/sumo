# This class is used to un-paginate results from the API. Specifically, this
# is currently used to page through records and messages returned by the API.
class Sumo::Collection
  include Enumerable
  include Sumo::Error

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
    remaining.each { |value| block.call(value) } if has_next_page?
    self
  end

  def values(hash)
    @get_values.call(hash)
  end
  private :values

  def status
    @status ||= get_new_status
  end
  private :status

  def get_new_status
    stat = { 'state' => '', @count_key => @offset }
    until (@offset < stat[@count_key]) || stat['state'].start_with?('DONE')
      stat = @get_status.call
      sleep 1
    end
    stat
  end
  private :get_new_status

  def total
    status[@count_key]
  end
  private :total

  def state
    status['state']
  end
  private :state

  def page
    @page ||= has_results? ? values(offset: offset, limit: limit) : []
  end
  private :page

  def has_results?
    limit > 0
  end
  private :has_results?

  def limit
    @limit ||= begin
      natural_limit = total - offset
      (natural_limit <= 1000) ? natural_limit : 1000
    end
  end
  private :limit

  def has_next_page?
    ['GATHERING RESULTS', 'NOT STARTED'].include?(state)
  end
  private :has_next_page?

  def remaining
    @remaining ||= Sumo::Collection.new(
      offset: offset + limit,
      get_values: @get_values,
      get_status: @get_status,
      count_key: @count_key
    )
  end
  private :remaining
end
