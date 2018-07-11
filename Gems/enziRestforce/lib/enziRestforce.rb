=begin
************************************************************************************************************************************
    Author      :   QaAutomationTeam
    Description :   This gem provides methods for CRUD operations in Salesforce.

    History     :
  ----------------------------------------------------------------------------------------------------------------------------------
  VERSION            DATE             AUTHOR                  DETAIL
  1                 21 April 2018     QaAutomationTeam        Initial Developement
**************************************************************************************************************************************
=end


require 'restforce'
require 'faye'
require 'cookiejar'

class EnziRestforce
  #@@@client = nil
  @@createdRecordsIds = Hash.new

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end

  def initialize(username,password,clientId,clientSecret,isSandbox)
    if(!isSandbox) then
      host = 'login.salesforce.com'
    else
      host = 'test.salesforce.com'
    end
    @client = Restforce.new(username: "#{username}",
                           password: "#{password}",
                           #mashify: false,
                           host: "#{host}",
                           # security_token: 'l3WwT1P1u0BaUkLw8ocH5Wzp',
                           client_id: "#{clientId}",
                           client_secret: "#{clientSecret}",
                           authentication_callback: Proc.new { |x| puts x },
                           api_version: '41.0',
                           request_headers: { 'sforce-auto-assign' => 'FALSE' })

    @client.authenticate!
    puts "Authenticated.....!!!!"
    return @client
    rescue Exception => e
      puts e
      return nil
  end


=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will fetch records from salesforce.
         Created Date     :   21 April 2018
         Issue No.        :
                    record.class   -   Restforce::Collection
                    record.first.Id - get id
                    record.first.fetch('Id') - get id
                    lead = record.first    - get 1st record from collection
                    lead.sobject_type     - get sObject name e.g- Lead
                    lead.fetch('Id')      - get id
                    lead.Id               - get id
                    lead.destroy         - delete record
                    puts record.to_a[0].attrs['Id']    - get id
    **************************************************************************************************************************************
=end

  def getRecords(query)
    record = @client.query_all("#{query}") #where emailId = #{emailId}")
    return record.to_a
    #explain = @client.explain("#{query}")
    #puts explain.class
    #puts explain

    #find = @client.find('Lead', '00Q3D000003QtdjUAC')
    #puts find
=begin
    puts "hello"
    puts record.class

    puts record
    puts record.first.Id
    puts record.first.fetch('Id')


    puts record.to_a[0].attrs['Id']
    puts "***********"
    #puts record.to_a[0].describe
    puts "***********"
    lead = record.first
    puts lead.sobject_type
    puts lead.fetch('Id')
    puts lead.Id
=end
=begin
    #we cant update records like below
    lead.Name = "testtttttt"
    puts lead.save

    puts lead.destroy
    jsonRecord = EnziRestforce.getJson(record)
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts jsonRecord.size
    puts jsonRecord[1].fetch('Id')
    rec = jsonRecord[0]
    puts rec.Id
    puts rec.sobject_type
  
    puts rec.fetch('Id')
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@"
=end
  end

=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method stores created records in @@createdRecordsIds class varable.
         Created Date     :   21 April 2018
         Issue No.        :
    **************************************************************************************************************************************
=end
  def createdRecords(key,value)
    if @@createdRecordsIds.key?("#{key}") then
      @@createdRecordsIds["#{key}"] << Hash["Id" => value]
    else
      @@createdRecordsIds["#{key}"] = [Hash["Id" => value]]
    end
  end

=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will create record in salesforce.
                              returns id of created record in string format
         Created Date     :   21 April 2018
         Issue No.        :
                              records_to_insert = Hash.new
                              records_to_insert.store('Name','Kishor_shinde')
                              createRecord(sObject,records_to_insert)
    **************************************************************************************************************************************
=end
  def createRecord(sObject,records_to_insert)
    record = @client.create("#{sObject}", records_to_insert)
    puts record.inspect
    return record
  end

=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will get Created Records.
         Created Date     :   21 April 2018
         Issue No.        :
    **************************************************************************************************************************************
=end
  def getCreatedRecords()
    puts "in getCreated records"
    return @@createdRecordsIds
  end

