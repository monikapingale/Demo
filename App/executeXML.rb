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

# require 'active_support/all'
# class ExecuteXml
#   def self.interpretXML(projectSuitMap, helper)
#     allXmlFiles = []
#     projectSuitMap.has_key?('section_id') ? projectSuitMap['section_id'].each {|section| allXmlFiles.concat(Dir.glob("#{Dir.pwd}/../**/*~#{section}/*.xml"))} : allXmlFiles = Dir.glob("#{Dir.pwd}/../**/*~#{projectSuitMap['suite_id']}/*.xml")
#     allXmlFiles.each do |filePath|
#       puts ":::::::::::::::::::::::::::::::::::::o: #{filePath.split('/')[-1].split('.')[0]} o::::::::::::::::::::::::::::::::::::::::::::::"
#       begin
#           helper.instance_variable_get(:@wait).until {helper.instance_variable_get(:@driver).execute_script("return document.readyState").eql? "complete"}
              
#           puts "[Step   ]  : Validating filePath"
#           assert_path_exist("#{filePath}")
#           puts "[Result ]  : SUCCESS"

#           caseHash = Hash.from_xml(File.read(filePath))
#           caseId = filePath[filePath.rindex("/")..filePath.length]
#           Dir.chdir(filePath.gsub(caseId, ''))
#           assert_not_nil(caseHash ,"caseHash value - Expected :: not nil \n Actual :: nil #{caseHash}")

#           caseHash['TestCase']['selenese'].each_with_index do |command, index|
#               if command['command'].eql?("loadVars")
#                 @testData = helper.loadVars(command['target'], command['value'])
#               end
#           end



#           puts "testDAtaaaaa---->#{@testData}"
          
#           # puts "&&&&&&&&&&&&&&&&&&&&&&"
#           # puts @testData.to_json
#           # puts "&&&&&&&&&&&&&&&&&&&&&&"

#           # puts @testData.class
#           # key = @testData.keys[0]
#           # puts "key--->#{key}"
#           # value = @testData.values[0]
#           # puts "value--->#{value}"

#           @testData.values[0].each_with_index do |row,rowNumber| 
#             # puts 
#             # puts "rowNumber--->#{rowNumber}"
#             helper.instance_variable_set(:@index,rowNumber)
#             begin
#                 # puts "row---->#{rowNumber}::#{row}"
#                 #helper.instance_variable_set(:@testDataJSON,row)
#                 #puts "testDATA to operate----------------->#{helper.instance_variable_get(:@testDataJSON)}"

#                 caseHash['TestCase']['selenese'].each_with_index do |command,index|
#                   puts "#{command}"

#                   if command['command'].eql?("loadVars")
#                     # puts "skip all loadVars"
#                     next;
#                   end

#                   if command['command'].eql?("chooseOkOnNextConfirmation")
#                     helper.instance_variable_set(:@accept_next_alert,true)
#                     next
#                   end

#                   if command['command'].eql?("chooseCancelOnNextConfirmation")
#                     helper.instance_variable_set(:@accept_next_alert,false)
#                     next
#                   end

#                   if command['command'].eql?("assertConfirmation")
#                     helper.close_alert_and_get_its_text().eql? "#{command['target']}"
#                     next
#                   end

#                   if (command['target'].eql?('link=Sales Console')) then 
#                     #(command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) && ()) then
#                     next
#                   end   
#                   # puts "rowNumber--->#{rowNumber}"
#                   if ((command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) && (rowNumber != 0)) then
#                     # puts "skip go to app for #{rowNumber} data"
#                     next;
#                   end           

#                   if ((command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) && (rowNumber == 0)) then
#                     assert_not_nil(helper.go_to_app(helper.instance_variable_get(:@driver), caseHash['TestCase']['selenese'][index + 1]['target'].split('=')[1]),"error in switching app")
#                     next;
#                     next;
#                     next
#                   else
#                     assert_not_nil(helper.send(command['command'].to_sym, command['target'], command['value']),'got nil from heler.'+"#{command['command']} with target:"+"#{command['target']} & value : "+ "#{command['value']}")
#                   end

