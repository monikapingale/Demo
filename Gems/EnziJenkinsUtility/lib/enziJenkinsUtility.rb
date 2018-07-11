require 'jenkins_api_client'
module EnziJenkinsUtility
  class JenkinsUtility
    def initialize(username,password,jenkins_server)
      @client = JenkinsApi::Client.new(
          server_url: jenkins_server,
          username: username,
          password: password
      )
      puts @client.job.list_all
    end
    def createJob(name,xml)
=begin
      puts @client.job.create_freestyle(
          :name => "test_freestyle_job",
          :keep_dependencies => true,
          :concurrent_build => true,
          :scm_provider => "git",
          :scm_url => "git://github.com./arangamani/jenkins_api_client.git",
          :scm_branch => "master",
          :shell_command => "bundle install\n rake func_tests"
      )
=end
      @client.job.create(name , xml)

    end
    #job_name (String) — the name of the job
    #params (Hash) (defaults to: {}) — the parameters for parameterized build
    #opts (Hash) (defaults to: {}) —   options for this method build_start_timeout [Integer] How long to wait for queued build to start before giving up. Default: 0/nil
    #                                  cancel_on_build_start_timeout [Boolean] Should an attempt be made to cancel the queued build if it hasn't started within '
    #                                  build_start_timeout' seconds? This only works on newer versions of Jenkins where JobQueue is exposed in build post response. Default: false end
    #                                  poll_interval [Integer] How often should we check with CI Server while waiting for start. Default: 2 (seconds)
    #                                  progress_proc [Proc] A proc that will receive progress notitications. Default: nil
    #                                  completion_proc [Proc] A proc that is called <just before> this method (build) exits. Default: nil
    def buildJob(job_name, params, opts)
      puts job_name
      puts params
      puts opts
      @client.job.build(job_name,params,opts)
    end

    def ScheduleJob(job_name,opts)
      @client.job.update(job_name,opts)
    end

    def deleteJob(job_name)
      @client.job.delete(job_name)
    end

    def updateJob(job_name,cron)
      @client.job.update(job_name,Nokogiri::XML::Document.parse(@client.job.get_config(job_name).gsub('*',"#{cron}")).to_s).inspect
    end
  end
end
=begin

#puts j.createJob('n88899988',File.read("jenkins_job_config.xml")).inspect
puts #j.buildJob('n333',{"PROJECT_ID" => 4, "SECTION_ID" => 22},{"build_start_timeout" => 1})

puts  Nokogiri::XML::Document.parse(File.read("jenkins_job_config.xml")).to_s.gsub('*/5 * * * *' , '*/5 */5 * * *').gsub('%&gt;','')
=end
=begin
j = EnziJenkinsUtility::JenkinsUtility.new('qa','9F*b)WX2tne(axcZ','http://enzqawin.eastus.cloudapp.azure.com:8080/')
j.buildJob('n333',{"PROJECT_ID" => 4, "SECTION_ID" => 22},{"build_start_timeout" => 1})
=end
