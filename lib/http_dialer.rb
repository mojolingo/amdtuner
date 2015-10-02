require 'erb'

class HttpDialer
  include Reel::App
  get('/dial/:file_id') do |request|
    params = request.path

    amd_parameters = {
      initial_silence: params["initial_silence"] || 2500,
      greeting: params["greeting"] || 1500,
      after_greeting_silence: params["after_greeting_silence"] || 800,
      total_analysis_time: params["total_analysis_time"] || 5000,
      min_word_length: params["min_word_length"] || 100,
      between_words_silence: params["between_words_silence"] || 50,
      maximum_number_of_words: params["maximum_number_of_words"] || 3,
      silence_threshold: params["silence_threshold"] || 256
    }

    
    file = TestFile.get params.file_id
    if file
      result = FutureResource.new
      Adhearsion::OutboundCall.originate "Local/#{params.file_id}@default"  do
        invoke_result = invoke AmdController, amd_parameters
        correct = true
        status = 'ok'
        if (!file.is_human? && invoke_result[0] != 'MACHINE')
          status = 'fn'
          correct = false
        end

        if (file.is_human? && invoke_result[0] == 'MACHINE')
          status = 'fp'
          correct = false
        end

        result.resource = {
          result: invoke_result[0],
          reason: invoke_result[1],
          time: invoke_result[2],
          name: file.name,
          human: file.is_human? ? true : false,
          correct: correct,
          status: status
        }
      end
      [200, {}, result.resource.to_json]
    else
      [200, {}, "null"]
    end
  end

  get '/' do
    @list = TestFile.annotated_list
    @num_files = @list.count
    page = erb 'index.html.erb'
    [200, {}, page]
  end

  def erb(file)
    tpl = ERB.new File.read(File.expand_path(File.join(File.dirname(__FILE__), '../html/', file)))
    tpl.result(binding)
  end
end