#                 end #end of caseHash
#                 helper.addLogs("Success for testData :: #{rowNumber}")
#                 helper.postSuccessResult(caseId.gsub('/', '').gsub('.xml', ''))
#               rescue Exception => e
#                 helper.addLogs("Error for testData ::#{rowNumber}")
#                 helper.addLogs("Exception :: #{e}")
#                 helper.postFailResult(e, caseId.gsub('/', '').gsub('.xml', ''))
#               end #end of inner begin
#           end #end of @testData
#       rescue Exception => e
#           helper.addLogs('Error')
#           helper.addLogs(e)
#           helper.postFailResult(e, caseId.gsub('/', '').gsub('.xml', ''))
#       end #end of begin
#       puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
#     end #end of allXmlFiles
#   end #end of def
# end #end of class





#           caseHash['TestCase']['selenese'].each_with_index do |command, index|
#             puts command
#               # if command['command'].eql?("loadVars")
#               #   @testData = helper.loadVars(command['target'], command['value'])
#               #   puts @testData
#               #   #helper.instance_variable_set(:@accept_next_alert,true)
#               #   next
#               # end 

#               if command['command'].eql?("chooseOkOnNextConfirmation")
#                 helper.instance_variable_set(:@accept_next_alert,true)
#                 next
#               end
#               if command['command'].eql?("chooseCancelOnNextConfirmation")
#                 helper.instance_variable_set(:@accept_next_alert,false)
#                 next
#               end
#               if command['command'].eql?("assertConfirmation")
#                 helper.close_alert_and_get_its_text().eql? "#{command['target']}"
#                 next
#               end

#               if (command['target'].eql?('link=Sales Console')) then 
#                 #(command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) && ()) then
#                 next
#               end              

#               if (command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) then
#                 assert_not_nil(helper.go_to_app(helper.instance_variable_get(:@driver), caseHash['TestCase']['selenese'][index + 1]['target'].split('=')[1]),"error in switching app")
#                 next;
#                 next;
#                 next
#               else
#                 assert_not_nil(helper.send(command['command'].to_sym, command['target'], command['value']),'got nil from heler.'+"#{command['command']} with target:"+"#{command['target']} & value : "+ "#{command['value']}")
#               end
#           end #end of caseHash
#           helper.addLogs('Success')
#           helper.postSuccessResult(caseId.gsub('/', '').gsub('.xml', ''))
#       rescue Exception => e
#           helper.addLogs('Error')
#           helper.addLogs(e)
#           helper.postFailResult(e, caseId.gsub('/', '').gsub('.xml', ''))
#       end #end of begin
#       puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
#     end #end of allXmlFiles
#   end
# end
# #puts Dir.glob("#{Dir.pwd}/../**/*~106/*.xml")






