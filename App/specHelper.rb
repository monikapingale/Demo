# require 'enziUIUtility'
# require 'selenium-webdriver'
# require 'faye'
# require 'test/unit'
# require 'yaml'
# require 'csv'
# include Test::Unit::Assertions
# require_relative File.expand_path('..', Dir.pwd) + "/Gems/enziRestforce/lib/enziRestforce.rb"
# require_relative File.expand_path('..', Dir.pwd) + "/Gems/RollbarUtility/rollbarUtility.rb"
# require_relative File.expand_path('..', Dir.pwd) + "/Gems/EnziUIUtility/lib/enziUIUtility.rb"
# require_relative File.expand_path('..', Dir.pwd) + "/Gems/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
# class Helper
#   def initialize()
#     @isDevelopment = true
#     @runId = ENV['RUN_ID']
#     @objRollbar = RollbarUtility.new()
#     @index = nil
#     @testData = {}
#     @testDataJSON = {}
#     @driver = ''
#     @timeSettingMap = YAML.load_file(File.expand_path(Dir.pwd) + '/Config/timeSettings.yaml')
#     @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
#   end

#   def alert_present?(driver)
#     driver.switch_to.alert
#     true
#    rescue Selenium::WebDriver::Error::NoAlertPresentError
#     false
#   end

#   def self.addRecordsToDelete(key, value)
#     if EnziRestforce.class_variable_get(:@@createdRecordsIds).key?("#{key}") then
#       EnziRestforce.class_variable_get(:@@createdRecordsIds)["#{key}"] << Hash["Id" => value]
#     else
#       EnziRestforce.class_variable_get(:@@createdRecordsIds)["#{key}"] = [Hash["Id" => value]]
#     end
#   end

#   def postSuccessResult(caseId)
#     puts "switching back to default_content" if @isDevelopment
#     @driver.switch_to.default_content
#     puts "----------------------------------------------------------------------------------"
#     puts ""
#     @testRailUtility.postResult(caseId, "Pass on #{@driver.browser}", 1, @runId)
#     @passedLogs = @objRollbar.addLogs("[Result  ]  Success")
#   end

#   def postFailResult(exception, caseId)
#     puts "switching back to default_content" if @isDevelopment
#     @driver.switch_to.default_content
#     puts "----------------------------------------------------------------------------------"
#     caseInfo = @testRailUtility.getCase(caseId)
#     @passedLogs = @objRollbar.addLogs("[Result  ]  Failed")
#     @passedLogs = @objRollbar.addLogs("#{exception}")
#     @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], @passedLogs[caseInfo['id'].to_s])
#     Rollbar.error(exception)
#     @testRailUtility.postResult(caseId, "Result for case #{caseId} on #{@driver.browser}  is #{@passedLogs[caseInfo['id'].to_s]}", 5, @runId)
#   rescue Exception => e
#     puts "Exception in specHelper------> #{e}" if @isDevelopment
#     return nil
#   end

#   def addLogs(logs, caseId = nil)
#     if caseId != nil then
#       @passedLogs = @objRollbar.addLogs(logs, caseId)
#     else
#       @passedLogs = @objRollbar.addLogs(logs)
#     end
#   end

#   def getSalesforceRecord(sObject, query)
#     puts query if @isDevelopment
#     result = Salesforce.getRecords(@salesforceBulk, "#{sObject}", "#{query}", nil)
#     #puts "#{sObject} created => #{result.result.records}"
#     return result.result.records
#    rescue Exception => e
#     puts e if @isDevelopment
#     puts "No record found111111" if @isDevelopment
#     return nil
#   end

#   def createSalesforceRecord(objectType, records_to_insert)
#     Salesforce.createRecords(@salesforceBulk, objectType, records_to_insert)
#   end

#   def getRestforceObj()
#     return @restForce
#   end

#   def getSalesforceRecordByRestforce(query)
#     #puts query
#     record = @restForce.getRecords("#{query}")
#     if record.size > 1 then
#       puts "Multiple records handle carefully....!!!"
#     elsif record.size == 0 then
#       puts "No record found....!!!" if @isDevelopment
#       return nil
#     end
#     #puts record[0].attrs['Id']
#     return record
#    rescue Exception => e
#     puts e if @isDevelopment
#     return nil
#   end

#   def deleteSalesforceRecordBySfbulk(sObject, recordsToDelete)
#     #puts recordsToDelete
#     result = Salesforce.deleteRecords(@salesforceBulk, sObject, recordsToDelete)
#     puts "record deleted===> #{result}"  if @isDevelopment
#     puts result if @isDevelopment
#     return true
#     rescue Exception => e
#     puts e if @isDevelopment
#     return nil
#   end

#   def getElementByAttribute(driver, elementFindBy, elementIdentity, attributeName, attributeValue)
#     puts "in accountAssignment::getElementByAttribute" if @isDevelopment
#     driver.execute_script("arguments[0].scrollIntoView();", driver.find_element(elementFindBy, elementIdentity))
#     puts "in getElementByAttribute #{attributeValue}" if @isDevelopment
#     @driver = driver
#     elements = @driver.find_elements(elementFindBy, elementIdentity)
#     elements.each do |element|
#       if element.attribute(attributeName) != nil then
#         if element.attribute(attributeName).include? attributeValue then
#           puts "element found" if @isDevelopment
#           return element
#           break
#         end
#       end
#     end
#   end

# =begin  def update_campaign(id, lead_owner = nil, email = nil, city = nil)
#     @restForce.updateRecord("Campaign", {"Id"  id, "Lead_Owner__c" => lead_owner, "Email_Address__c" => email, "City__c" => city})
# =end

#   def getExistingLead(from, to, owner = nil, checkForActivity = nil)
#     index = from
#     userHasPermission = false
#     owner = " AND CreatedBy.Name = '#{owner}'" if !owner.nil?
#     checkForActivity = "(SELECT id FROM tasks)," if !checkForActivity.nil?
#     if !from.nil? || !to.nil?
#       leadInfo = @restForce.getRecords("SELECT id , #{checkForActivity} Owner.Name,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate < #{from} AND CreatedDate  = LAST_N_DAYS:#{to} AND  isDeleted = false #{owner}")
#       allowedUsers = JSON.parse(@settings[3]['Data__c'])['allowedUsers']
#       leadInfo.each do |lead|
#         if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
#           userHasPermission = true
#           leadInfo = lead
#           break;
#         end
#       end
#       if leadInfo.nil?
#         until !(index < to) || userHasPermission
#           if leadInfo[0].nil?
#             leadInfo = @restForce.getRecords("SELECT id , Owner.Name, Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:#{index} AND isDeleted = false #{owner}")
#             leadInfo.each do |lead|
#               if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
#                 userHasPermission = true
#                 leadInfo = lead
#                 break;
#               end
#             end
#           end
#         end
#       else
#         leadInfo.each do |lead|
#           if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
#             userHasPermission = true
#             leadInfo = lead
#             break;
#           end
#         end
#       end
#       index += 1
#     else
#       puts "Getting Records....."
#       leadInfo = @restForce.getRecords("SELECT id , #{checkForActivity} Owner.Name,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email like '%@example.com' AND isConverted = false AND isDeleted = false #{owner} LIMIT 10")
#     end
#     leadInfo if !leadInfo.nil?
#   end

#   def createPushTopic(name, query)
#     # Create a PushTopic for subscribing to record changes.
#     client.upsert! 'PushTopic', {
#         ApiVersion: '23.0',
#         Name: name,
#         Description: 'Monitoring ',
#         NotifyForOperations: 'All',
#         NotifyForFields: 'All',
#         Query: query
#     }
#   end

#   def loadVars(target, value)
#     puts "[Step] #{target} loading is started"
#       puts "in loadVars--->target::#{target} value::#{value}" if @isDevelopment   
#       case File.extname(target)
#         when ".csv"
#           puts "Your test data is loading from csv file" if @isDevelopment
#           @testDataJSON[target.gsub('.csv', '')]= CSV.open(File.expand_path('..', Dir.pwd) + "/TestData/#{target}",:encoding => "utf-8", headers: :first_row).map(&:to_h)
#           #@testData = CSV.open(File.expand_path('..', Dir.pwd) + "/TestData/#{target}",:encoding => "bom|utf-8", headers: :first_row).map(&:to_h)
#         when ".json"
#           puts "Your test data is loading from json file" if @isDevelopment
#           @testDataJSON[target.gsub('.json', '')] = JSON.parse(File.read('..',Dir.pwd+"/TestData/#{target}"))
#           #@testData = JSON.parse(File.read('..',Dir.pwd+"/TestData/#{target}"))
#         else
#           puts "No valid testdata file found" if @isDevelopment
#           return nil
#       end    
#       puts "testDataJSON---->#{@testDataJSON}" if @isDevelopment
#       puts "[Result  ]  Success"
#       return @testDataJSON
#     rescue Exception => e
#       puts "exception in loadVars--->#{e}" if @isDevelopment
#       puts "[Result  ]  Failed"
#       nil
#   end

#   # def find_element(target)
#   #   puts "in find_element--->target::#{target}"  if @isDevelopment      
#   #   if target.include?('//') && !target.nil?
#   #     @driver.current_url().include?("lightning") && target.include?("id=") && target.include?(":") ? target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,") : target = target.gsub('xpath=', '')
#   #     @wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
#   #     return @driver.find_element(:xpath, "#{target}")
#   #   else
#   #     if @driver.current_url().include?("lightning") && target.include?("id=")
#   #       element = target.split('=')
#   #       @wait.until {@driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]").displayed?}
#   #       return @driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]")
#   #     else
#   #       element = target.split('=')
#   #       @wait.until {@driver.find_element(element[0].to_sym, element[1]).displayed?}
#   #       return @driver.find_element(element[0].to_sym, element[1])
#   #     end
#   #   end
#   #   rescue Exception => e
#   #   puts "Exception in find_element::#{e}" if @isDevelopment
#   #   raise e
#   # end
#    def find_element(target)
#    puts "in find_element--->target::#{target}"  #if @isDevelopment      
#    if target.include?('//') && target.include?(":") && !target.include?("::") && !target.nil?
#      puts "finding element xpath contains :" #if @isDevelopment
#      if @driver.current_url().include?("lightning") && target.include?("id=")
#        puts "in lightning--->" #if @isDevelopment
#        target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
#      else
#        puts "in classic--->" #if @isDevelopment
#        target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
#      end
#      #@driver.current_url().include?("lightning") && target.include?("id=") && target.include?(":") ? target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,") : target = target.gsub('xpath=', '')
#      #target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
#      puts "target--->#{target}" #if @isDevelopment
#      @wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
#      return @driver.find_element(:xpath, "#{target}")
#    else
#      if target.include?('//') && !target.nil?
#        puts "finding element by xpath" #if @isDevelopment
#        target = target.gsub('xpath=', '')
#        @wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
#        return @driver.find_element(:xpath, "#{target}")
#      end
#      if target.include?("id=") && target.include?(":")#@driver.current_url().include?("lightning") && 
#        puts "containing id= and :" #if @isDevelopment
#        element = target.split('=') #//*[starts-with(@id,'')]
#        @wait.until {@driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]").displayed?}
#        return @driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]")
#      else
#        puts "all escapes" #if @isDevelopment
#        element = target.split('=')
#        puts "element--->#{element[1]}" #if @isDevelopment
#        @wait.until {@driver.find_element(element[0].to_sym, element[1]).displayed?}
# return @driver.find_element(element[0].to_sym, element[1])
#      end
#    end
#    rescue Exception => e
#    puts "Exception in find_element::#{e} #{e.backtrace}" #if @isDevelopment
#    nil
#  end

