class Runner
  attr_accessor :options, :register, :times_to_run, :total, :original_command_line
  def initialize
    @options = {
      verbose: false,
      summary: true,
      num_threads: 3,
      csv: true,
      results_file: "amd_tuning.csv",
      write: true,
      log_file: "amd_log.csv",

      times_to_run: 1,
      presilence: true,

      initial_silence: 2500,
      greeting: 1500,
      after_greeting_silence: 800,
      total_analysis_time: 5000,
      min_word_length: 100,
      between_words_silence: 50,
      maximum_number_of_words: 3,
      silence_threshold: 256
    }

    @original_command_line = ARGV.join(' ')

    parse_options

    @target = ARGV[0] || 'ALL'
    @verbose = @options.delete :verbose
    @summary = @options.delete :summary
    @num_threads = @options.delete :num_threads

    @csv = @options.delete :csv
    @results_file = @options.delete :results_file

    @write = @options.delete :write
    @log_file = @options.delete :log_file

    @times_to_run = @options.delete :times_to_run

    @register = RunnerRegister.new @original_command_line

    @dialer = DRbObject.new_with_uri 'druby://localhost:9050'
    @list = @dialer.list
    @total = @list.count
  end

  def parse_options
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: runner [file_id|ALL] [@options]"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        @options[:verbose] = v
      end

      opts.on("-s", "--[no-]summary", "Print summary") do |v|
        @options[:summary] = v
      end

      opts.on("-c", "--[no-]csv", "Write results to CSV") do |v|
        @options[:csv] = v
      end

      opts.on("-f", "--file [FILENAME]", "Filename to write results to (defaults to amd_tuning_results.csv)") do |v|
        @options[:results_file] = v
      end

      opts.on("-w", "--[no-]write", "Write logs to file defined by -l") do |v|
        @options[:write] = v
      end

      opts.on("-l", "--log [FILENAME]", "Filename to write logs to (defaults to amd_logs.csv))") do |v|
        @options[:log_file] = v
      end

      opts.on("-p", "--[no-]presilence", "Play 50ms silence before activating AMD") do |v|
        @options[:presilence] = v
      end

      @options.keys.delete_if{ |i| [:verbose, :summary, :csv, :results_file, :write, :log_file].include? i}.each do |k|
        opts.on("--#{k} N", Integer, "#{k} - Default: #{@options[k]}") do |n|
          @options[k] = n
        end
      end

      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
      end
    end.parse!
  end

  def run
    if @target == 'ALL'
      Parallel.each_with_index(@list, :in_threads=> @num_threads) do |f, i|
        result = @dialer.dial i, @options
        if result
          @register.add(result)
        end
      end
    else
      result = @dialer.dial @target, @options
      if result
        @register.add(result)
        ap result if @verbose
      end
    end
    puts @register.print if @summary

    if @write
      @register.log(@log_file, @options)
    end

    if @csv
      path = register.to_csv(@results_file)
      puts "Results written to #{path}"
    end

    @register.summary
  end
end