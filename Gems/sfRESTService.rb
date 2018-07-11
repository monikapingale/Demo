#Created By : Monika Pingale
#Created Date : 18th Jan 2018
#Purpose: This class has methods to test salesforce rest service url's
#Modified date :
require 'httparty'
require 'yaml'
class SfRESTService
  def initialize(grant_type,client_id,client_secret,username,password)
    #puts "5555555"
    #@@credentails = YAML.load_file('credentials.yaml')
    #data = {"grant_type"=>@@credentails['QAAuto']['grant_type'],"client_id"=>@@credentails['QAAuto']['client_id'],"client_secret"=>@@credentails['QAAuto']['client_secret'], "username"=>@@credentails['QAAuto']['username'],"password"=>"#{@@credentails['QAAuto']['password']}"}
    data = {"grant_type"=>grant_type,"client_id"=>client_id,"client_secret"=>client_secret, "username"=>username,"password"=>"#{password}"}

    #puts data
    @response = HTTParty.post("https://test.salesforce.com/services/oauth2/token",
                              :body => data,
                              :headers => {"Content-Type":'application/x-www-form-urlencoded'} , verify: false)
    #puts "hellooooo"
    puts @response
  end

  def getData(id,serviceUrl)
    url = @response['instance_url'] + "#{serviceUrl}/#{id}"
    getResponse = HTTParty.get(url,:headers => {"Content-Type":"application/json","Authorization" => "Bearer #{@response['access_token']}"} , verify: false)
    return getResponse
  end

  def postData(data,serviceUrl)
    #puts data
    url = "#{@response['instance_url']}#{serviceUrl}"
    puts url
    postResponse = HTTParty.post(url,:body => data,:headers => {"Content-Type":"application/json","Authorization" => "Bearer #{@response['access_token']}"} , verify: false)
    puts postResponse
    @postedData = postResponse['result']
    return postResponse
  end
end
#SfRESTService.loginRequest
#puts SfRESTService.postData('',"/services/apexrest/Tour",false)

#puts SfRESTService.postData('a0R3D00000110e0',"/services/apexrest/Tour",false)['tour_id']