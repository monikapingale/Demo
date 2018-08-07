class EnziUIUtility
  def initialize()
    #puts @driver.title
  end

  #Use: This function print the page title
  def self.getPageTitle(driver)
    puts driver.title
  end

  #Use: This function use to set value of html element
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #Example: setValue(:id,'txtMinVal',20)
  def self.setValue(driver,findBy,elementIdentification,val)
    puts "setting value of #{elementIdentification} to #{val}"
     element = driver.find_element(findBy,elementIdentification)
     if element.enabled? then
      element.send_keys val
    else
       return "cant set value of disabled input element"
    end
  end
   #Use: This function use to open a visualforce page
   #Example: setValue('contactDetailPage')
  def self.navigateToUrl(driver,url)
     driver.navigate.to url
  end

  #Use: This function click the html element
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #Example: clickElement(:id,'btnSubmit')
  def self.clickElement(driver,findBy,elementIdentification)
    driver.execute_script("arguments[0].scrollIntoView();" , driver.find_element(findBy ,elementIdentification))
    driver.find_element(findBy ,elementIdentification).click
  end


  def self.getValue(driver,findBy,elementIdentification)
    return driver.find_element(findBy,elementIdentification).attribute('value')
  end

  #Use: This function use to wait code to execute till element gets created on page or page contains gets loaded
  #Parameters: findBy: Use to find element using id,name,class,xpath
  #            parentElementId: Use to send name(id,name,class,xpath) to find element
  #            childElementTagName: childElement tag from which we need to select the value/option
  #            textToSelect: It is text need to select a child
  #            childTabName: It is a child tag name which we need to find
  #Example: selectChild(':id','selectid','Default view',"input")
  def self.selectElement(driver,textToselect,elementTosearch)
    all_Elements = driver.find_elements(:tag_name,"#{elementTosearch}")
    all_Elements.each do |element|
      #select element by provided text 
      if textToselect != nil then
    
        if element.text == textToselect then
         
          return element
        end
      end
    end
  end
  def self.selectChild(driver,findBy,parentElementId,textToselect,childTagName)
    #Get the parent element
    childs = Array.new
    parent = driver.find_element(findBy,parentElementId)
    #Get all the childs for this element
    all_child = parent.find_elements(:tag_name, "#{childTagName}")
    #get the specified child element
    all_child.each do |child|
      #select child by privided text 
      if textToselect != nil then
        if child.text == textToselect then
          child.click
        break
       end
     else
      childs.push(child)
     end
    end
    return childs
  end
   #Use:This function is use to switch driver control from main window to Availability browser window
  def self.switchToWindow(driver,titleName)
    #self.wait(driver,nil,nil,5)
    #Get all currnt open window
    allWindows = driver.window_handles
        #Find any new window open
        allWindows.each do |window|
          #if isMainWindow && @@mainWindow != window then
            driver.switch_to.window(window)
            puts driver.title
            if(titleName == driver.title) then
              break
            end
         # end #End of @@mainWindow if
        end #end of forEach for allWindows
    #self.wait(driver,nil,nil,5)
  end


  #Use: This function use to wait code to execute till element gets created on page or page contains gets loaded
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #            waittime: Time till wail for element to load
  #Example: wait(:id,'txtMinVal',20)
  def self.wait(driver,findBy,elementIdentification,waitTime)
    if elementIdentification != nil then
      wait = Selenium::WebDriver::Wait.new(:timeout => waitTime)
      wait.until {driver.find_element(findBy ,elementIdentification)}
    else
      sleep(waitTime)
    end
  end

  #Use: This function close the current browser
  def self.quit(driver)
    driver.quit
  end

  def self.closeWindow(driver)
    driver.close()
    #driver.switch_to.window(mainWindow)
  end

  def self.switchToDefault(driver)
    #driver.switch_to.default_content
    driver.switch_to.window((driver.window_handles)[0])
  end


 #Use: Switch element between frames
  def self.switchToFrame(driver,frameName)
    puts "in EnziUIUtility :: switchToFrame with frameName::#{frameName}"
    driver.switch_to.frame(frameName)
    puts "7878"
    rescue Exception => e
    puts "Exception in EnziUIUtility :: switchToFrame -> #{e} !!!"
    raise
  end

  #Use: This function is use to switch to frame if it's name not known.
  #     This function first get the available frames and then swithc to each frame till it does not find element available on frame
  def self.switchToFrames(driver,findBy,elementIdentification)
    lstIframes = driver.find_elements(:tag_name,'iframe')
    lstIframes.each do|fr|
      if(fr.displayed? == true)
        driver.switch_to.frame(fr)
        if((driver.find_elements(findBy,elementIdentification).count > 0))
          break
        else
          driver.switch_to.window(allWindows[0])
        end
      end
    end
  end

 def self.getBaseUrl(driver)
       urlArr = driver.current_url.split('/')
       return (urlArr[0]+"//"+urlArr[2]+"/")
 end

  def self.getElementWithFocus(driver,findBy,elementIdentification)
    ele = driver.find_element(findBy ,elementIdentification)
    driver.execute_script("arguments[0].scrollIntoView();" , driver.find_element(findBy ,elementIdentification))
    return driver.find_element(findBy ,elementIdentification)
  end

  def self.checkErrorMessage(driver,elementTosearch,textToCheck)
    all_Elements = driver.find_elements(:tag_name,"#{elementTosearch}")
    all_Elements.each do |element|
      if textToCheck != nil then
        if element.text == textToCheck then
          return true
        end
      end
    end
    return false
  end


  #Use: This function is Used to switching to lightening from classic
  def self.switchToLightening(driver)
    #puts "in switch to lightning"
    self.wait(driver,:xpath,"//*[@title='Search Salesforce'] | //*[@id='phSearchInput']",60)
    if !(driver.current_url().include? "lightning")
      #puts "String not 'lightning'"
      self.wait(driver,:id,"userNav-arrow",30)
      driver.find_element(:id, "userNav-arrow").click
      self.wait(driver,:link,"Switch to Lightning Experience",30)

      driver.find_element(:link , "Switch to Lightning Experience").click
    else
      puts "u r already in lightning ha ha ha ------>>"
    end
    true
  rescue Exception => e 
    puts "Exception in EnziUIUtility :: switchToLightening -> #{e} !!!"
    nil
  end

  #Use: This function is Used to switching to classic from lightening
  def self.switchToClassic(driver)
    puts 'in switchToClassic'
    self.wait(driver,:xpath,"//*[@title='Search Salesforce'] | //*[@id='phSearchInput']",60)
    #puts driver.current_url()
    if (driver.current_url().include? "lightning")
      switchToWindow(driver,driver.current_url)
      #puts "1"
      self.wait(driver,:class,"oneUserProfileCardTrigger",30)
      #puts "String 'lightning'"
      #puts "2"
      #sleep(5)
      driver.find_element(:class, "oneUserProfileCardTrigger").click
      #puts "3"
      #driver.find_element(:class, "oneUserProfileCardTrigger").click
      #puts "4"
      #sleep(3)
      self.wait(driver,:class,"oneUserProfileCardTrigger",30)
      #puts "5"
      #sleep(3)
      self.wait(driver,:link,"Switch to Salesforce Classic",30)
      
      driver.find_element(:link , "Switch to Salesforce Classic").click
      puts "6"
    else
      puts "you are allready in classic"
    end
    puts "7"
    return true
  rescue Exception => e 
    puts "Exception in EnziUIUtility :: switchToClassic -> #{e} !!!"
    nil
  end

  def self.loginForUser(driver,profile_name)
   
    tBodyEle = driver.find_element(:class,"list").find_element(:tag_name,'tbody')
    arrRows = tBodyEle.find_elements(:tag_name,'tr')
    arrRows.each do |row|
      row.find_elements(:tag_name,'td').each do |col|
        if(col.text == "#{profile_name}")
          row.find_element(:tag_name,'th').text
          row.find_element(:link, 'Login').click
          return nil
        end
      end
    end
  end
  def self.logout(driver)
    if !(driver.current_url().include? "lightning") then
      driver.get "#{driver.current_url().split("/apex")[0]}"
      EnziUIUtility.clickElement(driver,:id,"userNavButton")
      EnziUIUtility.selectElement(driver,"Logout","a").click
    else
      switchToWindow(driver,driver.current_url)
      self.wait(driver,:class,"oneUserProfileCardTrigger",20)
      EnziUIUtility.clickElement(driver,:class,"oneUserProfileCardTrigger")
      self.wait(driver,:class,"uiOutputURL",20)
      EnziUIUtility.selectElement(driver,"Log Out","a").click
    end
  end
 end


