class AmdTunerPlugin < Adhearsion::Plugin
  init :amd_tuner do
    logger.info 'Survo plugin has been loaded'
  end

  config :amd_tuner do
    samples_dir "#{Adhearsion.config.platform[:root]}/samples/"
    samples_list []
  end
end