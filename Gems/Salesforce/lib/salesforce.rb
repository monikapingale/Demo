=begin
************************************************************************************************************************************
   Author      :   QAAutomationTeam
   Description :   This gem is used to consume salesforce rest api for crud operations.

   History     :
 ----------------------------------------------------------------------------------------------------------------------------------
 VERSION            DATE             AUTHOR                    DETAIL
 1                 24 May 2018       QAAutomationTeam          Initial Developement
**************************************************************************************************************************************
=end
require 'salesforce_bulk'

class Salesforce
	@sfBulk = nil
  @@createdRecordsIds = Hash.new
  def initialize()
    #puts @driver.title
  end
	def self.login(username,password,isSandbox)
		sfBulk =  SalesforceBulk::Api.new(username, password, isSandbox)
		#puts 'sfBulk==>'
		#puts sfBulk
		return sfBulk
	end
  
  def self.getRecords(sfBulk,sObjectType,query,key = nil)
    result =nil
    sObjectRecordMap = nil
    result = sfBulk.query(sObjectType,query)
    
    if key == nil then
      #puts "#{sObjectType} records :: #{result}"
      return result
    else
      sObjectRecordMap = Hash.new
      (result.result.records).each_with_index do |object, index|
       sObjectRecordMap.store(((result.result.records[index]).to_hash)[key],(result.result.records[index]).to_hash)
    end
    #puts 'sObjectRecordMap==>'
    #puts sObjectRecordMap
    end
  end
  def self.addRecordsToDelete(key,value)
    if @@createdRecordsIds.key?("#{key}") then
      @@createdRecordsIds["#{key}"] << Hash["Id" => value]
    else
      @@createdRecordsIds["#{key}"] = [Hash["Id" => value]]
    end
  end
 def self.createRecords(sfBulk,objectType,records_to_insert)
    recordIdsArray = Array.new
    result = sfBulk.create(objectType, records_to_insert,true)
    (result.result.records).each_with_index do |object, index|
      recordIdsArray.push(Hash["Id" => (result.result.records)[index].fetch('Id')])
      if @@createdRecordsIds.key?("#{objectType}") then
        @@createdRecordsIds["#{objectType}"] << Hash["Id" => (result.result.records)[index].fetch('Id')]
      else
        @@createdRecordsIds["#{objectType}"] = [Hash["Id" => (result.result.records)[index].fetch('Id')]]
      end
    end
    #puts "Record Ids :: #{@@createdRecordsIds}" 
    #puts "Created Records :: #{recordIdsArray}"
    return recordIdsArray
 end

 def self.getCreatedRecords(sfBulk,objectType,query,recordIds)
    setIds = nil
    setIds = '('

    (recordIds).each_with_index do |object, index|
      setIds+='\''+(recordIds)[index]['Id'] +'\','
    end

    setIds = setIds.chomp(',')
    setIds+=')'

    #puts 'query in createdrRecords==>'
    #puts query+" Id IN "+setIds+""
    result = sfBulk.query(objectType, query+" WHERE Id IN "+setIds+"")
    #puts 'result.result.records==>'
    #puts result.result.records
 end

 def self.deleteRecords(sfBulk,sObjectType,recordsToDelete)
  if(recordsToDelete!= nil && recordsToDelete.count > 0 && recordsToDelete.count < 10) 
     deletedRecords = sfBulk.delete(sObjectType, recordsToDelete,true)
     #puts 'deletedRecords==>'
     #puts deletedRecords.inspect
     return deletedRecords.result.records
  else
    return nil
  end
end
end