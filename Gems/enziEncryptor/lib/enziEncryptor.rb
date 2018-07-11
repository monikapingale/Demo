=begin
************************************************************************************************************************************
    Author      :   QaAutomationTeam
    Description :   This gem ....

    History     :
  ----------------------------------------------------------------------------------------------------------------------------------
  VERSION           DATE             AUTHOR                  DETAIL
  1                 20 June 2018     QaAutomationTeam        Initial Developement
**************************************************************************************************************************************
=end
require 'encryptor'
require 'securerandom'
require 'base64'
class EnziEncryptor

=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will encrypt confidetial data using provided key. Here key must be 32 bytes
         Created Date     :   21 April 2018
    **************************************************************************************************************************************
=end
  def self.encrypt(data,key)
=begin
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.encrypt
    @@iv = [cipher.random_iv]
    @@salt = SecureRandom.random_bytes(16)
    encrypted_value = [Encryptor.encrypt(value: "#{data}", key: key, iv: @@iv[0], salt: @@salt)]
    puts "encrypted_value-->#{encrypted_value}"
    return "#{encrypted_value[0]}"
=end
    cipher = OpenSSL::Cipher.new 'aes-256-cbc'
    cipher.encrypt
    cipher.key = Base64.decode64(key.encode('ascii-8bit'))
    iv= cipher.random_iv
    cipher.iv = iv
    encrypted = cipher.update data
    encrypted << cipher.final
    return Base64.encode64("#{encrypted}$@$#{iv}").encode('utf-8')
  end

=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will decrypt encrypted data using key used to encrypt it.
         Created Date     :   21 April 2018
         Issue No.        :
    **************************************************************************************************************************************
=end
  def self.decrypt(encrypted_value,key)
    decipher = Base64.decode64(encrypted_value.encode('ascii-8bit')).split('$@$')
    cipher = OpenSSL::Cipher.new 'aes-256-cbc'
    cipher.decrypt
    cipher.key = Base64.decode64(key.encode('ascii-8bit'))
    cipher.iv = decipher[1]
    decrypted = cipher.update decipher[0]
    decrypted << cipher.final
    return decrypted
  end

end #end of class
#str = '\xEC6\xB7\x9AL\xC1\x93\x9E\x0E\xE8\x8A\x0F\\\x9F2\x8C\x93Y\x7FH\ev\xE9|7\x8A\eq\xD3\xB5&\x87'
=begin
newStr = EnziEncryptor.encrypt("MyValue",str).to_s
puts "UTF*======"
puts newStr
puts "ASCCIIII"
encStr = newStr.force_encoding('ASCII-8BIT').encode('ASCII-8BIT')
puts encStr
EnziEncryptor.decrypt(encStr,str)
puts EnziEncryptor.decrypt(EnziEncryptor.encrypt('postgres://yjdxfiwamhnvtj:983b2b1792de9439f4ba133618903170b9364855fdbf868de89e524b465bfecd@ec2-54-243-137-182.compute-1.amazonaws.com:5432/d74mgl2e7s64ph','JUUulOQoqK6saOOfnDlKx1YpKdG8sAdIPwqcPuZo/dI='),'JUUulOQoqK6saOOfnDlKx1YpKdG8sAdIPwqcPuZo/dI=').eql? "postgres://yjdxfiwamhnvtj:983b2b1792de9439f4ba133618903170b9364855fdbf868de89e524b465bfecd@ec2-54-243-137-182.compute-1.amazonaws.com:5432/d74mgl2e7s64ph"
=end

#puts '\xEC6\xB7\x9AL\xC1\x93\x9E\x0E\xE8\x8A\x0F\\\x9F2\x8C\x93Y\x7FH\ev\xE9|7\x8A\eq\xD3\xB5&\x87'.codepoints.pack('U*')
#puts []