#   def click(target, value)
#     puts "in click--->target::#{target} value::#{value}" if @isDevelopment
#     retries ||= 0
#     puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" if @isDevelopment
#     puts "#{target.split('=')[1].delete('${}')}".split('_')[0] if target.include?('$') && target.include?('{') if @isDevelopment
#     puts @testDataJSON["#{target.split('=')[1].delete('${}')}".split('_')[0]][@index] if target.include?('$') && target.include?('{') if @isDevelopment
#     puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" if @isDevelopment

#     testData1 = @testDataJSON["#{target.split('=')[1].delete('${}')}".split('_')[0]][@index] if target.include?('$') && target.include?('{')
#     target = "#{target.split('=')[0]}=#{testData1["#{target.split('=')[1].delete('${}')}"]}" if target.include?('$') && target.include?('{')
#     begin
#       puts "wait till spinner not visible" if @isDevelopment
#       @driver.find_element(:xpath, "//div[@id='spinnerContainer'] | //div[@id='spinner']")
#       @wait.until {!@driver.find_element(:xpath, "//div[@id='spinnerContainer'] | //div[@id='spinner']").displayed?}
#       puts "success" if @isDevelopment
#     rescue Exception => e
#       puts "Exception in finding spinner--->#{e}" if @isDevelopment
#       puts "spinner not present......!!!" if @isDevelopment
#     end


#     element = find_element(target)
#     @wait.until{ element.enabled? }
#     #puts element.click.class
#     #puts element.displayed?
#     #puts element.enabled?
#     #@wait.until { element.displayed?}
#     #@wait.untill{ element.enabled? }
#     puts "click on button" if @isDevelopment
#     #sleep(2)
#     #@wait.until {@driver.find_elements(:xpath, "//*[contains(@id,'spinner')]")[0].displayed?}
#     element.click if !element.nil?
#     #puts "4454"
#     return true
#   rescue Exception => e
#     puts "Exception in click :: #{e}" if @isDevelopment
#     retry if (retries += 1) < 3
#     return nil
#   end

#   def type(target, value)
#     puts " in type---->with target:: #{target} and value:: #{value}" #if @isDevelopment

#     @testDataJSON["#{value.delete('${}')}".split('_')[0]][@index]["#{value.delete('${}')}"] = eval('"' + @testDataJSON["#{value.delete('${}')}".split('_')[0]][@index].fetch("#{value.delete('${}')}") + '"') if ((value.include? "${") && (@testDataJSON["#{value.delete('${}')}".split('_')[0]][@index].has_key?("#{value.delete('${}')}")) && (value.include? "${"))
    
#     element = find_element(target)
#     if !element.nil? then
#         element.clear
#         puts "::::((((((((((((((((((((((((("
#         puts @testDataJSON
#         #puts @testDataJSON["#{value.delete('${}')}"]
#         puts (value.include?('$') && value.include?('{'))
#         (value.include?('$') && value.include?('{')) ? element.send_keys(@testDataJSON["#{value.delete('${}')}".split('_')[0]][@index]["#{value.delete('${}')}"]) : element.send_keys("#{value.to_s}")
#         puts ":::::::::::::::::::::*************:::::::::::::::::::::::::" #if @isDevelopment
#         puts "@testDataJSON---->#{@testDataJSON}" #if @isDevelopment
#         puts ":::::::::::::::::::::*************:::::::::::::::::::::::::" #if @isDevelopment
#         puts "@testData---->#{@testData}" if @isDevelopment
#         puts ":::::::::::::::::::::*************:::::::::::::::::::::::::" if @isDevelopment
#         return true
#     else
#       puts "element not found...!!!" if @isDevelopment
#       return nil
#     end
#   rescue Exception => e
#     puts "Exception in type :: #{e.backtrace}" #if @isDevelopment
#     return nil
#   end

#   def doubleClick(target, value)
#     puts "in doubleClick--->target::#{target} value::#{value}" if @isDevelopment 
#     element = find_element(target)
#     element.click
#     element.click
#   end

#   def waitForElementPresent(target, value)
#     puts "in waitForElementPresent--->target::#{target} value::#{value}" if @isDevelopment
#     find_element(target)
#   end

#   def select(target, value)
#     puts "in select --->>with target:: #{target} and value:: #{value}" if @isDevelopment
#     #retries ||= 0
#     #puts @testDataJSON
#     val1 = value.split('=')[1]

#     if (val1.include?('$') && val1.include?('{')) then
#       puts "take value from json" if @isDevelopment
#         val = "#{val1.delete('${}')}"
#         valueToSelect = @testDataJSON[val.split('_')[0]][@index]["#{val}"]
#     else
#       puts "selected by users" if @isDevelopment
#         valueToSelect = val1
#     end 
    
#         puts "value to select---->#{valueToSelect}" if @isDevelopment


#     if target.include?('//') && !target.nil? 
#       puts "999999999999999999999999999" if @isDevelopment
#       puts "target--->#{target}" if @isDevelopment
#       #target1 = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
#       Selenium::WebDriver::Support::Select.new(find_element(target)).select_by(:text, valueToSelect)
#       return true
#     else
#       puts "8888888888888888888888888888" if @isDevelopment
#       #Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "FollowUpAfter")).select_by(:text, "7 Days")
#       #puts @testDataJSON
#       #puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
#       #puts val
#       #puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
      
#       #puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"

      
#       #puts valueToSelect
#       #puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
#       #puts @testDataJSON["LeadSource"]
#       Selenium::WebDriver::Support::Select.new(find_element(target)).select_by(:text, valueToSelect)
#       puts "returning true" if @isDevelopment
#       return true
#     end
#     rescue Exception => e
#     puts "Exception in select :: #{e}    #{e.backtrace}" #if @isDevelopment
#     #retry if (retries += 1) < 3
#     return nil
#   end

#   def selectWindow(target, value)
#     puts "in selectWindow--->target::#{target} value::#{value}" if @isDevelopment  
#     @driver.window_handles
#     @driver.window_handles
#     target[target.length - 1]
#     @driver.switch_to.window @driver.window_handles.last
#   end

#   def openWindow(target, value)
#     puts "in openWindow--->target::#{target} value::#{value}" if @isDevelopment
#     @driver.get target
#   end

#   def lightening_click_row(target, value)
#     puts "in lightening_click_row--->target::#{target} value::#{value}" if @isDevelopment
#     @wait.until {@driver.find_element(:xpath, "//span[contains(text(),#{target})]/../../../../../..").displayed?}
#     @driver.find_element(:xpath, "//span[contains(text(),#{target})]/../../../../../..").find_elements(:tag_name, 'tr')[value.to_i].find_elements(:tag_name, 'td')[2].find_elements(:tag_name, 'a')[0].click
#   end

#   def lightening_assert_form_element(target, value)
#     puts "in lightening_assert_form_element--->target::#{target} value::#{value}" if @isDevelopment 
#     xpath = "//span[./text()=#{target}]/../following-sibling::div/descendant::"
#     @wait.until {@driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").displayed?}
#     puts @driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").text if @isDevelopment
#     assert_match(value, @driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").text)
#   end

#   def moreAction(target, value)
#     puts "in moreAction--->target::#{target} value::#{value}" if @isDevelopment
#    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
#    frameid = @driver.find_elements(:xpath, "//iframe[contains(@id,'ext-comp-')]")[1].attribute('id')
#    @driver.switch_to.frame(frameid)
#    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
#    @driver.find_element(:id,'actionDropdown').click
#    return frameid

#    rescue Exception => e
#      puts "Exception in moreAction---->#{e}" if @isDevelopment
#      return nil
   
#  end

#   def lightening_type(target, value)
#     puts "in lightening_type--->target::#{target} value::#{value}" if @isDevelopment  
#     @testDataJSON["#{value.delete('${}')}"] = eval('"' + @testDataJSON.fetch("#{value.delete('${}')}") + '"') if @testDataJSON.has_key?("#{value.delete('${}')}")
#     puts @testDataJSON["#{value.delete('${}')}"] if @isDevelopment
#     target.include?('list') ? target = "//label[./text()= '#{target.split(':')[0]}']/../parent::div//input | //span[./text()= '#{target.split(':')[0]}']/../parent::div//input" : target = "//span[./text()= '#{target}']/../following-sibling::input"
#     @wait.until {@driver.find_element(:xpath, target).displayed?}
#     @driver.find_element(:xpath, target).clear
#     (value.include?('$') && value.include?('{')) ? @driver.find_element(:xpath, target).send_keys(@testDataJSON["#{value.delete('${}')}"]) : @driver.find_element(:xpath, target).send_keys("#{value.to_s}")
#   end

#   def lightening_click(target, value)
#     puts "in lightening_click--->target::#{target} value::#{value}" if @isDevelopment 
#     puts target if @isDevelopment
#     target = target.split('id=')[1].split(':')[0] if (target.include?("id=") && target.include?(':'))
#     @wait.until {@driver.find_element(:xpath, "//a[@title='#{target}'] | //button[@title='#{target}']| //*[starts-with(@id,'#{target}')] | //button/span[./text()='#{target}'] | //span[./text()= '#{target}']/../preceding-sibling::input").displayed?}
#     @driver.find_element(:xpath, "//a[@title='#{target}'] | //button[@title='#{target}']| //*[starts-with(@id,'#{target}')] | //button/span[./text()='#{target}'] | //span[./text()= '#{target}']/../preceding-sibling::input").click
#   end

#   def lightening_select(target, value)
#     puts "in lightening_select--->target::#{target} value::#{value}" if @isDevelopment 
#     value = "label=#{@testDataJSON.fetch(value.delete('${}').gsub('label=', ''))}" if (value.include?('$') && value.include?('{'))
#     @wait.until {@driver.find_element(:xpath, "//option[@value='" + value.split('label=')[1] + "'] | //li[@title='" + value.split('label=')[1] + "']").displayed?}
#     @driver.find_element(:xpath, "//option[@value='" + value.split('label=')[1] + "'] | //li[@title='" + value.split('label=')[1] + "']").click
#   end

