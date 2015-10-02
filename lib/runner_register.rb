class RunnerRegister
  attr_reader :total, :correct, :false_positives, :false_negatives, :average_time, :total_time, :start_time
  def initialize(original_command_line)
    reset
    @original_command_line = original_command_line
  end

  def reset
    @total = 0
    @correct = 0
    @false_positives = 0
    @false_negatives = 0
    @total_time = 0
    @highest_time = 0
    @start_time = Time.now
    @results = []
  end

  def add(result)
    @total += 1
    @correct += 1 if result[:correct]
    @false_positives += 1 if result[:status] == 'fp'
    @false_negatives += 1 if result[:status] == 'fn'
    @total_time += result[:time]
    @highest_time = result[:time] if result[:time] > @highest_time

    @results << result
  end

  def print
    sum = summary
    rows = [
      [{ :value => 'AMD Tuning Report', :colspan => 2, :alignment => :center }],
      :separator,
      ['Total', summary[:total]],
      ['Correct', summary[:correct]],
      ['Correct %', "#{summary[:correct_percent]}%"],
      ['False Positives', summary[:false_positives]],
      ['False Negatives', summary[:false_negatives]],
      ['Total time in AMD', "#{summary[:total_amd_time].round(3)} s"],
      ['Average time', "#{summary[:average_time]} s"],
      ['Execution time', "#{summary[:execution_time]} s"]
    ]
    Terminal::Table.new rows: rows
  end

  def summary
    correct_percent = (@correct.to_f/@total*100).round(2)
    average_time = (@total_time / @total).round(3)
    execution_time = Time.now - @start_time
    summary_hash = {
      total: @total,
      correct: @correct,
      correct_percent: correct_percent,
      false_positives: @false_positives,
      false_negatives: @false_negatives,
      total_amd_time: @total_time,
      average_time: average_time,
      execution_time: execution_time,
      original_command_line: @original_command_line
    }
  end

  def to_csv(file)
    path = File.expand_path(File.join(File.dirname(__FILE__), '../log/', file))
    CSV.open(path, "wb") do |csv|
      csv << ['Name', 'Human?', 'Result', 'Correct', 'Reason', 'Time', 'Status']
      @results.each do |r|
        csv << [ r[:name], r[:human], r[:result], r[:correct], r[:reason], r[:time], r[:status] ]
      end
    end
    path
  end

  def log(file, options)
      path = File.expand_path(File.join(File.dirname(__FILE__), '../log/', file))
      exists = File.exists? path
      sum = summary
      titles = options.keys + sum.keys
      values = options.merge(sum)
      CSV.open(path, "a") do |csv|
      if !exists
        csv << titles.map {|i| i.to_s}
      end
      row = []
      titles.each do |t|
        row << values[t]
      end
      csv << row
    end
  end
end