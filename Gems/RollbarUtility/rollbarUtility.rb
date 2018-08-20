=begin
************************************************************************************************************************************
   Author      :   QAAutomationTeam
   Description :   This gem has integration with rollbar.

   History     :
 ----------------------------------------------------------------------------------------------------------------------------------
 VERSION            DATE             AUTHOR                    DETAIL
 1                 24 May 2018       QAAutomationTeam          Initial Developement
**************************************************************************************************************************************
=end
require 'rollbar'

Rollbar.configure do |config|
  config.access_token = "0f80afe4f8eb4f03a3c1ab80ed377d32"
  #config.endpoint = 'https://api-alt.rollbar.com/api/1/item/'
  config.enabled = true
  config.environment = "sandbox"
  config.verify_ssl_peer = false

  # Other Configuration Settings
  #config.custom_data_method = lambda { { :Id => "", :Title => ""} }
end

class RollbarUtility
	@@logHash = Hash.new()
	@@sId = ''
	def postRollbarData(id, title, passedExpects)
		Rollbar.configure do |config| 
        	config.custom_data_method = lambda { { :Id => id, :Title => title, :PassExpects => passedExpects}}
      	end
	end

	def addLogs(logMessage, specId = nil)
	    puts logMessage
	    
	    if specId != nil
	      @@sId = specId
	      @@logHash = Hash.new()
	      @@logHash.store(specId, logMessage)
	    else
	      #puts "Inside else: #{@@logHash}"
	      @@logHash[@@sId] = "#{@@logHash[@@sId]}\n#{logMessage}"
	    end
	    #puts @@logHash
	    return @@logHash
  	end
end