=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will delete record.
         Created Date     :   21 April 2018
         Issue No.        :
                            EnziRestforce.deleteRecords(@client,'Account','0013D00000T6PnRQAV')
    **************************************************************************************************************************************
=end
 def deleteRecord(sObjectType,recordsToDelete)
   puts "in deleteRecords"
   if( recordsToDelete != nil ) #&& recordsToDelete.count > 0 && recordsToDelete.count < 10)
      result = @client.destroy("#{sObjectType}", recordsToDelete)
      return result
    else
      return nil
    end   
  end

=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will update record.
         Created Date     :   21 April 2018
         Issue No.        :
    **************************************************************************************************************************************
=end
  def updateRecord(sObject,updated_values)
    puts updated_values
    @client.update("#{sObject}",updated_values)
  end


=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will serach for records.
         Created Date     :   21 April 2018
         Issue No.        :


         result = EnziRestforce.serachRecord(@client,'FIND {Kishor_shinde} RETURNING Account (Name,Id)')
            puts result.to_a[0][1][0].attrs -> {"Name"=>"Kishor_shinde", "Id"=>"0013D00000TTzwQQAT"}
            puts result.to_a[0][1][0].attrs['Id']  ->  get id 
    **************************************************************************************************************************************
=end
  def searchRecord(query)
    result = @client.search(query)
    if result.to_a[0][1].size == 0 then
      puts "No records found"
    end
    return result.to_a[0][1]
  end
  def getUserInfo
    @client.user_info
  end
end


#obj = EnziRestforce.new('monika.pingale@wework.com.qaauto','monikaPingale@123','3MVG9PE4xB9wtoY9IbhNtYSuAVOegE_yR6h8s4fwIITYduuN1V8Tt84iUykgOM_X3lj7md_cCbNBlsN6D6LSc','3006740022073476903',true)

=begin
puts "1"
records_to_insert = Hash.new
records_to_insert.store('Name','Kishor_shinde')
#records = Array.new
#records.push(records_to_insert)
createdRecords = EnziRestforce.createRecords(@client,'Account',records_to_insert)
puts createdRecords
=end
#puts "2"
=begin
array = obj.getRecords("SELECT id,Looking_For_Number_Of_Desk__c,Name,Owner.Id,Owner.Name,RecordType.Name,RecordType.Id,Number_of_Full_Time_Employees__c FROM Contact limit 10")# where Id  = '00Q3D000003QtiAUAS'")
puts array[0].attrs
puts array[0].('RecordType')
puts array[0].'RecordType')['Name']
puts "121211"
puts array[0].fetch('RecordType.Name')
#puts array.class
#puts array[0].class
#puts array[1].class
#puts "################"
=end


=begin
recordMap = Hash.new
recordMap.store('Name','Kishor12345678987456123')
recordMap.store('Name1','Kishor12345678987456124')
ar = Array.new
ar= {"1":{"Name":"Kishor1"},"2":{"Name":"Kishor2"}}
=end

#EnziRestforce.createRecords(@client,'Account',ar)


#puts EnziRestforce.updateRecord(@client,'Account',recordMap)
#puts EnziRestforce.deleteRecords(@client,'Account','0013D00000T6PnRQAV')



=begin
puts array.inspect
puts "################"
puts array[0]
puts "################"
puts array[0].fetch('Id')
puts array.size
#puts @client.limits
=end



#puts "hiiiiiii"

# Find all occurrences of 'bar'
#srch = @client.search('FIND {bar}')
#puts srch
#puts "hhjhjhj"
#puts srch.to_a[0]
# => #<Restforce::Collection >
=begin
# Find accounts matching the term 'genepoint' and return the `Name` field
srch2 = @client.search('FIND {Kishor_shinde} RETURNING Account (Name,Id)')
puts "12121212"
puts srch2
puts "232323232"
puts srch2.to_a[0]
puts "4545454"
puts srch2.to_a[0][1]
puts "457887877878"
puts srch2.to_a[0][1].size
puts srch2.to_a[0][1][0].attrs
puts srch2.to_a[0][1][0].attrs['Id']
# => ['GenePoint']
=end



# Get the global describe for all sobjects
#puts "jjjjjj"
#puts @client.describe
# => { ... }

# Get the describe for the Account object
#puts @client.describe_layouts('Account')
# => { ... }


