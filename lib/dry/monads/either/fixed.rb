module Dry::Monads
  class Either
    class Fixed < Module
      def self.[](error, **options)
        new(error, **options)
      end

      def initialize(error, **options)
        @mod = Module.new do
          define_method(:Left) do |value|
            Left.new(error[value])
          end

          def Right(value)
            Right.new(value)
          end
        end
      end

      def included(base)
        super

        base.include(@mod)
      end
    end
  end
end
