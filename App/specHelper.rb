require 'enziUIUtility'
require 'selenium-webdriver'
require 'faye'
require 'test/unit'
require 'yaml'
require 'csv'
include Test::Unit::Assertions
require_relative File.expand_path('..', Dir.pwd) + "/Gems/enziRestforce/lib/enziRestforce.rb"
require_relative File.expand_path('..', Dir.pwd) + "/Gems/RollbarUtility/rollbarUtility.rb"
require_relative File.expand_path('..', Dir.pwd) + "/Gems/EnziUIUtility/lib/enziUIUtility.rb"
require_relative File.expand_path('..', Dir.pwd) + "/Gems/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
class Helper
  def initialize()
    @runId = ENV['RUN_ID']
    @objRollbar = RollbarUtility.new()
    @testDataJSON = {}
    @driver = ''
    @timeSettingMap = YAML.load_file(File.expand_path(Dir.pwd) + '/Config/timeSettings.yaml')
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
  end

  def alert_present?(driver)
    driver.switch_to.alert
    true
   rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end

  def self.addRecordsToDelete(key, value)
    if EnziRestforce.class_variable_get(:@@createdRecordsIds).key?("#{key}") then
      EnziRestforce.class_variable_get(:@@createdRecordsIds)["#{key}"] << Hash["Id" => value]
    else
      EnziRestforce.class_variable_get(:@@createdRecordsIds)["#{key}"] = [Hash["Id" => value]]
    end
  end

  def postSuccessResult(caseId)
    puts "----------------------------------------------------------------------------------"
    @testRailUtility.postResult(caseId, "Pass on #{@driver.browser}", 1, @runId)
    @passedLogs = @objRollbar.addLogs("[Result  ]  Success")
    puts "----------------------------------------------------------------------------------"
    return true
    rescue Exception => e
    #puts "Exception in Helper :: postSuccessResult---> #{e}"
    return nil    
  end

  def postFailResult(exception, caseId)
    puts "----------------------------------------------------------------------------------"
    caseInfo = @testRailUtility.getCase(caseId)
    @passedLogs = @objRollbar.addLogs("[Result  ]  Failed")
    @passedLogs = @objRollbar.addLogs("#{exception}")
    @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], @passedLogs[caseInfo['id'].to_s])
    Rollbar.error(exception)
    @testRailUtility.postResult(caseId, "Result for case #{caseId} on #{@driver.browser}  is #{@passedLogs[caseInfo['id'].to_s]}", 5, @runId)
    puts "----------------------------------------------------------------------------------"
    return true
    rescue Exception => e
    #puts "Exception in Helper :: postFailResult---> #{e}"
    return nil 
  end

  def addLogs(logs, caseId = nil)
    if caseId != nil then
      @passedLogs = @objRollbar.addLogs(logs, caseId)
    else
      @passedLogs = @objRollbar.addLogs(logs)
    end
    return true
    rescue Exception => e
    #puts "Exception in Helper :: addLogs---> #{e}"
    return nil 
  end

  def getSalesforceRecord(sObject, query)
    puts query
    result = Salesforce.getRecords(@salesforceBulk, "#{sObject}", "#{query}", nil)
    #puts "#{sObject} created => #{result.result.records}"
    return result.result.records
   rescue Exception => e
    puts e
    puts "No record found111111"
    return nil
  end

  def createSalesforceRecord(objectType, records_to_insert)
    Salesforce.createRecords(@salesforceBulk, objectType, records_to_insert)
    return true
    rescue Exception => e
    puts "Exception in Helper :: createSalesforceRecord---> #{e}"
    return nil 
  end

  def getRestforceObj()
    return @restForce
  end

  def getSalesforceRecordByRestforce(query)
    #puts query
    record = @restForce.getRecords("#{query}")
    if record.size > 1 then
      puts "Multiple records handle carefully....!!!"
    elsif record.size == 0 then
      puts "No record found....!!!"
      return nil
    end
    #puts record[0].attrs['Id']
    return record
   rescue Exception => e
    puts e
    return nil
  end

  def deleteSalesforceRecordBySfbulk(sObject, recordsToDelete)
    #puts recordsToDelete
    result = Salesforce.deleteRecords(@salesforceBulk, sObject, recordsToDelete)
    puts "record deleted===> #{result}"
    puts result
    return true
    rescue Exception => e
    puts e
    return nil
  end

  def getElementByAttribute(driver, elementFindBy, elementIdentity, attributeName, attributeValue)
    puts "in accountAssignment::getElementByAttribute"
    driver.execute_script("arguments[0].scrollIntoView();", driver.find_element(elementFindBy, elementIdentity))
    puts "in getElementByAttribute #{attributeValue}"
    @driver = driver
    elements = @driver.find_elements(elementFindBy, elementIdentity)
    elements.each do |element|
      if element.attribute(attributeName) != nil then
        if element.attribute(attributeName).include? attributeValue then
          puts "element found"
          return element
          break
        end
      end
    end
  end

  def update_campaign(id, lead_owner = nil, email = nil, city = nil)
    @restForce.updateRecord("Campaign", {"Id" => id, "Lead_Owner__c" => lead_owner, "Email_Address__c" => email, "City__c" => city})
  end

  def getExistingLead(from, to, owner = nil, checkForActivity = nil)
    index = from
    userHasPermission = false
    owner = " AND CreatedBy.Name = '#{owner}'" if !owner.nil?
    checkForActivity = "(SELECT id FROM tasks)," if !checkForActivity.nil?
    if !from.nil? || !to.nil?
      leadInfo = @restForce.getRecords("SELECT id , #{checkForActivity} Owner.Name,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate < #{from} AND CreatedDate  = LAST_N_DAYS:#{to} AND  isDeleted = false #{owner}")
      allowedUsers = JSON.parse(@settings[3]['Data__c'])['allowedUsers']
      leadInfo.each do |lead|
        if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
          userHasPermission = true
          leadInfo = lead
          break;
        end
      end
      if leadInfo.nil?
        until !(index < to) || userHasPermission
          if leadInfo[0].nil?
            leadInfo = @restForce.getRecords("SELECT id , Owner.Name, Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:#{index} AND isDeleted = false #{owner}")
            leadInfo.each do |lead|
              if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
                userHasPermission = true
                leadInfo = lead
                break;
              end
            end
          end
        end
      else
        leadInfo.each do |lead|
          if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
            userHasPermission = true
            leadInfo = lead
            break;
          end
        end
      end
      index += 1
    else
      puts "Getting Records....."
      leadInfo = @restForce.getRecords("SELECT id , #{checkForActivity} Owner.Name,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email like '%@example.com' AND isConverted = false AND isDeleted = false #{owner} LIMIT 10")
    end
    leadInfo if !leadInfo.nil?
  end

  def createPushTopic(name, query)
    # Create a PushTopic for subscribing to record changes.
    client.upsert! 'PushTopic', {
        ApiVersion: '23.0',
        Name: name,
        Description: 'Monitoring ',
        NotifyForOperations: 'All',
        NotifyForFields: 'All',
        Query: query
    }
  end

  def loadVars(target, value)
    #puts "in loadVars"
    lines = CSV.open(File.expand_path('..', Dir.pwd) + "/TestData/#{target}", :encoding => "ISO-8859-1", :liberal_parsing => true).readlines
    keys = lines.delete lines.first
    File.open('testData.json', 'a+') do |f|
      data = lines.map do |values|
        Hash[keys.zip(values)]
      end
      f.puts JSON.pretty_generate(data)
      @testDataJSON[target.gsub('.csv', '')] = JSON.parse(JSON.pretty_generate(data))[0]
    end
    @testDataJSON = @testDataJSON[target.gsub('.csv', '')]
    #puts @testDataJSON
    return true
    rescue Exception => e
    #puts "Exception in Helper :: loadVars--> #{e}"
    return nil
  end

  def find_element(target)
    #puts "in find_element"      
    if target.include?('//') && !target.nil?
      @driver.current_url().include?("lightning") && target.include?("id=") && target.include?(":") ? target = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,") : target = target.gsub('xpath=', '')
      @wait.until {@driver.find_element(:xpath, "#{target}").displayed?}
      return @driver.find_element(:xpath, "#{target}")
    else
      if @driver.current_url().include?("lightning") && target.include?("id=")
        element = target.split('=')
        @wait.until {@driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]").displayed?}
        return @driver.find_element(:xpath, "//*[starts-with(@id, '#{element[1].split(':')[0]}')]")
      else
        element = target.split('=')
        @wait.until {@driver.find_element(element[0].to_sym, element[1]).displayed?}
        return @driver.find_element(element[0].to_sym, element[1])
      end
    end
    rescue Exception => e
    #puts "Exception in find_element::#{e}"
    #raise e
  end

  def click(target, value)
    retries ||= 0    
    #puts "in click----with target:: #{target} ------:::::: #{retries}"
    target = "#{target.split('=')[0]}=#{@testDataJSON["#{target.split('=')[1].delete('${}')}"]}" if target.include?('$') && target.include?('{')
    element = find_element(target)
    #puts element.click.class
    #puts element.displayed?
    #puts element.enabled?
    #@wait.until { element.displayed?}
    #@wait.untill{ element.enabled? }
    #puts "click on button"
    sleep(2)
    #@wait.until {@driver.find_elements(:xpath, "//*[contains(@id,'spinner')]")[0].displayed?}
    element.click if !element.nil?
    #puts "4454"
    return true
  rescue Exception => e
    #puts "Exception in click :: #{e}"
    retry if (retries += 1) < 3
    #puts "returning nil----------------------"
    return nil
  end

  def type(target, value)
    #puts " in type---->with target:: #{target} and value:: #{value}"
    @testDataJSON["#{value.delete('${}')}"] = eval('"' + @testDataJSON.fetch("#{value.delete('${}')}") + '"') if @testDataJSON.has_key?("#{value.delete('${}')}")
    element = find_element(target)
    if !element.nil? then
        element.clear 
        (value.include?('$') && value.include?('{')) ? element.send_keys(@testDataJSON["#{value.delete('${}')}"]) : element.send_keys("#{value.to_s}")
        return true
    else
      #puts "element not found...!!!"
      return nil
    end
  rescue Exception => e
    #puts "Exception in type :: #{e}"
    return nil
  end

  def doubleClick(target, value)
    element = find_element(target)
    element.click
    element.click
    return true
    rescue Exception => e
    #puts "Exception in Helper :: doubleClick---> #{e}"
    return nil 
  end

  def waitForElementPresent(target, value)
    find_element(target)
    return true
    rescue Exception => e
    #puts "Exception in Helper :: waitForElementPresent---> #{e}"
    return nil 
  end

  def select(target, value)
    #puts "in select------->"
    #puts "testData------>#{@testDataJSON}"
    #retries ||= 0
    val = value.split('=')
      
    val = "#{val[1].delete('${}')}"
    valueToSelect = @testDataJSON["#{val}"]

    if target.include?('//') && !target.nil? 
      #puts "target--->#{target}"
      #target1 = target.gsub(target[target.index(":")..(target.index("]"))], ":')]").gsub('@id=', "starts-with(@id,")
      Selenium::WebDriver::Support::Select.new(@driver.find_element(:xpath, "#{target}")).select_by(:text, valueToSelect)
      return true
    else
      #puts "in select -------with target::#{target} value::#{value}"
      #Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "FollowUpAfter")).select_by(:text, "7 Days")
      #puts @testDataJSON
      #puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
      #puts val
      #puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
      
      #puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"

      
      #puts valueToSelect
      #puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
      #puts @testDataJSON["LeadSource"]
      Selenium::WebDriver::Support::Select.new(@driver.find_element(target.split('=')[0].to_sym,target.split('=')[1].to_s)).select_by(:text, valueToSelect)
      return true
    end
    rescue Exception => e
    #puts "Exception in Helper :: select----> #{e}"
    #retry if (retries += 1) < 3
    return nil
  end

  def selectWindow(target, value)
    #puts "in select window"
    @driver.window_handles
    #puts @driver.window_handles
    #puts target[target.length - 1]
    @driver.switch_to.window @driver.window_handles.last
    return true
    rescue Exception => e
    #puts "Exception in Helper :: selectWindow---->#{e}"
    return nil
  end

  def openWindow(target, value)
    @driver.get target
    return true
    rescue Exception => e
    #puts "Exception in Helper :: openWindow---> #{e}"
    return nil 
  end

  def lightening_click_row(target, value)
    @wait.until {@driver.find_element(:xpath, "//span[contains(text(),#{target})]/../../../../../..").displayed?}
    @driver.find_element(:xpath, "//span[contains(text(),#{target})]/../../../../../..").find_elements(:tag_name, 'tr')[value.to_i].find_elements(:tag_name, 'td')[2].find_elements(:tag_name, 'a')[0].click
  end

  def lightening_assert_form_element(target, value)
    xpath = "//span[./text()=#{target}]/../following-sibling::div/descendant::"
    @wait.until {@driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").displayed?}
    #puts @driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").text
    assert_match(value, @driver.find_element(:xpath, "#{xpath}a | #{xpath}input | #{xpath}span | #{xpath}select").text)
  end

  def lightening_type(target, value)
    @testDataJSON["#{value.delete('${}')}"] = eval('"' + @testDataJSON.fetch("#{value.delete('${}')}") + '"') if @testDataJSON.has_key?("#{value.delete('${}')}")
    #puts @testDataJSON["#{value.delete('${}')}"]
    target.include?('list') ? target = "//label[./text()= '#{target.split(':')[0]}']/../parent::div//input | //span[./text()= '#{target.split(':')[0]}']/../parent::div//input" : target = "//span[./text()= '#{target}']/../following-sibling::input"
    @wait.until {@driver.find_element(:xpath, target).displayed?}
    @driver.find_element(:xpath, target).clear
    (value.include?('$') && value.include?('{')) ? @driver.find_element(:xpath, target).send_keys(@testDataJSON["#{value.delete('${}')}"]) : @driver.find_element(:xpath, target).send_keys("#{value.to_s}")
  end

  def lightening_click(target, value)
    #puts target
    target = target.split('id=')[1].split(':')[0] if (target.include?("id=") && target.include?(':'))
    @wait.until {@driver.find_element(:xpath, "//a[@title='#{target}'] | //button[@title='#{target}']| //*[starts-with(@id,'#{target}')] | //button/span[./text()='#{target}'] | //span[./text()= '#{target}']/../preceding-sibling::input").displayed?}
    @driver.find_element(:xpath, "//a[@title='#{target}'] | //button[@title='#{target}']| //*[starts-with(@id,'#{target}')] | //button/span[./text()='#{target}'] | //span[./text()= '#{target}']/../preceding-sibling::input").click
  end

  def lightening_select(target, value)
    value = "label=#{@testDataJSON.fetch(value.delete('${}').gsub('label=', ''))}" if (value.include?('$') && value.include?('{'))
    @wait.until {@driver.find_element(:xpath, "//option[@value='" + value.split('label=')[1] + "'] | //li[@title='" + value.split('label=')[1] + "']").displayed?}
    @driver.find_element(:xpath, "//option[@value='" + value.split('label=')[1] + "'] | //li[@title='" + value.split('label=')[1] + "']").click
  end

  def date_picker(target, value)
    @wait.until {@driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0]}']/../parent::div//input")}
    @driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0]}']/../parent::div//input").click
    @wait.until {@driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0]}']/../parent::div//table//span[@id='#{Date.today.to_s}']")}
    @driver.find_element(:xpath, "//label[./text()= '#{target.split(':')[0]}']/../parent::div//table//span[@id='#{Date.today.to_s}']").click
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
  end

  def wait(target, value)
    value.eql?('true') ? @wait.until {@driver.find_element(target.split('=')[0].to_sym, target.split('=')[1]).displayed?} : @wait.until {!@driver.find_element(target.split('=')[0].to_sym, target.split('=')[1]).displayed?}
  end

  def login(envCredential)
    #puts "in login"
    pwd = EnziEncryptor.decrypt(JSON.parse(envCredential.fetch('parameters'))['password'], ENV['KEY'].chop.chop)
    #@driver.get 'https://test.salesforce.com/'
    @driver.get JSON.parse(envCredential.fetch('parameters'))['url']
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    @driver.find_element(:xpath, "//input[contains(@id,'name')]").clear
    @driver.find_element(:xpath, "//input[contains(@id,'name')]").send_keys JSON.parse(envCredential.fetch('parameters'))['username']
    @driver.find_element(:xpath, "//input[contains(@id,'password')]").clear
    @driver.find_element(:xpath, "//input[contains(@id,'password')]").send_keys pwd
    @driver.find_element(:xpath, "//input[contains(@type,'submit')] | //button[contains(@type,'submit')]").click
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    @wait.until {@driver.find_element(:xpath, "//*[@title='Search Salesforce'] | //*[@id='phSearchInput']").displayed?}
    
    #puts "switching to classic....."
    #puts @driver.current_url()
    EnziUIUtility.switchToClassic(@driver) if (@driver.current_url().include? "lightning")
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    return true
    rescue Exception => e 
    #puts "Exception in Helper :: login -> #{e}"
    return nil
  end

  def loginAsGivenProfile(profile)
    #puts "in loginAsGivenProfile--------<o>"
    EnziUIUtility.switchToClassic(@driver) if (@driver.current_url().include? "lightning")
    
    newUrl = @driver.current_url().split('/')
    #puts newUrl
    @driver.get "#{newUrl[0]}//#{newUrl[2]}/" + "005?id=" + "#{profile['id']}"

    #puts "go to #{@driver.current_url()}"
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    #sleep(20)
    begin
      element = @driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[2]/td[1]/a[2]")
    rescue
      #puts "element not found i 1st row"
      element = @driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[3]/td[1]/a[2]")
    end

    #if element == nil then
     # puts "852852"
     # puts "element not found i 1st row"
     # element = @driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[3]/td[1]/a[2]")
    #end
    @wait.until {element.displayed?}
    element.click
    ##@driver.find_element(:xpath, "//*[@id='ResetForm']/div[2]/table/tbody/tr[2]/td[1]/a[2]").click
    #EnziUIUtility.switchToClassic(@driver)
    #EnziUIUtility.switchToLightening(@driver)
    @wait.until {@driver.execute_script("return document.readyState").eql? "complete"}
    return true
    rescue Exception => e 
    #puts "Exception in Helper :: loginAsGivenProfile -> #{e}"
    #raise  
    return nil
  end

  def logOutGivenProfile()
    #puts "in Helper :: logOutGivenProfile"
    #puts @driver.current_url
    url = @driver.current_url.split('force.com')[0].to_s
    finalURL = url+"force.com/home/home.jsp"
    #puts "finalURL--->#{finalURL}"

    @driver.get finalURL
    @wait.until {@driver.find_element(:xpath, "//*[@title='Search Salesforce'] | //*[@id='phSearchInput']").displayed?}
    
    if !(@driver.current_url.include? 'lightning') then
      #puts "lightning"
      @wait.until {@driver.find_element(:xpath, "//*[@id='userNav-arrow']").displayed?}
      @driver.find_element(:xpath, "//*[@id='userNav-arrow']").click
    end
    @wait.until {@driver.find_element(:xpath, "//a[@href='/secur/logout.jsp']").displayed?}
    @driver.find_element(:xpath, "//a[@href='/secur/logout.jsp']").click
    return true
    rescue Exception => e 
    #puts "Exception in Helper :: logOutGivenProfile -> #{e}"
    return nil
  end

  def echo(target, value)
    !value.nil? ? addLogs(target, value) : addLogs(target)
    rescue Exception => e 
    #puts "Exception in Helper :: echo -> #{e}"
    nil
  end

  def store(target, value)
    target = value
    rescue Exception => e 
    #puts "Exception in Helper :: store -> #{e}"
    nil
  end

  def pause(target, value)
    sleep("#{value.to_i / 1000}.to_i")
    true
    rescue Exception => e 
    #puts "Exception in Helper :: pause -> #{e}"
    nil
  end

  def close_alert_and_get_its_text
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
    #puts "in open ------<o>"
    #puts "target------> #{target}"
    #puts target.include? "lightning"
    #puts !(@driver.current_url().include?("lightning"))
    #puts "::::::::::::::::::"
    #puts target.to_s.include?("lightning") && !(@driver.current_url().to_s.include?("lightning"))
    #puts "::::::::::::::::::"

    #puts (!(target.include? "lightning") && (@driver.current_url().include? "lightning"))
    if (target.include?("lightning") && !(@driver.current_url().include? ("lightning"))) then
      #puts "454545454454"
      ##assert_not_nil(EnziUIUtility.switchToLightening(@driver),"error in switching to Lightning")
    elsif (!target.include?("lightning") && (@driver.current_url().include? ("lightning"))) then
      #puts "7878787878787"
      ##assert_not_nil(EnziUIUtility.switchToClassic(@driver),'error in switching to Classic')
    end
    #(target.include? "lightning" && !(@driver.current_url().include? "lightning")) ? assert_not_nil(EnziUIUtility.switchToLightening(@driver),"error in switching to Lightning") : (assert_not_nil(EnziUIUtility.switchToClassic(@driver),'error in switching to Classic') if (!(target.include? "lightning") && (@driver.current_url().include? "lightning")))
    url = @driver.current_url.split('force.com')[0].to_s+"force.com/"    
    finalURL = url+target.split('force.com/')[1]

    @driver.get finalURL
    @wait.until {@driver.find_element(:xpath, "//*[@title='Search Salesforce'] | //*[@id='phSearchInput']").displayed?}
    
    #puts @driver.current_url()

    #puts "link opened successfully"
    true
  rescue Exception => e 
    #puts "Exception in Helper :: open -> #{e}"
    nil
  end

  #Please provide exact app name displayed on app list
  def go_to_app(driver, app_name)
    #puts "in go to app----------------"
    #puts "switching to classic if user is in lightning"
    isLightning = driver.current_url().include? ("lightning")

    if isLightning then
      #puts "logged in user is in lightning------"
      @wait.until {driver.find_element(:xpath, "//div[@class='slds-icon-waffle']")}
      

      url = @driver.current_url.split('force.com')[0].to_s
      finalURL = url+"force.com/console?tsid=02uF00000011Ncb"
      #puts "finalURL--->#{finalURL}"

      @driver.get finalURL
      @wait.until {@driver.find_element(:xpath, "//*[@title='Search Salesforce'] | //*[@id='phSearchInput']").displayed?}     

    else
        #EnziUIUtility.switchToClassic(@driver) if isLightning
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
            addLogs("[Result ] : #{app_name} app opened successfully")
          else
            #puts "link not found---"
            driver.find_element(:id, "tsidButton").click
            addLogs("[Result ] : Logged in user dont have permsn to open ths app")
            return nil
          end
        else
          addLogs("[Result ] : Already on #{app_name}")
        end
  end
    #EnziUIUtility.switchToLightening(driver) if isLightning
    return true
  rescue Exception => e 
    #puts "Exception in Helper :: go_to_app -> #{e} !!!"
    nil
  end

  def validate_case(object,actual,expected)
    expected.keys.each do |key|
      if actual.key? key
        addLogs("[Validate ] : Checking #{object} : #{key}")
        addLogs("[Expected ] : #{actual[key]}")
        addLogs("[Actual ]   : #{expected[key]}")
        assert_match(expected[key],actual[key])
        addLogs("[Result ]   : #{key} checked successfully")
        puts "------------------------------------------------------------------------"
      end
    end
  end

  def followUp(target, value)
    begin
    #puts "in followUp------"
    retries ||= 0
    @driver.find_element(:link_text, 'Follow Up').click    
    sleep(3)
    #puts "wait for frame to load"
    #@wait.until {!@driver.find_element(:id, "spinner").displayed?}
    @wait.until {@driver.find_element(:xpath, "//iframe[@id='frame']").displayed?}

    #@driver.wait_for_frame_to_load "frame", "30000"
    #puts "switching to 'frame'"
    @driver.switch_to.frame('frame')
    begin
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    rescue
    end
    !60.times{ break if (@driver.find_element(:id, "FollowUpAfter").displayed? rescue false); sleep 1 }
    @driver.find_element(:id, "FollowUpAfter").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "FollowUpAfter")).select_by(:text, "1 Day")
    #Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "FollowUpAfter")).select_by(:index, "0")
    @driver.find_element(:id, "FollowUpAfter").click
    @driver.find_element(:xpath, "//div[@id='lightning']/div[4]/div[3]/div[3]/div[2]/div/textarea").click
    @driver.find_element(:xpath, "//div[@id='lightning']/div[4]/div[3]/div[3]/div[2]/div/textarea").clear
    @driver.find_element(:xpath, "//div[@id='lightning']/div[4]/div[3]/div[3]/div[2]/div/textarea").send_keys "Follow up - test data"
    @driver.find_element(:xpath, "//div[@id='lightning']/div[4]/div[4]/button").click
    #puts "Follow up is done"
    return true
  rescue Exception => e
    #puts "Exception in folllowUp----> #{e}"
    retry if (retries += 1) < 3
    #puts e.backtrace
    return nil
  end
  end

  def moreAction(target, value)
    #puts "in more Action"
    #sleep(10)
    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
    frameid = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[1].attribute('id')
    #puts frameid
    @driver.switch_to.frame(frameid)
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    @driver.find_element(:id,'actionDropdown').click
    return frameid

    rescue Exception => e
      #puts "Exception in moreAction---->#{e}"
      return nil
    
  end

  def selectFrame(target, value)
    #puts "in selectFrame ---->with target:: #{target} and value:: #{value}"
    @driver.switch_to.default_content
    #puts "switching to frame"
    @wait.until {@driver.find_elements(:tag_name, "iframe")[target.split('=')[1].to_i]}
    #puts 'frame found'
    
    #@driver.switch_to.frame(4);
    @driver.switch_to.frame("#{value}")
    #puts 
    #@driver.switch_to.frame("#{target.split('=')[1].to_i}");
    #puts "545454"
    #puts @driver.find_elements(:name, "iframe")[3].attribute("name")
    #EnziUIUtility.switchToFrame(@driver, @driver.find_elements(:tag_name, "iframe")[target.split('=')[1].to_i].attribute("name"))
    true
    rescue Exception => e
    #puts "Exception in Helper :: selectFrame -> #{e}"
    nil
  end

end
