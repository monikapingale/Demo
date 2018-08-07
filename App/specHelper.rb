=begin
************************************************************************************************************************************
    Author      :   QaAutomationTeam
    Description :   This file contai methods required to execute scripts.

    History     :
  ----------------------------------------------------------------------------------------------------------------------------------
  VERSION           DATE             AUTHOR                  DETAIL
  1                 23 June 2018     QaAutomationTeam        Initial Developement
**************************************************************************************************************************************
=end
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
        puts "fail result for record" if @isDevelopment

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
      if target.include?("id=") && target.include?(":")
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
    !value.nil? ? addLogs(target, value) : addLogs(target)
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
    if target.include?('//') && target.include?(":") && !target.nil?
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
    #puts element.length
    element.last.tag_name == 'a' ? actualValue = element.last.text : actualValue = element.last.attribute('value') if element.length > 1
    element.first.tag_name == 'a' ? actualValue = element.first.text : actualValue = element.first.attribute('value') if element.length == 1

    addLogs("[Step     ] : Check #{key_column.delete('${}').split('_')[1]}")
    addLogs("[Expected ] : #{expectedValue}")
    addLogs("[Actual   ] : #{actualValue}")
    assert_match(actualValue,expectedValue)
    addLogs("[Result   ] : Success")
    return true

    rescue Exception => e 
    addLogs("[Result   ] : Failed") 
    puts "Exception in Helper :: assertText -> #{e}" if @isDevelopment
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




