class DrbShared
  def dial(file_id, amd_parameters)
    file = TestFile.get file_id
    if file
      result = FutureResource.new
      Adhearsion::OutboundCall.originate "Local/#{file_id}@default"  do
        invoke_result = invoke AmdController, amd_parameters
        correct = true
        status = 'ok'
        if (!file.is_human? && invoke_result[0] != 'MACHINE')
          status = 'fn'
          correct = false
        end

        if (file.is_human? && invoke_result[0] == 'MACHINE') # we want as few as possible here
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
      return result.resource
    end
    nil
  end

  def list
    TestFile.list
  end
end