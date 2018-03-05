require "singleton"

module SHD
  class Logger
    include Singleton

    class << self
      def method_missing(name, *args, &block)
        if instance.respond_to?(name)
          instance.public_send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, *_args)
        instance.respond_to?(name)
      end
    end

    def info(string)
      output(string)
    end

    def warn(string)
      output(string)
    end

    def error(string)
      output(string, $stderr)
    end

    def fatal(string)
      output(string, $stderr)
    end

    def output(string, out = $stdout)
      out.puts string
    end
  end
end