#   def date_picker(target, value)
#     puts "in date_picker--->target::#{target} value::#{value}" if @isDevelopment
#     @wait.until {@driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0]}']/../parent::div//input")}
#     @driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0]}']/../parent::div//input").click
#     @wait.until {@driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0]}']/../parent::div//table//span[@id='#{Date.today.to_s}']")}
#     @driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0]}']/../parent::div//table//span[@id='#{Date.today.to_s}']").click
#     @wait.until {!@driver.find_element(:id, "spinner").displayed?}
#   end

#   def wait(target, value)
#     puts "in wait--->target::#{target} value::#{value}" if @isDevelopment
#     value.eql?('true') ? @wait.until {@driver.find_element(target.split('=')[0].to_sym, target.split('=')[1]).displayed?} : @wait.until {!@driver.find_element(target.split('=')[0].to_sym, target.split('=')[1]).displayed?}
#   end

#   def login(envCredential)
#     puts "in login--->envCredential::#{envCredential}" if @isDevelopment
#     pwd = EnziEncryptor.decrypt(JSON.parse(envCredential.fetch('parameters'))['password'], ENV['KEY'].chop.chop)
#     @driver.get 'https://test.salesforce.com/'
#     #puts pwd
#     #puts envCredential
#     #@driver.get JSON.parse(envCredential.fetch('parameters'))['url']
#     @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
#     @driver.find_element(:xpath, "//input[contains(@id,'name')]").clear
#     @driver.find_element(:xpath, "//input[contains(@id,'name')]").send_keys JSON.parse(envCredential.fetch('parameters'))['username']
#     @driver.find_element(:xpath, "//input[contains(@id,'password')]").clear
#     @driver.find_element(:xpath, "//input[contains(@id,'password')]").send_keys pwd
#     @driver.find_element(:xpath, "//input[contains(@type,'submit')] | //button[contains(@type,'submit')]").click
#     @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
#     @wait.until {@driver.find_element(:xpath, "//*[@title='Search Salesforce'] | //*[@id='phSearchInput']").displayed?}
    
#     puts "switching to classic....." if @isDevelopment
#     puts @driver.current_url() if @isDevelopment
#     EnziUIUtility.switchToClassic(@driver) if (@driver.current_url().include? "lightning")
#     @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
#     true
#     rescue Exception => e 
#     puts "Exception in Helper :: login -> #{e}" if @isDevelopment
#     nil
#   end

#   # def loginAsGivenProfile(profile)
#   #   puts "in loginAsGivenProfile---->profile::#{profile}" #if @isDevelopment
#   #   EnziUIUtility.switchToClassic(@driver) if (@driver.current_url().include? "lightning")
    
#   #   newUrl = @driver.current_url().split('/')
#   #   #puts newUrl
#   #   @driver.get "#{newUrl[0]}//#{newUrl[2]}/" + "005?id=" + "#{profile['id']}"

#   #   #puts "go to #{@driver.current_url()}"
#   #   @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
#   #   #sleep(20)
#   #   @wait.until {@driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[2]/td[1]/a[2]").displayed?}
#   #   @driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[2]/td[1]/a[2]").click
#   #   #EnziUIUtility.switchToClassic(@driver)
#   #   #EnziUIUtility.switchToLightening(@driver)
#   #   @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
#   #   rescue Exception => e 
#   #   puts "Exception in Helper :: loginAsGivenProfile -> #{e}" #if @isDevelopment
#   #   nil
#   # end

#     def loginAsGivenProfile(record)
#     puts "in loginAsGivenProfile---->record::#{record}" if @isDevelopment
#     #puts record.fetch('profile')['id']
#     EnziUIUtility.switchToClassic(@driver) if (@driver.current_url().include? "lightning")
    
#     newUrl = @driver.current_url().split('/')
#     #puts newUrl
#     @driver.get "#{newUrl[0]}//#{newUrl[2]}/" + "005?id=" + "#{record.fetch('profile')['id']}" if record.has_key?('profile')

#     @driver.get "#{newUrl[0]}//#{newUrl[2]}/" + "#{record.fetch('user')['id']}" + "?noredirect=1&isUserEntityOverride=1" if record.has_key?('user')

#     #puts "go to #{@driver.current_url()}"
#     @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
#     if record.has_key?('profile')
#       puts "login for profile" if @isDevelopment
#       @wait.until {@driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[2]/td[1]/a[2]").displayed?}
#       @driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[2]/td[1]/a[2]").click
#       puts "done"  if @isDevelopment
#     elsif record.has_key?('user')
#       puts "login for user"  if @isDevelopment    
#       @wait.until {@driver.find_element(:xpath, "//input[@name='login']").displayed?}
#       @driver.find_element(:xpath, "//input[@name='login']").click      
#       puts "done"  if @isDevelopment
#     end
#     #EnziUIUtility.switchToClassic(@driver)
#     #EnziUIUtility.switchToLightening(@driver)
#     @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
#     addLogs("[Result   ] : Success")
#     true
#     rescue Exception => e 
#     addLogs("[Result   ] : Failed")
#     puts "Exception in Helper :: loginAsGivenrecord -> #{e} #{e.backtrace}" if @isDevelopment
#     nil
#   end

#   def logOutGivenProfile()
#     puts "in Helper :: logOutGivenProfile" if @isDevelopment
#     #puts @driver.current_url
#     url = @driver.current_url.split('force.com')[0].to_s
#     finalURL = url+"force.com/home/home.jsp"
#     #puts "finalURL--->#{finalURL}"

#     @driver.get finalURL
#     @wait.until {@driver.find_element(:xpath, "//*[@title='Search Salesforce'] | //*[@id='phSearchInput']").displayed?}
    
#     if !(@driver.current_url.include? 'lightning') then
#       #puts "lightning"
#       @wait.until {@driver.find_element(:xpath, "//*[@id='userNav-arrow']").displayed?}
#       @driver.find_element(:xpath, "//*[@id='userNav-arrow']").click
#     end
#     @wait.until {@driver.find_element(:xpath, "//a[@href='/secur/logout.jsp']").displayed?}
#     @driver.find_element(:xpath, "//a[@href='/secur/logout.jsp']").click
#     return true
#     rescue Exception => e 
#     puts "Exception in Helper :: logOutGivenProfile -> #{e}" if @isDevelopment
#     return nil
#   end

#   def echo(target, value)
#     puts "in echo--->target::#{target} value::#{value}" if @isDevelopment  
#     !value.nil? ? addLogs(target, value) : addLogs(target)
#     rescue Exception => e 
#     puts "Exception in Helper :: echo -> #{e}" if @isDevelopment
#     nil
#   end

#   def store(target, value)
#     puts "in store--->target::#{target} value::#{value}" if @isDevelopment  
#     target = value
#     rescue Exception => e 
#     puts "Exception in Helper :: store -> #{e}" if @isDevelopment
#     nil
#   end

#   def pause(target, value)
#     puts "in pause--->target::#{target} value::#{value}"  if @isDevelopment 
#     sleep("#{value.to_i / 1000}.to_i")
#     rescue Exception => e 
#     puts "Exception in Helper :: pause -> #{e}" if @isDevelopment
#     nil
#   end

#   def close_alert_and_get_its_text
#     puts "in close_alert_and_get_its_text--->target::#{target} value::#{value}" if @isDevelopment  
#     alert = @driver.switch_to().alert()
#     alert_text = alert.text
#     if (@accept_next_alert) then
#       alert.accept()
#     else
#       alert.dismiss()
#     end
#     alert_text
#   ensure
#     @accept_next_alert = true
#   end

#   def open(target, value)
#     puts "[Step ] Opening #{target} "
#     puts "in open--->target::#{target} value::#{value}" if @isDevelopment  
#     #puts target.include? "lightning"
#     #puts !(@driver.current_url().include?("lightning"))
#     #puts "::::::::::::::::::"
#     #puts target.to_s.include?("lightning") && !(@driver.current_url().to_s.include?("lightning"))
#     #puts "::::::::::::::::::"

#     #puts (!(target.include? "lightning") && (@driver.current_url().include? "lightning"))
#     if (target.include?("lightning") && !(@driver.current_url().include? ("lightning"))) then
#       #puts "454545454454"
#       assert_not_nil(EnziUIUtility.switchToLightening(@driver),"error in switching to Lightning")
#     elsif (!target.include?("lightning") && (@driver.current_url().include? ("lightning"))) then
#       #puts "7878787878787"
#       assert_not_nil(EnziUIUtility.switchToClassic(@driver),'error in switching to Classic')
#     end
#     #(target.include? "lightning" && !(@driver.current_url().include? "lightning")) ? assert_not_nil(EnziUIUtility.switchToLightening(@driver),"error in switching to Lightning") : (assert_not_nil(EnziUIUtility.switchToClassic(@driver),'error in switching to Classic') if (!(target.include? "lightning") && (@driver.current_url().include? "lightning")))
#     @driver.get target
#     #puts "link opened successfully"
#     true
#   rescue Exception => e 
#     puts "Exception in Helper :: open -> #{e}" if @isDevelopment
#     nil
#   end

#   #Please provide exact app name displayed on app list
#   def go_to_app(driver, app_name)
#     puts "in go to app--->with app_name::#{app_name}" if @isDevelopment
#     #puts "switching to classic if user is in lightning"
#     isLightning = driver.current_url().include? ("lightning")
#     EnziUIUtility.switchToClassic(@driver) if isLightning
#     @wait.until {driver.find_element(:id, "tsidButton")}
#     if driver.find_element(:id, "tsidLabel").text != app_name then
#       #appButton = driver.find_elements(:id, "tsidButton")
#       addLogs("[Step ]   : Opening #{app_name} app")
#       #puts "click on tsidButton"
#       driver.find_element(:id, "tsidButton").click
#       #puts "wait for tsid-menuItems"
#       @wait.until {driver.find_element(:id, "tsid-menuItems")}
#       #puts "get links from dropdown"
#       #sleep(10)
#       #puts "789"
#       #puts driver.find_element(:id, "tsid-menuItems")
#       #puts "4587"
#       elem = driver.find_element(:id, "tsid-menuItems")
#       #puts elem.attribute(:class)
#       #puts "**--->#{app_name}"
#       #puts "xpath------>//div[@id='tsid-menuItems']/a[.='#{app_name}']"
#       @wait.until {driver.find_element(:xpath, "//div[@id='tsid-menuItems']/a[.='#{app_name}']")}
      
