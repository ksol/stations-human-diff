require "openssl"

module SHD
  module Utils
    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack("C*")
      r = 0
      i = -1

      b.each_byte { |v| r |= v ^ l[i += 1] }

      r == 0
    end
    module_function :secure_compare

    def verify_signature(payload_body, expected)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['STATIONS_GITHUB_APP_WEBHOOK_SECRET'], payload_body)

      signature && expected && secure_compare(signature, expected)
    end
    module_function :verify_signature
  end
end
