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

require 'active_support/all'
class ExecuteXml
  def self.interpretXML(projectSuitMap, helper)
    allXmlFiles = []
    projectSuitMap.has_key?('section_id') ? projectSuitMap['section_id'].each {|section| allXmlFiles.concat(Dir.glob("#{Dir.pwd}/../**/*~#{section}/*.xml"))} : allXmlFiles = Dir.glob("#{Dir.pwd}/../**/*~#{projectSuitMap['suite_id']}/*.xml")
    allXmlFiles.each do |filePath|
      puts ":::::::::::::::::::::::::::::::::::::o: #{filePath.split('/')[-1].split('.')[0]} o::::::::::::::::::::::::::::::::::::::::::::::"
      begin
          helper.instance_variable_get(:@wait).until {helper.instance_variable_get(:@driver).execute_script("return document.readyState").eql? "complete"}
              
          puts "[Step   ]  : Validating filePath"
          assert_path_exist("#{filePath}")
          puts "[Result ]  : SUCCESS"

          caseHash = Hash.from_xml(File.read(filePath))
          caseId = filePath[filePath.rindex("/")..filePath.length]
          Dir.chdir(filePath.gsub(caseId, ''))
          assert_not_nil(caseHash ,"caseHash value - Expected :: not nil \n Actual :: nil #{caseHash}")
          caseHash['TestCase']['selenese'].each_with_index do |command, index|
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

              if (command['target'].eql?('link=Sales Console')) then 
                #(command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) && ()) then
                next
              end              

              if (command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) then
                assert_not_nil(helper.go_to_app(helper.instance_variable_get(:@driver), caseHash['TestCase']['selenese'][index + 1]['target'].split('=')[1]),"error in switching app")
                next;
                next;
                next
              else
                assert_not_nil(helper.send(command['command'].to_sym, command['target'], command['value']),'got nil from heler.'+"#{command['command']} with target:"+"#{command['target']} & value : "+ "#{command['value']}")
              end
          end #end of caseHash
          helper.addLogs('Success')
          helper.postSuccessResult(caseId.gsub('/', '').gsub('.xml', ''))
      rescue Exception => e
          helper.addLogs('Error')
          helper.addLogs(e)
          helper.postFailResult(e, caseId.gsub('/', '').gsub('.xml', ''))
      end #end of begin
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    end #end of allXmlFiles
  end
end
#puts Dir.glob("#{Dir.pwd}/../**/*~106/*.xml")

