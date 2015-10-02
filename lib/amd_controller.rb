# encoding: utf-8

class AmdController < Adhearsion::CallController
  def run
    answer
    logger.info "AMD_CONTROLLER INVOKED"
    start = Time.now

    play "#{Adhearsion.config.amd_tuner.samples_dir}../audio/50ms" if metadata[:presilence]
    
    execute "AMD", metadata[:initial_silence], metadata[:greeting], metadata[:after_greeting_silence], metadata[:total_analysis_time], metadata[:min_word_length], metadata[:between_words_silence], metadata[:maximum_number_of_words], metadata[:silence_threshold]
    
    logger.info "AMDSTATUS INVOKED"
    result = get_variable("AMDSTATUS")
    logger.info "AMDCAUSE INVOKED"
    reason = get_variable("AMDCAUSE")
    time = Time.now - start

    logger.info "AMD RESULT WAS #{result} #{reason}"
    [result, reason, time.round(3)]
  end
end
