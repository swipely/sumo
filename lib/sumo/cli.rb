# This class is used to define a CLI.
class Sumo::CLI < Clamp::Command
  option ['-q', '--query'], 'QUERY', 'The query that will be sent to Sumo'
  option ['-f', '--from'], 'FROM', 'The start time of the query (iso8601).'
  option ['-t', '--to'], 'TO', 'The end time of the query (iso8601).'
  option ['-z', '--time-zone'], 'TZ', 'The time zone of the FROM and TO times.'
  option ['-e', '--extract-key'], 'KEY', 'The key to extract from the raw JSON.'
  option ['-r', '--records'], :flag, 'Extract records instead of messages.'
  option ['-v', '--version'], :flag, 'Print the version.'

  banner <<-EOS.gsub(/^\s+\|/, '')
    |Example
    |
    |Search for all of the logs containing 'HealthMetrics' on March 4, 2014,
    |extracting the 'message' key from the response:
    |
    |sumo --query HealthMetrics \\
    |     --from 2014-03-14T00:00:00 \\
    |     --to 2014-03-15T00:00:00 \\
    |     --time-zone EST \\
    |     --extract-key message
  EOS

  # This method is called when the CLI is run.
  def execute
    if version?
      $stdout.puts Sumo::VERSION
    elsif records?
      search.records.each { |record| $stdout.puts record }
    else
      search.messages.each { |msg| $stdout.puts format_message(msg['_raw']) }
    end
  rescue StandardError => ex
    $stderr.puts "#{ex.class}: #{ex.message}"
    exit 1
  end

  def format_message(raw)
    JSON.parse(raw)[extract_key] || raw
  rescue StandardError
    raw
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