#       elemnt = driver.find_element(:xpath, "//div[@id='tsid-menuItems']/a[.='#{app_name}']")
#       #puts elemnt
#       #puts elemnt.text
#       #puts driver.find_element(:id, "tsid-menuItems").find_elements(:link, app_name).size
#       #puts "7869"
#       #puts driver.find_element(:id, "tsid-menuItems").find_element(:link, app_name).text
#       #puts "456"
#       #appsDrpDwn = driver.find_element(:id, "tsid-menuItems").find_elements(:link, app_name)
#       #puts "got all links"
#       #puts elemnt.size
#       #puts elemnt.nil?
#       if !elemnt.nil?
#         #puts "link found"
#         elemnt.click
#         addLogs("[Result ] : #{app_name} app opened successfully")
#       else
#         #puts "link not found---"
#         driver.find_element(:id, "tsidButton").click
#         addLogs("[Result ] : Logged in user dont have permsn to open ths app")
#         return nil
#       end
#     else
#       addLogs("[Result ] : Already on #{app_name}")
#     end
#     EnziUIUtility.switchToLightening(driver) if isLightning
#     return true
#   rescue Exception => e 
#     puts e.backtrace
#     puts "Exception in Helper :: go_to_app -> #{e} !!!" if @isDevelopment
#     nil
#   end

#   def validate_case(object,actual,expected)
#     puts "in validate_case--->target::#{target} value::#{value}" if @isDevelopment  
#     expected.keys.each do |key|
#       if actual.key? key
#         addLogs("[Validate ] : Checking #{object} : #{key}")
#         addLogs("[Expected ] : #{actual[key]}")
#         addLogs("[Actual ]   : #{expected[key]}")
#         assert_match(expected[key],actual[key])
#         addLogs("[Result ]   : #{key} checked successfully")
#         puts "------------------------------------------------------------------------"
#       end
#     end
#   end

#   # def selectFrame(target, value)
#   #   puts "in selectFrame ---->with target:: #{target} and value:: #{value}" if @isDevelopment
#   #   sleep(2)
#   #   #puts "switch to default_content"
#   #   #@driver.switch_to.default_content if (value == '')
#   #   puts "switching to parent frame---" if (target.include? 'relative=parent')
#   #   @driver.switch_to.parent_frame if (target.include? 'relative=parent')
#   #   puts "switching to frame" if @isDevelopment
#   #   @wait.until {@driver.find_elements(:tag_name, "iframe")[target.split('=')[1].to_i]}
#   #   puts 'frame found'  if @isDevelopment
    
#   #   #@driver.switch_to.frame(4);

#   #   if value != nil && value != '' then
#   #     puts "value---not nil #{value}" if @isDevelopment
#   #     #puts "switching to parent frame" if @isDevelopment
#   #     #@driver.switch_to.parent_frame
#   #     @driver.switch_to.frame(value)
#   #   else
#   #     puts "value nil" if @isDevelopment
#   #     EnziUIUtility.switchToWindow(@driver, @driver.current_url())
#   #     frameid = @driver.find_elements(:xpath, "//iframe[contains(@id,'ext-comp-')]").last.attribute('id')
#   #     puts frameid if @isDevelopment
#   #     @driver.switch_to.frame(frameid)
#   #     @wait.until {!@driver.find_element(:id, "spinner").displayed?}
#   #   end
    
#   #   #@driver.switch_to.frame("#{target.split('=')[1].to_i}");
#   #   #puts @driver.find_elements(:name, "iframe")[3].attribute("name")
#   #   #EnziUIUtility.switchToFrame(@driver, @driver.find_elements(:tag_name, "iframe")[target.split('=')[1].to_i].attribute("name"))
#   #   puts "frame selected successfully returning true"
#   #   return true
#   #   rescue Exception => e
#   #   puts "Exception in Helper :: selectFrame -> #{e}" if @isDevelopment
#   #   return nil
#   # end


#  def selectFrame(target, value)
#     puts "in selectFrame ---->with target:: #{target} and value:: #{value}" #if @isDevelopment
#     sleep(2)
#     puts (value == '') if @isDevelopment
#     @driver.switch_to.default_content if (value == '')
#     puts "switching to frame" #if @isDevelopment
#     #@wait.until {@driver.find_elements(:tag_name, "iframe")[target.split('=')[1].to_i]}
#     puts 'frame found' #if @isDevelopment
    
#     #@driver.switch_to.frame(4);

#     if value != nil && value != '' then
#       puts "value---not nil #{value}" #if @isDevelopment
#       sleep(2)
#       #@wait.until {@driver.find_element(:id,value)}
#      # @driver.switch_to.default_content
#       @driver.switch_to.frame(value)
#     else
#       puts "value nil" #if @isDevelopment
#       EnziUIUtility.switchToWindow(@driver, @driver.current_url())
#       frameid = @driver.find_elements(:xpath, "//iframe[contains(@id,'ext-comp-')]").last.attribute('id')
#       puts frameid #if @isDevelopment
#       @driver.switch_to.frame(frameid)
#       @wait.until {!@driver.find_element(:id, "spinner").displayed?}
#       puts "77777"
#     end
    
#     #@driver.switch_to.frame("#{target.split('=')[1].to_i}");
    
#     #puts @driver.find_elements(:name, "iframe")[3].attribute("name")
#     #EnziUIUtility.switchToFrame(@driver, @driver.find_elements(:tag_name, "iframe")[target.split('=')[1].to_i].attribute("name"))
#     sleep(3)
#     puts "returning true"
#     true
#     rescue Exception => e
#     puts "Exception11 in Helper :: selectFrame -> #{e} #{e.backtrace}" #if @isDevelopment
#     nil
#   end

#   def generateQuery(sObject,data)

#     #fields = @restForce.getAllFields(sObject)

#     #query = 'SELECT FROM "#{sObject}"  WHERE '


# # @helper.validate_case(
# #   @helper.instance_variable_get(:@testDataJSON)['object'],
# #   @helper.instance_variable_get(:@restforce).getRecords("SELECT #{@helper.instance_variable_get(:@testDataJSON).except(:object).except(:uniqfield).keys().join(',')} FROM #{@helper.instance_variable_get(:@testDataJSON)['object']} WHERE #{@helper.instance_variable_get(:@testDataJSON)['uniqfield']} = #{@helper.instance_variable_get(:@testDataJSON)[@helper.instance_variable_get(:@testDataJSON)['uniqfield']]}"),
# #   @helper.instance_variable_get(:@testDataJSON))
#     puts "+++++++++++++++++++++++++++++++++++++++++++++++" if @isDevelopment
#     puts "in generateQuery with sObject::#{sObject} data::#{data}" if @isDevelopment
#     puts "+++++++++++++++++++++++++++++++++++++++++++++++" if @isDevelopment

#   end


#   #generateQuery(target.gsub('.json', ''),@testDataJSON)
      

#   def assertRecords()
#     puts "in assertRecords --->" if @isDevelopment
#     puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO" if @isDevelopment
#     puts @testDataJSON if @isDevelopment
#     puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO" if @isDevelopment
#     @restForce.getAllFields(sObject)
#     #generateQuery(target.gsub('.json', ''),@testDataJSON)      
#   end 



#   def find_elements(target)
#    puts "in find_elements--->target::#{target}"  if @isDevelopment      
#    if target.include?('//') && target.include?(":") && !target.nil?
#      puts "finding element xpath contains :" 
#      if @driver.current_url().include?("lightning") && target.include?("id=")
#        puts "in lightning--->"
#        target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
#      else
#        puts "in classic--->"
#        target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
#      end
#      #@driver.current_url().include?("lightning") && target.include?("id=") && target.include?(":") ? target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,") : target = target.gsub('xpath=', '')
#      #target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
#      puts "target--->#{target}"
#      @wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
#      return @driver.find_elements(:xpath, "#{target}")
#    else
#      if target.include?('//') && !target.nil?
#        puts "finding element by xpath"
#        target = target.gsub('xpath=', '')
#        @wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
#        return @driver.find_elements(:xpath, "#{target}")
#      end
#      if @driver.current_url().include?("lightning") && target.include?("id=")
#        puts "lightning containing id="
#        element = target.split('=')
#        @wait.until {@driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]").displayed?}
#        return @driver.find_elements(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]")
#      else
#        puts "all escapes"
#        element = target.split('=')
#        puts "element--->#{element[1]}"
#        @wait.until {@driver.find_element(element[0].to_sym, element[1]).displayed?}
#        return @driver.find_elements(element[0].to_sym, element[1])
#      end
#    end
#    rescue Exception => e
#    puts "Exception in find_elements::#{e}" if @isDevelopment
#    raise e
#  end

#  def assertText(target,key_column)  #(&:selected?)
#    puts "In assertText--->target::#{target} value::#{key_column}" if @isDevelopment

#    expectedValue = ''
#    key_column.split('+').each  do |row|
#     puts "row--->#{row}"
#      if row.include? ('${')
#       # puts "11111"
#        column  = row.delete('${}')
#        puts "column--->#{column}"
#        # #puts @testDataJSON[:Lead]
#        # #puts column.split('_')[0].to_sym.class
#        puts @testDataJSON[column.split('_')[0]]
#        # #puts @testDataJSON
#        # #puts @testDataJSON[column.split('_')[0]]
#        # puts "index--->#{@index}"
#        puts @testDataJSON[column.split('_')[0]][@index]
#        # puts "11212121212121211111111111"
#        # puts @testDataJSON[column.split('_')[0]][@index][column.to_sym]
#        # puts "2222222222222222222222222222222"
#        # puts @testDataJSON[column.split('_')[0]][@index][column.to_s]
#        # puts "3333333333333333333333333333"
#        puts @testDataJSON[column.split('_')[0]][@index][column.to_s]
#        # puts "::::::::::::::::"


#        expectedValue << @testDataJSON[column.split('_')[0]][@index][column] 
#      else
#       # puts "22222"
#        expectedValue << row
#      end
#    end
#    # puts "expectedValue--->#{expectedValue}"

#    #key_column.split('${')
#    #expectedValue = @testDataJSON[key_column.delete('${}').split('_')[0]][@index].fetch(key_column.delete('${}'))
#    element = find_elements(target)    
#    element.last.tag_name == 'a' ? actualValue = element.last.text : actualValue = element.last.attribute('value')
#    puts "[Step     ] Check #{key_column.delete('${}').split('_')[1]}"
#    puts "[Expected ] #{expectedValue}"
#    puts "[Actual   ] #{actualValue}"
#    assert_match(actualValue,expectedValue)
#    puts "[Result   ] Success"
#    return true
#    rescue Exception => e 
#    puts "[Result   ] Failed" 
#    puts "Exception in Helper :: assertText -> #{e}  #{e.backtrace}" if @isDevelopment
#    return nil
#  end