require 'active_support/all'
require 'colorize'
require 'terminal-table'
class ExecuteXml
  @analytics_report = Hash.new
  def self.interpretXML(projectSuitMap, helper)
    allXmlFiles = []
    puts projectSuitMap.has_key?('section_id')
    puts Dir.pwd
    projectSuitMap.has_key?('section_id') ? projectSuitMap['section_id'].each {|section| allXmlFiles.concat(Dir.glob("#{Dir.pwd}/../**/*~#{section}/*.xml"))} : allXmlFiles = Dir.glob("#{Dir.pwd}/../**/*~#{projectSuitMap['suite_id']}/*.xml")
    if allXmlFiles.length > 0 then
      allXmlFiles.each do |filePath|
        puts ":::::::::::::::::::::::::::::::::::::o: #{filePath.split('/')[-1].split('.')[0]} o::::::::::::::::::::::::::::::::::::::::::::::"
        begin
            helper.addLogs("\n[Step     ] : Execution starts for case id ::#{filePath.split('/')[-1].split('.')[0]}","C#{filePath.split('/')[-1].split('.')[0]}")#+':'+helper.instance_variable_get(:@index).to_s}")
            helper.instance_variable_get(:@wait).until {helper.instance_variable_get(:@driver).execute_script("return document.readyState").eql? "complete"}
                
            puts "[Step     ] : Validating filePath"
            assert_path_exist("#{filePath}")
            puts "[Result   ] : Success"

            caseHash = Hash.from_xml(File.read(filePath))
            caseId = filePath[filePath.rindex("/")..filePath.length]
            Dir.chdir(filePath.gsub(caseId, ''))
            assert_not_nil(caseHash ,"caseHash value - Expected :: not nil \n Actual :: nil #{caseHash}")

            caseHash['TestCase']['selenese'].each_with_index do |command, index|
                if command['command'].eql?("loadVars")
                  @testData = helper.loadVars(command['target'], command['value'])
                end
            end
            
            @testData.values[0].each_with_index do |row,rowNumber| 
              helper.instance_variable_set(:@index,rowNumber)
              begin
                  helper.addLogs("\n[Step     ] : Execution starts for case id ::C#{filePath.split('/')[-1].split('.')[0]} : Record -#{rowNumber.to_s}","C#{filePath.split('/')[-1].split('.')[0]+': Record -'+rowNumber.to_s}")#+':'+helper.instance_variable_get(:@index).to_s}")
                  caseHash['TestCase']['selenese'].each_with_index do |command,index|
                   


                    #puts "#{command}"
                    if command['command'].eql?("loadVars")
                      next;
                    end

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
                      next
                    end   
                    if ((command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) && (rowNumber != 0)) then
                      next;
                    end
                    if ((command['target'].eql?('id=tsidButton') | command['target'].eql?('id=tsidLabel') | command['target'].eql?('id=tsid-arrow')) && (rowNumber == 0)) then
                      assert_not_nil(helper.go_to_app(helper.instance_variable_get(:@driver), caseHash['TestCase']['selenese'][index + 1]['target'].split('=')[1]),"error in switching app")
                      next;
                      next;
                      next
                    else
                      assert_not_nil(helper.send(command['command'].to_sym, command['target'], command['value']),'got nil from heler.'+"#{command['command']} with target:"+"#{command['target']} & value : "+ "#{command['value']}")
                    end

                  end #end of caseHash
                  helper.addLogs("Success for testData :: #{rowNumber}")
                  
                  result = Hash.new
                  result.store('Result',"#{'Success'.green}")
                  result.store('Browser',"#{helper.instance_variable_get(:@driver).browser}")
                  #result = {"Result" => 'Success',"Profile/User" => '',"Browser" => "#{helper.instance_variable_get(:@driver).browser}"}
                  projectSuitMap.has_key?('user') ? result.store('User',projectSuitMap['user']) : result.store('Profile',projectSuitMap['profile'])
                  @analytics_report.store("C#{caseId.gsub('/', '').gsub('.xml', '')+': Record -'+rowNumber.to_s}",result)
                  
                  assert_not_nil(helper.postSuccessResult("C#{caseId.gsub('/', '').gsub('.xml', '')+': Record -'+rowNumber.to_s}"),'error in posting result')
                rescue Exception => e
                  helper.addLogs("Error for testData ::#{rowNumber}")

                  result = Hash.new
                  result.store('Result',"#{'Fail'.red}")
                  result.store('Browser',"#{helper.instance_variable_get(:@driver).browser}")
                  #result = {"Result" => 'Success',"Profile/User" => '',"Browser" => "#{helper.instance_variable_get(:@driver).browser}"}
                  projectSuitMap.has_key?('user') ? result.store('User',projectSuitMap['user']) : result.store('Profile',projectSuitMap['profile'])
                  
                  @analytics_report.store("C#{caseId.gsub('/', '').gsub('.xml', '')+': Record -'+rowNumber.to_s}",result)
                  
                  #helper.addLogs("Exception :: #{e}")
                  helper.postFailResult(e, "C#{caseId.gsub('/', '').gsub('.xml', '')+': Record -'+rowNumber.to_s}")
                end #end of inner begin
            end #end of @testData
        rescue Exception => e
            helper.addLogs("[Error    ] : Exception while reading recording - #{e}")
            helper.postFailResult(e, "C"+caseId.gsub('/', '').gsub('.xml', ''))#+':'+helper.instance_variable_get(:@index).to_s)
        end #end of begin
      end #end of allXmlFiles
    elsif allXmlFiles.length == 0 then
      helper.addLogs("[Error    ] : No recordings found for given section")
      #puts projectSuitMap['case_id'][0].class
      helper.addLogs('',projectSuitMap['case_id'][0].to_s)
      helper.postFailResult('[Error    ] : No recordings found for given section', projectSuitMap['case_id'][0])
    end
    
    trows = []    
    @analytics_report.each do |key,value|
      rows = []
        rows.push("#{key}")
        value.values.each do |row|
          rows.push(row.to_s)
        end
        trows << rows
    end
    table = Terminal::Table.new :headings => ['Test Case Id'.light_blue, 'Result'.light_blue,'Browser'.light_blue,'User/Profile'.light_blue], :rows => trows
    puts table
    

    rescue Exception => e
      puts "Exception--->#{e} #{e.backtrace}"

  end #end of def
end #end of class
