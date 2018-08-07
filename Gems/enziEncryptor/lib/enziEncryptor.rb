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

