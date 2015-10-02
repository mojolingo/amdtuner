class PlayerController < Adhearsion::CallController
  def run
    answer
    file = TestFile.get(call.to)
    logger.info "PLAYER_CONTROLLER PLAYING #{file.name}"
    play file.asterisk_path
    sleep(3)
  end
end