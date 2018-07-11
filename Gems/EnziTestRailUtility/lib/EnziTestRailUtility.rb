require 'yaml'
require_relative('testrail/api_client')
module EnziTestRailUtility
  class TestRailUtility

    def initialize(username, password)
      @client = TestRail::APIClient.new('https://enzigma.testrail.io/')
      @client.user = username
      @client.password = password

    end

    def getSuites(projectId)
      url = "get_suites/#{projectId}"
      return @client.send_get(url)
    end

    def closeRun(run_id)
      @client.send_post("close_run/#{run_id}", {})
    end

    def addRuns(projectId)
      getSuites(projectId).each do |suite|
        addRun(getProject(projectId)['name'], projectId, suite['id'], nil)
      end
    end

    def addRun(test_run_name, projectId, suiteId, caseIDs)
      if !caseIDs.nil? && caseIDs.size > 0 then
        data = {
            suite_id: suiteId,
            name: "#{test_run_name}- #{Time.now.asctime}",
            include_all: false,
            case_ids: caseIDs
        }
      else
        data = {suite_id: suiteId, name: "#{test_run_name}- #{Time.now.asctime}", include_all: true}
      end
      @client.send_post("add_run/#{projectId}", data)
    end

    def createRuns(profile, runs)
      puts "in create Runs
      runs1 = Marshal.load(Marshal.dump(runs))
      runs1.each do |run|
        run.store('profile', profile)
        if (run.has_key?('section_id') && !run.values_at('section_id').nil? && run.has_key?('case_id') && !run.values_at('case_id').nil? && !run.has_key?('run_id') && !run.has_key?('profile'))
           run.store('run_id', addRun("#{profile['name']}", run['project_id'], run['suite_id'], run['case_id'])['id'])
        else
          if !run.has_key?('section_id') && run.has_key?('suite_id') && !run.values_at('suite_id').nil? && !run.has_key?('run_id') && !run.has_key?('profile') then
            run.store('run_id', addRun("#{profile['name']}", run['project_id'], run['suite_id'], nil)['id'])
          end
        end
      end
      runs1
    end

    def deleteRun(runId)
      @client.send_get("delete_run/#{runId}")
    end

    def getSpecLocations(caseId, sectionId, suitId, planId, projectId, profiles)
      specLocations = Array.new
      tempRunHolder = []
      if !caseId.nil? then
        testCase = getCase(caseId)
        if !ENV['RUN_ID'].nil?
          specLocations.push(Hash["path" => testCase.fetch('custom_spec_location'), "isBrowserDependent" => testCase.fetch('custom_is_browser_dependent')])
          return specLocations.uniq
        else
          if !profiles.nil? && profiles.size > 0
            profiles.each do |profile|
              tempRunHolder.push(addRun("#{getSuite(suit)['name']}-#{profile}", projectId, suitId, [caseId])['id'].to_s)
            end
            specLocations.push(Hash["path" => testCase.fetch('custom_spec_location'), "isBrowserDependent" => testCase.fetch('custom_is_browser_dependent')], 'runId' => tempRunHolder)
          end

        end
      else
        if !sectionId.nil? && getSuites(projectId).size == 1 then
          arrCaseIds = Array.new
          tempCaseHolder = nil
          getCases(projectId, nil, sectionId).each do |testCase|
            if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
              if !ENV['RUN_ID'].nil?
                specLocations.push(Hash["path" => testCase.fetch('custom_spec_location'), "isBrowserDependent" => testCase.fetch('custom_is_browser_dependent')])
                break;
              else
                tempCaseHolder = testCase
                arrCaseIds.push(testCase['id']);
              end
            end
          end
          if ENV['RUN_ID'].nil? && arrCaseIds.size > 0
            tempRunHolder = []
            suit = getSection(sectionId)['suit_id']
            if !profiles.nil? && profiles.size > 0
              profiles.each do |profile|
                tempRunHolder.push(addRun("#{getSuite(suit)['name']}-#{profile}", projectId, suit, arrCaseIds)['id'].to_s)
              end
              specLocations.push(Hash["path" => tempCaseHolder.fetch('custom_spec_location'), "isBrowserDependent" => tempCaseHolder.fetch('custom_is_browser_dependent'), "runId" => tempRunHolder])
            end
          end
        else
          #puts "Gettingsssssssssssssssssss"
          arrCaseIds = Array.new
          tempCaseHolder = nil
          #Getting cases from suit id only if project is operating in single suit mode otherwise required
          if !suitId.nil? then
            if !sectionId.nil? then
              getCases(projectId, suitId, sectionId).each do |testCase|
                if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
                  if !ENV['RUN_ID'].nil?
                    specLocations.push(Hash["path" => testCase.fetch('custom_spec_location'), "isBrowserDependent" => testCase.fetch('custom_is_browser_dependent')])
                    break;
                  else
                    tempCaseHolder = testCase
                    arrCaseIds.push(testCase['id']);
                  end
                end
              end
              if ENV['RUN_ID'].nil? && arrCaseIds.size > 0
                tempRunHolder = []
                if !profiles.nil? && profiles.size > 0
                  profiles.each do |profile|
                    tempRunHolder.push(addRun("#{getSuite(suitId)['name']}-#{profile}", projectId, suitId, arrCaseIds)['id'].to_s)
                  end
                  specLocations.push(Hash["path" => tempCaseHolder.fetch('custom_spec_location'), "isBrowserDependent" => tempCaseHolder.fetch('custom_is_browser_dependent'), "runId" => tempRunHolder])
                end
              end
              puts specLocations
            else
              arrCaseIds = Array.new
              tempCaseHolder = nil
              getSections(suitId, projectId).each do |section|
                getCases(projectId, suitId, section['id']).each do |testCase|
                  if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
                    if !ENV['RUN_ID'].nil?
                      specLocations.push(Hash["path" => testCase.fetch('custom_spec_location'), "isBrowserDependent" => testCase.fetch('custom_is_browser_dependent')])
                      break;
                    else
                      tempCaseHolder = testCase
                      arrCaseIds.push(testCase['id']);
                    end
                  end
                end
              end
              if ENV['RUN_ID'].nil? && arrCaseIds.size > 0
                tempRunHolder = []
                if !profiles.nil? && profiles.size > 0
                  profiles.each do |profile|
                    tempRunHolder.push(addRun("#{getSuite(suitId)['name']}-#{profile}", projectId, suitId, arrCaseIds)['id'].to_s)
                  end
                  specLocations.push(Hash["path" => tempCaseHolder.fetch('custom_spec_location'), "isBrowserDependent" => tempCaseHolder.fetch('custom_is_browser_dependent'), "runId" => tempRunHolder])
                end
              end
            end
          else
            if !planId.nil? then
              plan = getPlan(planId)
              plan['entries'].each do |entry|
                suit = entry['suite_id']
                getSections(suit, projectId).each do |section|
                  getCases(projectId, suit, section['id']).each do |testCase|
                    if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
                      specLocations.push(Hash["path" => testCase.fetch('custom_spec_location'), "isBrowserDependent" => testCase.fetch('custom_is_browser_dependent')])
                      break;
                    end
                  end
                end
              end
            else
              if !projectId.nil? then
                specLocation = nil
                getSuites(projectId).each do |suit|
                  arrCaseIds = Array.new
                  tempCaseHolder = nil
                  getSections(suit['id'], projectId).each do |section|
                    getCases(projectId, suit['id'], section['id']).each do |testCase|
                      if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
                        if !ENV['RUN_ID'].nil?
                          specLocations.push(Hash["path" => testCase.fetch('custom_spec_location'), "isBrowserDependent" => testCase.fetch('custom_is_browser_dependent')])
                          break;
                        else
                          tempCaseHolder = testCase
                          arrCaseIds.push(testCase['id']);
                        end
                      end
                    end
                  end
                  if ENV['RUN_ID'].nil? && arrCaseIds.size > 0
                    tempRunHolder = []
                    if !profiles.nil? && profiles.size > 0
                      profiles.each do |profile|
                        tempRunHolder.push(addRun("#{suit['name']}-#{profile}", projectId, suit['id'], arrCaseIds)['id'].to_s)
                      end
                      specLocations.push(Hash["path" => tempCaseHolder.fetch('custom_spec_location'), "isBrowserDependent" => tempCaseHolder.fetch('custom_is_browser_dependent'), "runId" => tempRunHolder])
                    end
                  end
                end
              end
            end
          end
        end
        return specLocations.uniq
      end
    end

    #StatusId ::
    #1  Passed
    #2  Blocked
    #3  Untested (not allowed when adding a result)
    #4  Retest
    #5  Failed
    def postResult(caseId, comment, statusId, testRunId)
      url = "add_result_for_case/#{testRunId}/#{caseId}"
      @client.send_post(url, {:status_id => statusId, :comment => "#{comment}"})
    end

    def getCase(caseId)
      url = "get_case/#{caseId}"
      return @client.send_get(url)
    end

    def getCases(projectId, suiteId, sectionId)
      caseSet = Set.new
      if sectionId.is_a?(Array) then
        sectionId.each do |section|
          @client.send_get("get_cases/#{projectId}&suite_id=#{suiteId}&section_id=#{section}").each do |cases|
            caseSet.add(cases['id'])
          end
        end
        return caseSet.to_a
      else
        #if single section given
        @client.send_get("get_cases/#{projectId}&suite_id=#{suiteId}&section_id=#{sectionId}").each {|cases| caseSet.add(cases['id'])} if (!sectionId.nil? && !suiteId.nil? && !projectId.nil?)
        return caseSet.to_a
      end
      #if suit not given
      if !sectionId.nil? && !projectId.nil? then
        return @client.send_get("get_cases/#{projectId}&section_id=#{sectionId}")
      else
        #Getting cases from suit id only if project is operating in single suit mode otherwise required
        if getSuites(projectId).size == 1 && !suiteId.nil? then
          return @client.send_get("get_cases/#{projectId}&suite_id=#{suiteId}")
          #Getting cases from project id is valid iff project is operating in single suit mode
        else
          if getSuites(projectId).size == 1 && !projectId.nil? then
            return @client.send_get("get_cases/#{projectId}")
          end
        end
      end
    end

    def getSuite(suiteId)
      url = "get_suite/#{suiteId}"
      return @client.send_get(url)
    end

    def getProject(projectId)
      url = "get_project/#{projectId}"
      return @client.send_get(url)
    end

    def getProjects()
      return @client.send_get('get_projects')
    end

    def getSuitByName(projectId, suitName)
      suitJSON = getSuites(projectId)
      index = 0
      until suitJSON[index] == nil do
        if suitJSON[index]["name"] == suitName then
          return suitJSON[index]["id"]
        end
        index += 1
      end
    end

    def getProjectByName(projectName)
      arrProject = getProjects()
      index = 0
      id = nil
      until arrProject[index] == nil do
        if arrProject[index]["name"] == projectName.to_s then
          id = arrProject[index]["id"]
          break
        end
        index += 1
      end
      return id
    end

    def getRun(runId)
      @client.send_get("get_run/#{runId}")
    end

    def getRuns(suitId, sectionId, projectId)
      @client.send_get("get_runs/#{projectId}&suite_id=#{suitId}&section_id=#{sectionId}")
    end

    def getPayloadsFromSteps(steps)
      payloads = Array.new
      steps.each do |cases|
        if cases.has_value?("Payload") then
          payloads.push(cases)
        end
      end
      return payloads
    end

    def getCaseFields
      @client.send_get("get_case_fields")
    end

    def getSections(suitId, projectId)
      @client.send_get("get_sections/#{projectId}&suite_id=#{suitId}")
    rescue Exception => e
      puts e
      return nil
    end

    def getSection(sectionId)
      @client.send_get("get_section/#{sectionId}")
    end

    def getPlan(planId)
      @client.send_get("get_plan/#{planId}")
    end

    def getTests(runId)
      @client.send_get("get_tests/#{runId}")
    end

    def getTest(testId)
      @client.send_get("get_test/#{testId}")
    end
  end

      
