
=begin

************************************************************************************************************************************
    Author      :   QaAutomationTeam
    Description :   This is a entry point for all run spec requests it will parse the input and run scripts for them

    History     :
  ----------------------------------------------------------------------------------------------------------------------------------
  VERSION           DATE             AUTHOR                  DETAIL
  1                 20 June 2018     QaAutomationTeam        Initial Developement
**************************************************************************************************************************************

=end
=begin
require 'yaml'
require 'rspec'
require 'selenium-webdriver'
require 'enziEncryptor'
require 'pg'
require 'securerandom'
require_relative File.expand_path(Dir.pwd) + '/executeXML.rb'
require_relative File.expand_path(Dir.pwd) + '/specHelper.rb'
require 'active_support/core_ext/hash'
require_relative File.expand_path('..', Dir.pwd) + "/Gems/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
@helper = Helper.new
@wait = @helper.instance_variable_get(:@wait)
if !(ENV['DATABASE_URL'].nil?)
  @con = PG.connect EnziEncryptor.decrypt(ENV['DATABASE_URL'],ENV['KEY'].chop.chop)
  templateHash = {}
  ENV['TEMPLATE_ID'].nil? ? templateHash['testrailserver']='team-qa@enzigma.com' : templateHash = @con.exec("select * from templates where job = '#{ENV['TEMPLATE_ID']}'")[0]
  testRailCredential = @con.exec("select * from credentials where name = '#{templateHash['testrailserver']}' OR username= '#{templateHash['testrailserver']}'")[0]
  testRailUtility = EnziTestRailUtility::TestRailUtility.new(testRailCredential['username'], EnziEncryptor.decrypt(testRailCredential['password'],ENV['KEY'].chop.chop))
  @helper.instance_variable_set(:@testRailUtility, testRailUtility)
  puts "lets start"

  runs = Array.new
  if(templateHash.key?('project') || templateHash.key?('suit') ||templateHash.key?('section') )
#for section
    JSON.parse(templateHash.fetch('section')).each {|section| suite = testRailUtility.getSuite(section['suite_id']); runs.push({'project_id' => suite['project_id'], 'suite_id' => suite['id'], 'section_id' => [section['id']], 'case_id' => testRailUtility.getCases(suite['project_id'], suite['id'], section['id'])}) if !runs.any? {|h| (h['section_id'] << section['id'] && h['case_id'].concat(testRailUtility.getCases(h['project_id'], h['suite_id'], section['id']))) if h['suite_id'].eql?(suite['id'])}} if (templateHash.has_key?('section') && !templateHash.values_at('section').nil? && templateHash.has_key?('suit') && templateHash.has_key?('project') && !templateHash.values_at('case').nil?)
#for suit
    JSON.parse(templateHash.fetch('suit')).each {|suit| runs.push({'project_id' => suit['project_id'], 'suite_id' => suit['id'],'case_id'=>ENV['CASE_ID']}) if !runs.any? {|h| h['suite_id'].eql?(suit['id'])}} if (templateHash.has_key?('suit') && !templateHash.values_at('suit').nil? && templateHash.has_key?('project') && !templateHash.values_at('case').nil?)
#for project
    JSON.parse(templateHash.fetch('project')).each {|project| testRailUtility.getSuites(project['id']).each {|suite| runs.push({'project_id' => project['id'], 'suite_id' => suite['id']})} if !runs.any? {|h| h['project_id'].eql?(project['id'])}} if (templateHash.has_key?('suit') && !templateHash.values_at('project').nil? && templateHash.has_key?('project') && !templateHash.values_at('case').nil?)
    puts runs
  else
    runs.push({'project_id'=>ENV['PROJECT_ID'],'suite_id'=>ENV['SUIT_ID'],'section_id'=>[ENV['SECTION_ID']]}) if(!ENV['PROJECT_ID'].nil? || !ENV['SUIT_ID'].nil? || !ENV['SECTION_ID'].nil?)
  end
  ENV['RUN_ID'].nil? ? profiles = JSON.parse(templateHash.fetch('profile')) : profiles = YAML.load_file(File.expand_path(Dir.pwd)+'/Config/UserSettings.yaml')['profile']; profiles.each {|profile| runs = testRailUtility.createRuns(profile['name'], runs)} if (templateHash.has_key?('profile') && !templateHash.values_at('profile').nil?)
  puts "************************Start execution ****************************"
  runs.each {|script| @helper.instance_variable_set(:@runId, script['run_id']) if(ENV['RUN_ID'].nil?) ;ExecuteXml.interpretXML(script, @helper)}
