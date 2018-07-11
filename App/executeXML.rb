=begin
************************************************************************************************************************************
    Author      :   QaAutomationTeam
    Description :   This gem ....

    History     :
  ----------------------------------------------------------------------------------------------------------------------------------
  VERSION           DATE             AUTHOR                  DETAIL
  1                 23 June 2018     QaAutomationTeam        Initial Developement
**************************************************************************************************************************************
=end
class ExecuteXml

  def self.interpretXML(projectSuitMap, helper)
    allXmlFiles = []
    projectSuitMap.has_key?('section_id') ? projectSuitMap['section_id'].each {|section| allXmlFiles.concat(Dir.glob("#{Dir.pwd}/../**/*~#{section}/*.xml"))} : allXmlFiles = Dir.glob("#{Dir.pwd}/../**/*~#{projectSuitMap['suite_id']}/*.xml")
    puts allXmlFiles.inspect
    allXmlFiles.each do |filePath|
      begin
        caseHash = Hash.from_xml(File.read(filePath))
        caseId = filePath[filePath.rindex("/")..filePath.length]
        Dir.chdir(filePath.gsub(caseId, ''))
        caseHash['TestCase']['selenese'].each_with_index do |command, index|
          puts command
          if command['command'].eql?("chooseOkOnNextConfirmation")
            helper.instance_variable_set(:@accept_next_alert,true)
            next
          end
          if command['command'].eql?("chooseCancelOnNextConfirmation")
            helper.instance_variable_set(:@accept_next_alert,false)
            next
          end
          if command['command'].eql?("assertConfirmation")
            helper.close_alert_and_get_its_text().eql? "#{command['target']}"
            next
          end
          helper.instance_variable_get(:@wait).until {helper.instance_variable_get(:@driver).execute_script("return document.readyState").eql? "complete"}
          if command['target'].eql?('id=tsidButton')
            helper.go_to_app(helper.instance_variable_get(:@driver), caseHash['TestCase']['selenese'][index + 1]['target'].split('=')[1]); next; next
          else
            helper.send(command['command'].to_sym, command['target'], command['value'])
          end
        end
        helper.addLogs('Success')
        helper.postSuccessResult(caseId.gsub('/', '').gsub('.xml', ''))
      rescue Exception => e
        puts e
        helper.addLogs('Error')
        helper.postFailResult(e, caseId.gsub('/', '').gsub('.xml', ''))
        #raise e
      end
    end
  end
end
#puts Dir.glob("#{Dir.pwd}/../**/*~106/*.xml")