#  def verifyValue(target,value)
#   puts "in verifyValue"
#    assertText(target,value)
#    return true
#  rescue Exception => e
#    puts "Exception in verifyValue::#{e}"
#    return nil
#  end

# end









require 'enziUIUtility'
require 'selenium-webdriver'
require 'faye'
require 'test/unit'
require 'yaml'
require 'csv'
require 'ordinalize'
include Test::Unit::Assertions
require_relative File.expand_path('..', Dir.pwd) + "/Gems/enziRestforce/lib/enziRestforce.rb"
require_relative File.expand_path('..', Dir.pwd) + "/Gems/RollbarUtility/rollbarUtility.rb"
require_relative File.expand_path('..', Dir.pwd) + "/Gems/EnziUIUtility/lib/enziUIUtility.rb"
require_relative File.expand_path('..', Dir.pwd) + "/Gems/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
class Helper
  def initialize()
    @isDevelopment = false
    @runId = ENV['RUN_ID']
    @objRollbar = RollbarUtility.new()
    @index = 0
    @frameID = nil
    @testData = {}
    @testDataJSON = {}
    @driver = ''
    @timeSettingMap = YAML.load_file(File.expand_path(Dir.pwd) + '/Config/timeSettings.yaml')
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
  end

  def alert_present?(driver)
    driver.switch_to.alert
    addLogs("[Result   ] : Success")
    true
   rescue Selenium::WebDriver::Error::NoAlertPresentError
    addLogs("[Result   ] : Failed")
    nil
  end

  def generateLogs(caseId)
    puts "in genenrate logs caseId--->#{caseId}"# if @isDevelopment
    if caseId.include? ':' then
        puts "fail result for record" #if @isDevelopment

        caseInfo = @testRailUtility.getCase(caseId.split(':')[0].delete('C'))
        @passedLogs[caseId].prepend(@passedLogs["C#{caseInfo['id'].to_s}"]) if (!(@runId.nil?) && !(ENV['TEMPLATE_ID'].nil?) && !(caseInfo['id'].nil?))
        @passedLogs[caseId].prepend(@passedLogs[@runId.to_i]) if !(@runId.nil?)
        @passedLogs[caseId].prepend(@passedLogs[ENV['TEMPLATE_ID']]) if (!(@runId.nil?) && !(ENV['TEMPLATE_ID'].nil?))
    elsif caseId.include? 'C' then
        puts "fail result for testCase" if @isDevelopment
        caseInfo = @testRailUtility.getCase(caseId.delete('C'))
        @passedLogs[caseId].prepend(@passedLogs[@runId.to_i]) if !(@runId.nil?)
        @passedLogs[caseId].prepend(@passedLogs[ENV['TEMPLATE_ID']]) if (!(@runId.nil?) && !(ENV['TEMPLATE_ID'].nil?))
    elsif caseId.to_s == @runId.to_s then
        puts "fail result for runId" if @isDevelopment
        @passedLogs[@runId.to_i].prepend(@passedLogs[ENV['TEMPLATE_ID']]) if (!(@runId.nil?) && !(ENV['TEMPLATE_ID'].nil?))
        caseInfo  = nil
    end

    puts "TTTTTTTTTTTttttttttttttttttttttt"
    puts @passedLogs
    puts "TTTTTTTTTTTttttttttttttttttttttt"

    return caseInfo
    rescue Exception => e
      puts "exception in generateLogs---> #{e} #{e.backtrace}" #if @isDevelopment
      return nil
  end

  def postSuccessResult(caseId)
    puts "switching back to default_content" if @isDevelopment
    addLogs("[Step     ] : posting Success result for caseId-->#{caseId}")
    @driver.switch_to.default_content
    puts "---------------------------------------------------------------------"
    puts ""
    generateLogs(caseId)
    if caseId.include? ':' then
      cId = caseId.split(':')[0].delete('C')
    elsif 
      cId = caseId.delete('C')
    end  

puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
puts @passedLogs
puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"

    @testRailUtility.postResult(cId, "Logs --> #{@passedLogs[caseId]}", 1, @runId)
    addLogs("[Result   ] : Success")
    true
   rescue Exception => e
    addLogs("[Result   ] : Failed - #{e}")
    nil
  end

  def postFailResult(exception, caseId)
    puts "in postFailResult with exception::#{exception} caseId::#{caseId}" if @isDevelopment
    @driver.switch_to.default_content
    puts "---------------------------------------------------------------------"
    addLogs("[Step     ] : posting fail result")
    addLogs("[Error    ] : #{exception}")
    begin 
      caseInfo = generateLogs(caseId)
      @objRollbar.postRollbarData(caseId, caseInfo['title'], @passedLogs[caseId])
      Rollbar.error(exception)
      puts "[Result   ] : Success"
      puts "[Step     ] : posting fail result in testRail"
      @testRailUtility.postResult(caseInfo['id'].to_s, "Result for case #{caseId} on #{@driver.browser}  is #{@passedLogs[caseId]}", 5, @runId)
      puts "[Result   ] : Success"
      puts "---------------------------------------------------------------------"
    rescue Exception => ex
      puts "[Exception] : while posting fail result : #{ex}"
      @objRollbar.postRollbarData(ENV['TEMPLATE_ID'], "demo", @passedLogs[ENV['TEMPLATE_ID']])
      Rollbar.error(exception)
    end
    rescue Exception => e
      puts "Exception in specHelper::postFailResult---> #{e} #{e.backtrace}" if @isDevelopment
      addLogs("[Result   ] : Failed")
      return nil
  end

  def addLogs(logs, caseId = nil)
    if caseId != nil then
      @passedLogs = @objRollbar.addLogs(logs, caseId)
    else
      @passedLogs = @objRollbar.addLogs(logs)
    end
  end

  def getElementByAttribute(driver, elementFindBy, elementIdentity, attributeName, attributeValue)
    puts "in accountAssignment::getElementByAttribute" if @isDevelopment
    driver.execute_script("arguments[0].scrollIntoView();", driver.find_element(elementFindBy, elementIdentity))
    puts "in getElementByAttribute #{attributeValue}" if @isDevelopment
    @driver = driver
    elements = @driver.find_elements(elementFindBy, elementIdentity)
    elements.each do |element|
      if element.attribute(attributeName) != nil then
        if element.attribute(attributeName).include? attributeValue then
          puts "element found" if @isDevelopment
          return element
          break
        end
      end
    end
  end

  def loadVars(target, value)
    addLogs("[Step     ] : #{target} loading")
    puts "in loadVars--->target::#{target} value::#{value}" if @isDevelopment   
    case File.extname(target)
      when ".csv"
        puts "Your test data is loading from csv file" if @isDevelopment
        @testDataJSON[target.gsub('.csv', '')]= CSV.open(File.expand_path('..', Dir.pwd) + "/TestData/#{target}",:encoding => "utf-8", headers: :first_row).map(&:to_h)
        #@testData = CSV.open(File.expand_path('..', Dir.pwd) + "/TestData/#{target}",:encoding => "bom|utf-8", headers: :first_row).map(&:to_h)
      when ".json"
        puts "Your test data is loading from json file" if @isDevelopment
        @testDataJSON[target.gsub('.json', '')] = JSON.parse(File.read('..',Dir.pwd+"/TestData/#{target}"))
        #@testData = JSON.parse(File.read('..',Dir.pwd+"/TestData/#{target}"))
      else
        puts "No valid testdata file found" if @isDevelopment
        return nil
    end    
    puts "testDataJSON---->#{@testDataJSON}" if @isDevelopment
    addLogs("[Result   ] : Success")
    return @testDataJSON
    rescue Exception => e
      puts "exception in loadVars--->#{e}" if @isDevelopment
      addLogs("[Result   ] : Failed- #{e}")
      nil
  end

  def find_element(target)
    puts "in find_element--->target::#{target}"  if @isDevelopment      
    if target.include?('//') && target.include?(":") && !target.include?("::") && !target.nil? 
      puts "finding element xpath contains :" if @isDevelopment
      if @driver.current_url().include?("lightning") && target.include?("id=")
        puts "in lightning--->" if @isDevelopment
        target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
      else
        puts "in classic--->" if @isDevelopment
        target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
      end
      #@driver.current_url().include?("lightning") && target.include?("id=") && target.include?(":") ? target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,") : target = target.gsub('xpath=', '')
      #target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
      puts "xpath :: #{target}" if @isDevelopment
      @wait.until {@driver.find_elements(:xpath, "#{target}").last.displayed?}
      return @driver.find_elements(:xpath, "#{target}").last
    else
      if target.include?('//') && !target.nil?
        puts "finding element by xpath" if @isDevelopment
        target = target.gsub('xpath=', '')
        puts "xpath :: #{target}" if @isDevelopment
        @wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
        puts @driver.find_elements(:xpath, "#{target}").last.text if @isDevelopment
        puts "done" if @isDevelopment
        return @driver.find_element(:xpath, "#{target}")
      end
      if target.include?("id=") && target.include?(":") && false
        puts "containing id= and :" if @isDevelopment
        element = target.split('=')
        # puts "element found"
        # #puts "text--->#{element.text}"
        # puts "^^^^^^^^^^^^^^^"
        # puts "//*[starts-with(@id, '#{element[1].split(':')[0]}')]"
        # puts "^^^^^^^^^^^^^^^^"
        puts "xpath :: //*[starts-with(@id, '#{element[1].split(':')[0]}')]" if @isDevelopment
        # kkks = @driver.find_elements(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}:')]")
        # puts kkks.length
        # kkks.each do |kkk|
        #   puts "****start*****"

        #   puts kkk.tag_name
        #   puts "****text*****"
        #   puts kkk.text
        #   puts "****val*****"
        #   puts kkk.attribute('value')
        #   puts "****class*****"
        #   puts kkk.attribute('class')
        #   puts "*****end****"

        # end
        @wait.until {@driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}:')]").displayed?}
        return @driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}:')]")
      else
        puts "all escapes" if @isDevelopment
        element = target.split('=')
        puts "find element by:#{element[0]} value:#{element[1]}" if @isDevelopment
        @wait.until {@driver.find_element(element[0].to_sym, element[1]).displayed?}
        return @driver.find_element(element[0].to_sym, element[1])
      end
    end
    rescue Exception => e
    puts "Exception in find_element::#{e} #{e.backtrace}" if @isDevelopment
    nil
  end

  def close(target,value)
    puts "in close with target : #{target} value : #{value}"
    true
    rescue Exception => e
    puts "Exception in close---> #{e}"
    nil
  end

  def click(target, value)
    puts "in click--->target::#{target} value::#{value}" if @isDevelopment
    retries ||= 0
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" if @isDevelopment
    puts "#{target.split('=')[1].delete('${}')}".split('_')[0] if target.include?('$') && target.include?('{') if @isDevelopment
    puts @testDataJSON["#{target.split('=')[1].delete('${}')}".split('_')[0]][@index] if target.include?('$') && target.include?('{') if @isDevelopment
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" if @isDevelopment

    testData1 = @testDataJSON["#{target.split('=')[1].delete('${}')}".split('_')[0]][@index] if target.include?('$') && target.include?('{')
    target = "#{target.split('=')[0]}=#{testData1["#{target.split('=')[1].delete('${}')}"]}" if target.include?('$') && target.include?('{')
    begin
      puts "wait till spinner not visible" if @isDevelopment
      @driver.find_element(:xpath, "//div[@id='spinnerContainer'] | //div[@id='spinner']")
      @wait.until {!@driver.find_element(:xpath, "//div[@id='spinnerContainer'] | //div[@id='spinner']").displayed?}
      puts "Success" if @isDevelopment
    rescue Exception => e
      puts "Exception in finding spinner--->#{e}" if @isDevelopment
      puts "spinner not present......!!!" if @isDevelopment
    end
    element = find_element(target)
    begin 
      # puts "value"
      # puts element.attribute('value')
      # puts 'text'
      # puts element.tag_name
      # puts element.text
      # puts element.attribute('value')
      
      addLogs("[Step     ] : Click on #{element.text}")  if (element.tag_name != 'select' && element.tag_name != 'svg' && element.tag_name != 'input')
      # puts element.tag_name
    rescue Exception => ex
      puts "Exception in click log :: #{ex}" if @isDevelopment      
    end    
    #@wait.until{ element.enabled? }
    puts "click on button" if @isDevelopment
    begin
      puts "wait till spinner not visible" if @isDevelopment
      @driver.find_element(:xpath, "//div[@id='spinnerContainer'] | //div[@id='spinner']")
      @wait.until {!@driver.find_element(:xpath, "//div[@id='spinnerContainer'] | //div[@id='spinner']").displayed?}
      puts "Success" if @isDevelopment
    rescue Exception => e
      puts "Exception in finding spinner--->#{e}" if @isDevelopment
      puts "spinner not present......!!!" if @isDevelopment
    end    
    element.click #if !element.nil?
    #addLogs("[Result   ] : Success")
    return true

    rescue Exception => e
    puts "Exception in click :: #{e}" if @isDevelopment
    puts "error #{e} in click trying again wait..."
    retry if (retries += 1) < 3
    addLogs("[Result   ] : Failed - #{e}")
    return nil
  end

  def type(target, value)
    puts " in type---->with target:: #{target} and value:: #{value}"  if @isDevelopment
    valueToType = value.delete('${}') if (value.include? "${")
    if ((value.include? "${") && (@testDataJSON[valueToType.split('_')[0]][@index].has_key?(valueToType)) && (value.include? "${")) then
       @testDataJSON[valueToType.split('_')[0]][@index][valueToType] = eval('"' + @testDataJSON[valueToType.split('_')[0]][@index].fetch(valueToType) + '"') 
    end
    element = find_element(target)
    if !element.nil? then
        element.clear
        puts (value.include?('$') && value.include?('{')) if @isDevelopment
        if (value.include?('$') && value.include?('{')) then
          val = @testDataJSON["#{value.delete('${}')}".split('_')[0]][@index]["#{value.delete('${}')}"]
          begin
            addLogs("[Step     ] : Entering value: #{val} in #{value.delete('${}').split('_',2)[1]}")
          rescue
            puts "exception in type logs"
            addLogs("[Step     ] : Entering value: #{val} in  #{element.text}")
          end
        else
          begin
              addLogs("[Step     ] : Entering value: #{value} ")# in  #{element.attribute('value')}")
          rescue
            puts "exception in type logs for user input value"
              addLogs("[Step     ] : Entering value: #{value}") # in  #{element.text}")
          end
        end
        (value.include?('$') && value.include?('{')) ? element.send_keys(@testDataJSON["#{value.delete('${}')}".split('_')[0]][@index]["#{value.delete('${}')}"]) : element.send_keys("#{value.to_s}")
        #addLogs("[Result   ] : Success")
        return true
    else
      puts "element not found...!!!" if @isDevelopment
      return nil
    end

    rescue Exception => e
    puts "Exception in type :: #{e} #{e.backtrace}" #if @isDevelopment
    #addLogs("[Result   ] : Failed")
    return nil
  end

  def doubleClick(target, value)
    puts "in doubleClick--->target::#{target} value::#{value}" if @isDevelopment 
    element = find_element(target)
    element.click
    element.click
    addLogs("[Result   ] : Success")
  end

  def waitForElementPresent(target, value)
    puts "in waitForElementPresent--->target::#{target} value::#{value}" if @isDevelopment
    find_element(target)
    addLogs("[Result   ] : Success")
  end

  def select(target, value)
    puts "in select --->>with target:: #{target} and value:: #{value}" if @isDevelopment
    begin
      puts "wait till spinner not visible" if @isDevelopment
      @driver.find_element(:xpath, "//div[@id='spinnerContainer'] | //div[@id='spinner']")
      @wait.until {!@driver.find_element(:xpath, "//div[@id='spinnerContainer'] | //div[@id='spinner']").displayed?}
      puts "Success" if @isDevelopment
    rescue Exception => e
      puts "Exception in finding spinner--->#{e}" if @isDevelopment
      puts "spinner not present......!!!" if @isDevelopment
    end
    element = find_element(target)
    
    val1 = value.split('=')[1]
    #puts (value.split('=')[0] == 'label')

    (value.split('=')[0] == 'label') ?  selectBy = 'text' : selectBy = 'index'
    #puts "selectBy --->#{selectBy}"
    if (val1.include?('$') && val1.include?('{')) then
      puts "take value from json" if @isDevelopment
      val = "#{val1.delete('${}')}"
      valueToSelect = @testDataJSON[val.split('_')[0]][@index]["#{val}"]
      log = "Selecting values : #{valueToSelect} for #{val.split('_',2)[1]}"
    else
      puts "selected by users" if @isDevelopment
      valueToSelect = val1
      # puts "****************************"
      # puts element.text
      # puts element.text.split(/\n+/).class
      # puts element.text.split(/\n+/).size
      # puts "****************************"
      selectBy == 'text' ? log = "Selecting values : #{valueToSelect}" : ((element.text.split(/\n+/).size > valueToSelect.to_i) ? log = "Selecting #{valueToSelect.to_i.ordinalize} value :"+element.text.split(/\n+/)[valueToSelect.to_i] : log = "Required index not present")
    end
      puts "value to select---->#{valueToSelect}" if @isDevelopment
    if target.include?('//') && !target.nil?
      #element = find_element(target)
      # puts "****************************"
      # puts element.text.class
      # puts "****************************"
      # puts element.attribute('value')
      # puts "****************************"
      addLogs("[Step     ] : #{log}")
      # puts "****************************"

      Selenium::WebDriver::Support::Select.new(element).select_by(selectBy.to_sym, valueToSelect)
      #addLogs("[Result   ] : Success")
      return true
    else
      #element = find_element(target)
      # puts "*************222222222***************"
      # puts element.text.class
      # puts "****************************"
      # puts element.text.split(/\n+/).class
      # puts element.text.split(/\n+/)
      # puts "****************************"
      # puts element.attribute('value')
      # puts "****************************"
      addLogs("[Step     ] : #{log}")
      # puts "****************************"
      (!valueToSelect.nil? && (valueToSelect != '')) ? Selenium::WebDriver::Support::Select.new(element).select_by(selectBy.to_sym, valueToSelect) : (puts "value to select got nil"; return true;)
      addLogs("[Result   ] : Success")
      return true
    end
    rescue Exception => e
    puts "Exception in select :: #{e}" #if @isDevelopment
    addLogs("[Result   ] : Failed")
    return nil
  end

  def selectWindow(target, value)
    puts "in selectWindow--->target::#{target} value::#{value}" if @isDevelopment 
    @driver.window_handles
    if target == 'win_ser_local' then
      puts "switching to parent window" if @isDevelopment
      @driver.switch_to.window @driver.window_handles.first
   	  @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}

      addLogs("[Result   ] : Success") if @isDevelopment
    else
      puts "switching to current open window" if @isDevelopment
      @driver.window_handles
      #@driver.window_handles
      #target[target.length - 1]
      @driver.switch_to.window @driver.window_handles.last
   	  @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
      addLogs("[Result   ] : Success") if @isDevelopment
    end 
    true
  rescue Exception => e
    puts "Exception in selectWindow : #{e}"
    nil
  end

  def openWindow(target, value)
    puts "in openWindow--->target::#{target} value::#{value}" if @isDevelopment
    @driver.get target
    addLogs("[Result   ] : Success")
  end

  def lightening_click_row(target, value)
    puts "in lightening_click_row--->target::#{target} value::#{value}" if @isDevelopment
    @wait.until {@driver.find_element(:xpath, "//span[contains(text(),#{target})]/../../../../../..").displayed?}
    @driver.find_element(:xpath, "//span[contains(text(),#{target})]/../../../../../..").find_elements(:tag_name, 'tr')[value.to_i].find_elements(:tag_name, 'td')[2].find_elements(:tag_name, 'a')[0].click
    addLogs("[Result   ] : Success")
  end

  def lightening_assert_form_element(target, value)
    puts "in lightening_assert_form_element--->target::#{target} value::#{value}" if @isDevelopment 
    xpath = "//span[./text()=#{target}]/../following-sibling::div/descendant::"
    @wait.until {@driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").displayed?}
    puts @driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").text if @isDevelopment
    assert_match(value, @driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").text)
    addLogs("[Result   ] : Success")
  end

  def moreAction(target, value)
    puts "in moreAction--->target::#{target} value::#{value}" if @isDevelopment
    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
    frameid = @driver.find_elements(:xpath, "//iframe[contains(@id,'ext-comp-')]")[1].attribute('id')
    @driver.switch_to.frame(frameid)
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    @driver.find_element(:id,'actionDropdown').click
    addLogs("[Result   ] : Success")
    return frameid

    rescue Exception => e
     puts "Exception in moreAction---->#{e}" if @isDevelopment
     addLogs("[Result   ] : Failed")
     return nil   
  end

  def lightening_type(target, value)
    puts "in lightening_type--->target::#{target} value::#{value}" if @isDevelopment  
    @testDataJSON["#{value.delete('${}')}"] = eval('"' + @testDataJSON.fetch("#{value.delete('${}')}") + '"') if @testDataJSON.has_key?("#{value.delete('${}')}")
    puts @testDataJSON["#{value.delete('${}')}"] if @isDevelopment
    target.include?('list') ? target = "//label[./text()= '#{target.split(':')[0]}']/../parent::div//input | //span[./text()= '#{target.split(':')[0]}']/../parent::div//input" : target = "//span[./text()= '#{target}']/../following-sibling::input"
    @wait.until {@driver.find_element(:xpath, target).displayed?}
    @driver.find_element(:xpath, target).clear
    (value.include?('$') && value.include?('{')) ? @driver.find_element(:xpath, target).send_keys(@testDataJSON["#{value.delete('${}')}"]) : @driver.find_element(:xpath, target).send_keys("#{value.to_s}")
    addLogs("[Result   ] : Success")
  end

  def lightening_click(target, value)
    puts "in lightening_click--->target::#{target} value::#{value}" if @isDevelopment 
    puts target if @isDevelopment
    target = target.split('id=')[1].split(':')[0] if (target.include?("id=") && target.include?(':'))
    @wait.until {@driver.find_element(:xpath, "//a[@title='#{target}'] | //button[@title='#{target}']| //*[starts-with(@id,'#{target}')] | //button/span[./text()='#{target}'] | //span[./text()= '#{target}']/../preceding-sibling::input").displayed?}
    @driver.find_element(:xpath, "//a[@title='#{target}'] | //button[@title='#{target}']| //*[starts-with(@id,'#{target}')] | //button/span[./text()='#{target}'] | //span[./text()= '#{target}']/../preceding-sibling::input").click
    addLogs("[Result   ] : Success")
  end

  def lightening_select(target, value)
    puts "in lightening_select--->target::#{target} value::#{value}" if @isDevelopment 
    value = "label=#{@testDataJSON.fetch(value.delete('${}').gsub('label=', ''))}" if (value.include?('$') && value.include?('{'))
    @wait.until {@driver.find_element(:xpath, "//option[@value='" + value.split('label=')[1] + "'] | //li[@title='" + value.split('label=')[1] + "']").displayed?}
    @driver.find_element(:xpath, "//option[@value='" + value.split('label=')[1] + "'] | //li[@title='" + value.split('label=')[1] + "']").click
    addLogs("[Result   ] : Success")
  end

  def date_picker(target, value)
    puts "In date picker --->with target::#{target} value::#{value}" if @isDevelopment   
    @wait.until {@driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0].split('_')[1]}']/../parent::div//input")}
    @driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0].split('_')[1]}']/../parent::div//input").click
    @wait.until {@driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0].split('_')[1]}']/../parent::div//table//span[@id='#{(value.include?('+')) ? (Date.today + value.split('+')[1].to_i).to_s : Date.today.to_s}']")}
    @driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0].split('_')[1]}']/../parent::div//table//span[@id='#{(value.include?('+')) ? (Date.today + value.split('+')[1].to_i).to_s : Date.today.to_s}']").click
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    @testDataJSON[target.split('_')[0]][@index]["#{target}"] = value.include?('+') ? (Date.today + value.split('+')[1].to_i).to_s : Date.today.to_s
    addLogs("[Step     ] : Selecting date #{@testDataJSON[target.split('_')[0]][@index]["#{target}"]}")
    addLogs("[Result   ] : Success")
    return true

    rescue Exception => e
    addLogs("[Result   ] : Failed")
    puts "Exception in date_picker :: #{e}"
    return nil
  end

  def wait(target, value)
    puts "in wait--->target::#{target} value::#{value}" if @isDevelopment
    value.eql?('true') ? @wait.until {@driver.find_element(target.split('=')[0].to_sym, target.split('=')[1]).displayed?} : @wait.until {!@driver.find_element(target.split('=')[0].to_sym, target.split('=')[1]).displayed?}
    addLogs("[Result   ] : Success")
  end

  def login(envCredential)
    puts "in login--->envCredential::#{envCredential}" if @isDevelopment
    pwd = EnziEncryptor.decrypt(JSON.parse(envCredential.fetch('parameters'))['password'], ENV['KEY'].chop.chop)
    @driver.get 'https://test.salesforce.com/'
    puts "go to https://test.salesforce.com/" if @isDevelopment
    #@driver.get JSON.parse(envCredential.fetch('parameters'))['url']
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    puts "enter username" if @isDevelopment
    @driver.find_element(:xpath, "//input[contains(@id,'name')]").clear
    @driver.find_element(:xpath, "//input[contains(@id,'name')]").send_keys JSON.parse(envCredential.fetch('parameters'))['username']
    puts "enter pwd" if @isDevelopment
    @driver.find_element(:xpath, "//input[contains(@id,'password')]").clear
    @driver.find_element(:xpath, "//input[contains(@id,'password')]").send_keys pwd
    puts "click on submit" if @isDevelopment
    @driver.find_element(:xpath, "//input[contains(@type,'submit')] | //button[contains(@type,'submit')]").click
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    puts "wait for search box" if @isDevelopment
    @wait.until {@driver.find_element(:xpath, "//*[@title='Search Salesforce'] | //*[@id='phSearchInput']").displayed?}
    
    puts "switching to classic....." if @isDevelopment
    puts @driver.current_url() if @isDevelopment
    assert_not_nil(EnziUIUtility.switchToClassic(@driver),"[Error   ] : Error in switching to classic") if (@driver.current_url().include? "lightning")
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    addLogs("[Result   ] : Success")
    true

    rescue Exception => e 
    addLogs("[Result   ] : Failed")
    addLogs("[Error    ] : #{e} #{e.backtrace}")
    nil
  end

  def loginAsGivenProfile(record)
    puts "in loginAsGivenProfile---->record::#{record}" if @isDevelopment
    #puts record.fetch('profile')['id']
    EnziUIUtility.switchToClassic(@driver) if (@driver.current_url().include? "lightning")
    
    newUrl = @driver.current_url().split('/')
    #puts newUrl
    @driver.get "#{newUrl[0]}//#{newUrl[2]}/" + "005?id=" + "#{record.fetch('profile')['id']}" if record.has_key?('profile')

    @driver.get "#{newUrl[0]}//#{newUrl[2]}/" + "#{record.fetch('user')['id']}" + "?noredirect=1&isUserEntityOverride=1" if record.has_key?('user')

    #puts "go to #{@driver.current_url()}"
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    if record.has_key?('profile')
      puts "login for profile" if @isDevelopment
      @wait.until {@driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[2]/td[1]/a[2]").displayed?}
      @driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[2]/td[1]/a[2]").click
      puts "done"  if @isDevelopment
    elsif record.has_key?('user')
      puts "login for user"  if @isDevelopment    
      @wait.until {@driver.find_element(:xpath, "//input[@name='login']").displayed?}
      @driver.find_element(:xpath, "//input[@name='login']").click      
      puts "done"  if @isDevelopment
    end
    #EnziUIUtility.switchToClassic(@driver)
    #EnziUIUtility.switchToLightening(@driver)
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    addLogs("[Result   ] : Success")
    true
    rescue Exception => e 
    addLogs("[Result   ] : Failed")
    puts "Exception in Helper :: loginAsGivenrecord -> #{e} #{e.backtrace}" if @isDevelopment
    nil
  end

  def logOutGivenProfile()
    addLogs("[Step     ] : Logged Out from current user")
    addLogs("in Helper :: logOutGivenProfile") if @isDevelopment
    #puts @driver.current_url
    url = @driver.current_url.split('force.com')[0].to_s
    finalURL = url+"force.com/home/home.jsp"
    puts "finalURL--->#{finalURL}" if @isDevelopment

    @driver.get finalURL
    @wait.until {@driver.find_element(:xpath, "//*[@title='Search Salesforce'] | //*[@id='phSearchInput']").displayed?}
    
    if !(@driver.current_url.include? 'lightning') then
      puts "not lightning"  if @isDevelopment
      #puts "sleep for 10sec"
      #sleep(10)
      @wait.until {@driver.find_element(:xpath, "//*[@id='userNav-arrow']").displayed?}
      @driver.find_element(:xpath, "//*[@id='userNav-arrow']").click
    end
    @wait.until {@driver.find_element(:xpath, "//a[@href='/secur/logout.jsp']").displayed?}
    @driver.find_element(:xpath, "//a[@href='/secur/logout.jsp']").click
    addLogs("[Result   ] : Success")
    return true
    rescue Exception => e 
    addLogs("[Result   ] : Failed")
    puts "Exception in Helper :: logOutGivenProfile -> #{e}" if @isDevelopment
    return nil
  end

  def echo(target, value)
    puts "in echo--->target::#{target} value::#{value}" if @isDevelopment 
    puts !value.nil? 
    (!value.nil? && value != '') ? addLogs(target, value) : addLogs(target)
    rescue Exception => e 
      addLogs("[Result   ] : Failed")
    puts "Exception in Helper :: echo -> #{e}" if @isDevelopment
    nil
  end

  def store(target, value)
    puts "in store--->target::#{target} value::#{value}" if @isDevelopment  
    target = value
    rescue Exception => e
    addLogs("[Result   ] : Failed") 
    puts "Exception in Helper :: store -> #{e}" if @isDevelopment
    nil
  end

  def pause(target, value)
    puts "in pause--->target::#{target} value::#{value}"  if @isDevelopment 
    puts "[Step     ] : Sleep for #{target.to_i / 1000} sec"
    sleep(target.to_i / 1000)
    #addLogs("[Result   ] : Success")
    return true
    rescue Exception => e 
    puts "Exception in Helper :: pause -> #{e}" if @isDevelopment
    addLogs("[Result   ] : Failed")
    nil
  end

  def close_alert_and_get_its_text
    puts "in close_alert_and_get_its_text--->target::#{target} value::#{value}" if @isDevelopment  
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
    ensure
    @accept_next_alert = true
  end

  def open(target, value)
    addLogs("[Step     ] : Opening #{target} ")
    puts "in open--->target::#{target} value::#{value}" if @isDevelopment  
    #puts target.include? "lightning"
    #puts !(@driver.current_url().include?("lightning"))
    #puts "::::::::::::::::::"
    #puts target.to_s.include?("lightning") && !(@driver.current_url().to_s.include?("lightning"))
    #puts "::::::::::::::::::"

    #puts (!(target.include? "lightning") && (@driver.current_url().include? "lightning"))
    if (target.include?("lightning") && !(@driver.current_url().include? ("lightning"))) then
      #puts "454545454454"
      #assert_not_nil(EnziUIUtility.switchToLightening(@driver),"error in switching to Lightning")
    elsif (!target.include?("lightning") && (@driver.current_url().include? ("lightning"))) then
      #puts "7878787878787"
      #assert_not_nil(EnziUIUtility.switchToClassic(@driver),'error in switching to Classic')
    end
    #(target.include? "lightning" && !(@driver.current_url().include? "lightning")) ? assert_not_nil(EnziUIUtility.switchToLightening(@driver),"error in switching to Lightning") : (assert_not_nil(EnziUIUtility.switchToClassic(@driver),'error in switching to Classic') if (!(target.include? "lightning") && (@driver.current_url().include? "lightning")))
    @driver.get target
    addLogs("[Result   ] : Success")
    true

    rescue Exception => e 
    puts "Exception in Helper :: open -> #{e}" if @isDevelopment
    addLogs("[Result   ] : Failed")
    nil
  end

  #Please provide exact app name displayed on app list
  def go_to_app(driver, app_name)
    puts "in go to app--->with app_name::#{app_name}" if @isDevelopment
    #puts "switching to classic if user is in lightning"
    isLightning = driver.current_url().include? ("lightning")
    EnziUIUtility.switchToClassic(@driver) if isLightning
    @wait.until {driver.find_element(:id, "tsidButton")}
    if driver.find_element(:id, "tsidLabel").text != app_name then
      #appButton = driver.find_elements(:id, "tsidButton")
      addLogs("[Step ]   : Opening #{app_name} app")
      #puts "click on tsidButton"
      driver.find_element(:id, "tsidButton").click
      #puts "wait for tsid-menuItems"
      @wait.until {driver.find_element(:id, "tsid-menuItems")}
      #puts "get links from dropdown"
      #sleep(10)
      #puts "789"
      #puts driver.find_element(:id, "tsid-menuItems")
      #puts "4587"
      elem = driver.find_element(:id, "tsid-menuItems")
      #puts elem.attribute(:class)
      #puts "**--->#{app_name}"
      #puts "xpath------>//div[@id='tsid-menuItems']/a[.='#{app_name}']"
      @wait.until {driver.find_element(:xpath, "//div[@id='tsid-menuItems']/a[.='#{app_name}']")}
      
      elemnt = driver.find_element(:xpath, "//div[@id='tsid-menuItems']/a[.='#{app_name}']")
      #puts elemnt
      #puts elemnt.text
      #puts driver.find_element(:id, "tsid-menuItems").find_elements(:link, app_name).size
      #puts "7869"
      #puts driver.find_element(:id, "tsid-menuItems").find_element(:link, app_name).text
      #puts "456"
      #appsDrpDwn = driver.find_element(:id, "tsid-menuItems").find_elements(:link, app_name)
      #puts "got all links"
      #puts elemnt.size
      #puts elemnt.nil?
      if !elemnt.nil?
        #puts "link found"
        elemnt.click
        addLogs("[Result ] : #{app_name} app opened Successfully")
      else
        #puts "link not found---"
        driver.find_element(:id, "tsidButton").click
        addLogs("[Result ] : Logged in user dont have permsn to open ths app")
        return nil
      end
    else
      addLogs("[Result ] : Already on #{app_name}")
    end
    EnziUIUtility.switchToLightening(driver) if isLightning
    addLogs("[Result   ] : Success")
    return true
    rescue Exception => e 
    addLogs("[Result   ] : Failed")
    puts "Exception in Helper :: go_to_app -> #{e} !!!" if @isDevelopment
    nil
  end

  def validate_case(object,actual,expected)
    puts "in validate_case--->target::#{target} value::#{value}" if @isDevelopment  
    expected.keys.each do |key|
      if actual.key? key
        addLogs("[Validate ] : Checking #{object} : #{key}")
        addLogs("[Expected ] : #{actual[key]}")
        addLogs("[Actual ]   : #{expected[key]}")
        assert_match(expected[key],actual[key])
        addLogs("[Result ]   : #{key} checked Successfully")
        puts "------------------------------------------------------------------------"
      end
    end
  end

  
  def selectFrame(target, value)
  	sleep(3)
    puts "in selectFrame ---->with target:: #{target} and value:: #{value}" if @isDevelopment
    puts (value == '') if @isDevelopment
    @driver.switch_to.default_content if (value == '')
    puts "switching to frame" if @isDevelopment
    @wait.until {@driver.find_elements(:tag_name, "iframe")[target.split('=')[1].to_i]}
    puts 'frame found' if @isDevelopment    
    if value != nil && value != '' then
      puts "value---not nil #{value}" if @isDevelopment      
      @frameID = value
      @driver.switch_to.frame(value)
    else
      puts "value nil" if @isDevelopment
      EnziUIUtility.switchToWindow(@driver, @driver.current_url())
      frameid = @driver.find_elements(:xpath, "//iframe[contains(@id,'ext-comp-')]").last.attribute('id')
      puts frameid if @isDevelopment
      @driver.switch_to.frame(frameid)
      @frameID = frameid
      @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    end    
    sleep(5)
    true

    rescue Exception => e
    #addLogs("[Result   ] : Failed")
    puts "Exception in Helper :: selectFrame -> #{e} #{e.backtrace}" if @isDevelopment
    nil
  end

  def assertRecords()
    puts "in assertRecords --->" if @isDevelopment
    puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO" if @isDevelopment
    puts @testDataJSON if @isDevelopment
    puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO" if @isDevelopment
    @restForce.getAllFields(sObject)
    #generateQuery(target.gsub('.json', ''),@testDataJSON)      
  end 

  def find_elements(target)
    puts "in find_elements--->target::#{target}"  #if @isDevelopment      
    if target.include?('//') && target.include?(":") && !target.nil? && !target.include?("::")
      puts "finding element xpath contains :" 
      if @driver.current_url().include?("lightning") && target.include?("id=")
        puts "in lightning--->" #if @isDevelopment
        target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
      else
        puts "in classic--->" #if @isDevelopment
        target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
      end
      #@driver.current_url().include?("lightning") && target.include?("id=") && target.include?(":") ? target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,") : target = target.gsub('xpath=', '')
      #target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
      puts "target--->#{target}" #if @isDevelopment
      @wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
      return @driver.find_elements(:xpath, "#{target}")
    else
      if target.include?('//') && !target.nil?
        puts "finding element by xpath" #if @isDevelopment
        target = target.gsub('xpath=', '')
        puts "target--->#{target}" #if @isDevelopment
        #@wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
        return @driver.find_elements(:xpath, "#{target}")
      end
      if @driver.current_url().include?("lightning") && target.include?("id=")
        puts "lightning containing id=" #if @isDevelopment
        element = target.split('=')
        @wait.until {@driver.find_elements(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]").last.displayed?}
        return @driver.find_elements(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]")
      else
        puts "all escapes" if @isDevelopment
        puts "sleep 5"
        sleep(5)
        element = target.split('=')
        puts "element--->#{element[1]}" #if @isDevelopment
        kkks  = @driver.find_elements(element[0].to_sym, element[1])
        puts kkks.class
        puts kkks.length
        @wait.until {@driver.find_element(element[0].to_sym, element[1]).displayed?}
        kkks.each do |kkk|
        	puts "******************************"
        	puts "text --->#{kkk.text}"
        	puts "value ---->#{kkk.attribute('value')}"
        	puts "tagname--->#{kkk.tag_name}"
        	puts "*******************************"
        end
        #@wait.until {@driver.find_element(element[0].to_sym, element[1]).displayed?}
        #return @driver.find_elements(element[0].to_sym, element[1])
        return kkks
      end
    end
    rescue Exception => e
    puts "Exception in find_elements::#{e}#{e.backtrace}" #if @isDevelopment
    return nil
  end

  def verifyValue(target,value)
    assertText(target,value)
    return true
    rescue Exception => e
    addLogs("[Result   ] : Failed")
    puts "Exception in verifyValue::#{e}"
    return nil
  end

  def assertText(target,key_column)  #(&:selected?)
  	#sleep(10)
    puts "In assertText--->target::#{target} value::#{key_column}" if @isDevelopment
    expectedValue = ''
    key_column.split('+').each  do |row|
      if row.include? ('${')
        column  = row.delete('${}')
        expectedValue << @testDataJSON[column.split('_')[0]][@index][column] 
      else
        expectedValue << row
      end
    end
    puts "expectedValue--->#{expectedValue}" if @isDevelopment
    #key_column.split('${')
    #expectedValue = @testDataJSON[key_column.delete('${}').split('_')[0]][@index].fetch(key_column.delete('${}'))
    element = find_elements(target)    
    puts "*****************length****************************"
    puts element.length
    # puts "******************value****************************"
    # puts element.first.attribute('value')
    # puts "******************text****************************"
    # puts element.first.text
    # puts element.first.tag_name

    # puts "**********************************************"
    ((element.last.tag_name == 'a') | (element.last.tag_name == 'span')) ? actualValue = element.last.text : actualValue = element.last.attribute('value') if element.length > 1
    ((element.first.tag_name == 'a') | (element.first.tag_name == 'span')) ? actualValue = element.first.text : actualValue = element.first.attribute('value') if element.length == 1

    addLogs("[Step     ] : Check #{key_column.delete('${}').split('_')[1]}")
    addLogs("[Expected ] : #{expectedValue}")
    addLogs("[Actual   ] : #{actualValue}")
    assert_match(actualValue,expectedValue)
    addLogs("[Result   ] : Success")
    puts "--------------********************-------------------"
    puts @passedLogs
    puts "--------------********************-------------------"

    return true

    rescue Exception => e 
    addLogs("[Result   ] : Failed") 
    puts "Exception in Helper :: assertText -> #{e} #{e.backtrace}" if @isDevelopment
    return nil
  end

  def alert (target,value)
    puts "in alert --------with target::#{target} value::#{value}"
    @driver.switch_to.default_content
    @driver.execute_script("window.alert('I am an alert box!');");    #    .showModalDialog = window.openWindow;");
    sleep(5)
    alert = @driver.switch_to().alert();
    sleep(2)
    alert.accept();
    sleep(3)
    puts @frameID
    @driver.switch_to.frame(@frameID)
    addLogs("[Result   ] : Success")
    true
    rescue Exception => e
      addLogs("[Result   ] : Failed")
    puts "Exception in Helper :: alert -> #{e}"
    nil
  end

  def assertTitle(target,value)
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    addLogs("[Step     ] : Check Title of current page")
    addLogs("[Expected ] : #{target}")
    addLogs("[Actual   ] : #{@driver.title}")
    if (/Console$/ === @driver.title) then
      addLogs("[Result   ] : Success")
      return true
    else
      raise Exception,'not in sales onsole'
      #return nil
    end
    true      
    rescue Exception => e
    addLogs("[Result   ] : Failed - #{e}")
    #puts "Exception in Helper :: assertTitle -> #{e}"
    nil
  end

end