else
  puts "Please Provide database url"
  end
=end
require 'yaml'
require 'rspec'
require 'selenium-webdriver'
require 'enziEncryptor'
require 'pg'
require 'securerandom'
require 'os'
require 'active_support/core_ext/hash'
require_relative File.expand_path(Dir.pwd) + '/executeXML.rb'
require_relative File.expand_path(Dir.pwd) + '/specHelper.rb'
require_relative File.expand_path('..', Dir.pwd) + "/Gems/EnziTestRailUtility/lib/EnziTestRailUtility.rb"

@helper = Helper.new
@wait = @helper.instance_variable_get(:@wait)
if !(ENV['DATABASE_URL'].nil?)
  @con = PG.connect EnziEncryptor.decrypt(ENV['DATABASE_URL'],ENV['KEY'].chop.chop)
  templateHash = {}
  ENV['TEMPLATE_ID'].nil? ? templateHash['testrailserver']='team-qa@enzigma.com' : templateHash = @con.exec("select * from templates where job = '#{ENV['TEMPLATE_ID']}'")[0]

  testRailCredential = @con.exec("select * from credentials where name = '#{templateHash['testrailserver']}' OR username= '#{templateHash['testrailserver']}'")[0]
  testRailUtility = EnziTestRailUtility::TestRailUtility.new(testRailCredential['username'], EnziEncryptor.decrypt(testRailCredential['password'],ENV['KEY'].chop.chop))
  @helper.instance_variable_set(:@testRailUtility, testRailUtility)
  runs = Array.new
  if(templateHash.key?('project') || templateHash.key?('suit') ||templateHash.key?('section') )
    puts "-------------------- exc starts with application ----------------"
    #for section
    JSON.parse(templateHash.fetch('section')).each {|section| suite = testRailUtility.getSuite(section['suite_id']); runs.push({'project_id' => suite['project_id'], 'suite_id' => suite['id'], 'section_id' => [section['id']], 'case_id' => testRailUtility.getCases(suite['project_id'], suite['id'], section['id'])}) if !runs.any? {|h| (h['section_id'] << section['id'] && h['case_id'].concat(testRailUtility.getCases(h['project_id'], h['suite_id'], section['id']))) if h['suite_id'].eql?(suite['id'])}} if (templateHash.has_key?('section') && !templateHash.values_at('section').nil? && templateHash.has_key?('suit') && templateHash.has_key?('project') && !templateHash.values_at('case').nil?)
    #for suit
    JSON.parse(templateHash.fetch('suit')).each {|suit| runs.push({'project_id' => suit['project_id'], 'suite_id' => suit['id'],'case_id'=>ENV['CASE_ID']}) if !runs.any? {|h| h['suite_id'].eql?(suit['id'])}} if (templateHash.has_key?('suit') && !templateHash.values_at('suit').nil? && templateHash.has_key?('project') && !templateHash.values_at('case').nil?)
    #for project
    JSON.parse(templateHash.fetch('project')).each {|project| testRailUtility.getSuites(project['id']).each {|suite| runs.push({'project_id' => project['id'], 'suite_id' => suite['id']})} if !runs.any? {|h| h['project_id'].eql?(project['id'])}} if (templateHash.has_key?('suit') && !templateHash.values_at('project').nil? && templateHash.has_key?('project') && !templateHash.values_at('case').nil?)
  else
    puts "------------------- exe starts with testRail----------------------"
    runs.push({'project_id'=>ENV['PROJECT_ID'],'suite_id'=>ENV['SUIT_ID'],'section_id'=>[ENV['SECTION_ID']]}) if(!ENV['PROJECT_ID'].nil? || !ENV['SUIT_ID'].nil? || !ENV['SECTION_ID'].nil?)
  end
  ENV['RUN_ID'].nil? ? profiles = JSON.parse(templateHash.fetch('profile')) : profiles = YAML.load_file(File.expand_path(Dir.pwd)+'/Config/UserSettings.yaml')['profile'];
  runsForEachProfile = nil
  profiles.each do |profile|
    if runsForEachProfile.nil? then
      runsForEachProfile = testRailUtility.createRuns(profile, runs)
    else
      runsForEachProfile.concat(testRailUtility.createRuns(profile, runs))
    end
  end
  ENV['RUN_ID'].nil? ? browsers = JSON.parse(templateHash.fetch('browser')) : browsers = ENV['BROWSERS'].split(',')
  browsersForCurrentOS = nil
  if ENV['RUN_ID'].nil? then
    env = templateHash.fetch('environment')
    browsers = [{"name"=> "JenkinsServer~mac","value"=>["chrome","safari"],"$$hashKey"=>"object:12363",'os'=>'mac'},{"name"=> "JenkinsServer~Windows","value"=>["chrome","firefox"],"$$hashKey"=>"object:12363",'os'=>'windows'}]
    #browsers = JSON.parse(templateHash.fetch('browser'))
    browsers.each do |browser|
      browsersForCurrentOS = browser.fetch('value') if eval("OS.#{browser.fetch('os').to_s.downcase}?")
    end
  else
    env = 'Staging'
    browsersForCurrentOS = ENV['BROWSERS'].split(',')
  end
  envCredential = @con.exec("select * from environments where name = '#{env}'")[0]
  auth = @con.exec("select * from salesforce_cons")[0]
  @helper.instance_variable_set(:@restforce,EnziRestforce.new(JSON.parse(envCredential.fetch('parameters'))['username'], EnziEncryptor.decrypt(JSON.parse(envCredential.fetch('parameters'))['password'], ENV['KEY'].chop.chop), auth.fetch('client_id'), auth.fetch('client_secret'), true))
  puts "************************ iterate thr browsers ****************************"
  browsersForCurrentOS.each do |browser|
    puts "************************ Execution on #{browser} starts ****************************"
    driver = Selenium::WebDriver.for browser.to_sym
    @helper.instance_variable_set(:@driver, driver)
    #login to sf as admin
    @helper.login(envCredential)
    runsForEachProfile.each_index do |index,hash2|
      puts "****************. Start .************************"
      puts "login as #{runsForEachProfile[index]['profile']['name']}" if index == 0
      puts "login as #{runsForEachProfile[index]['profile']['name']}" if index > 0 && runsForEachProfile[index]['profile']['name'] != runsForEachProfile[index - 1]['profile']['name']

      @helper.instance_variable_set(:@runId, runsForEachProfile[index]['run_id'].to_s) if(ENV['RUN_ID'].nil? && !(runsForEachProfile[index]['run_id'].nil?))

      @helper.loginAsGivenProfile(runsForEachProfile[index]['profile']) if index == 0
      @helper.loginAsGivenProfile(runsForEachProfile[index]['profile']) if index > 0 && runsForEachProfile[index]['profile']['name'] != runsForEachProfile[index - 1]['profile']['name']

      puts "execution starts"
      ExecuteXml.interpretXML(runsForEachProfile[index], @helper) if (!(ENV['RUN_ID'] =='') && !(ENV['RUN_ID'].nil?))

      ENV['RUN_ID'] = nil
      #log out user
      @helper.logOutGivenProfile()
      puts "****************.End .************************"
      puts runsForEachProfile[index]['run_id']
      @helper.validate_case(@helper.instance_variable_get(:@testDataJSON)['object'],@helper.instance_variable_get(:@restforce).getRecords("SELECT #{@helper.instance_variable_get(:@testDataJSON).except(:object).except(:uniqfield).keys().join(',')} FROM #{@helper.instance_variable_get(:@testDataJSON)['object']} WHERE #{@helper.instance_variable_get(:@testDataJSON)['uniqfield']} = #{@helper.instance_variable_get(:@testDataJSON)[@helper.instance_variable_get(:@testDataJSON)['uniqfield']]}"),@helper.instance_variable_get(:@testDataJSON))
    end
    #sleep(10)
    puts "logged out before changing browser"
    @helper.logOutGivenProfile()
    testRailUtility.closeRun(@helper.instance_variable_get(:@runId)) if (browsersForCurrentOS.last.eql? browser)
    driver.quit
    puts "************************ Execution on #{browser} ends ****************************"
  end
  puts "************************ iterate thr browsers ends ****************************"
else
  puts "Please Provide database url"
end
