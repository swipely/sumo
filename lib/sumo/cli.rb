# This class is used to define a CLI.
class Sumo::CLI < Clamp::Command
  option ['-q', '--query'], 'QUERY', 'The query that will be sent to Sumo'
  option ['-f', '--from'], 'FROM', 'The start time of the query (iso8601).'
  option ['-t', '--to'], 'TO', 'The end time of the query (iso8601).'
  option ['-z', '--time-zone'], 'TZ', 'The time zone of the FROM and TO times.'
  option ['-e', '--extract-key'], 'KEY', 'The key to extract from the raw JSON.'
  option ['-r', '--records'], :flag, 'Extract records instead of messages.'
  option ['-v', '--version'], :flag, 'Print the version.'

  # This method is called when the CLI is run.
  def execute
    if version?
      puts Sumo::VERSION
    elsif records?
      search.records.each { |record| puts record }
    else
      search.messages.each { |message| puts format_message(message) }
    end
  rescue StandardError => ex
    puts "#{ex.class}: #{ex.message}"
    exit 1
  end

  def format_message(message)
    if extract_key.nil?
      message['_raw']
    else
      JSON.parse(message['_raw'])[extract_key]
    end
  end
  private :format_message

  def search
    Sumo::Search.create(
      :query => query,
      :from => from,
      :to => to,
      :time_zone => time_zone
    )
  end
  private :search
end
