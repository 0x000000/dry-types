require 'dry/types/decorator'

module Dry
  module Types
    class Enum
      include Type
      include Dry::Equalizer(:type, :options, :values)
      include Decorator

      # @return [Array]
      attr_reader :values

      # @return [Hash]
      attr_reader :mapping

      # @param [Type] type
      # @param [Hash] options
      # @option options [Array] :values
      def initialize(type, options)
        super
        @values = options.fetch(:values).freeze
        @values.each(&:freeze)
        @mapping = values.each_with_object({}) { |v, h| h[values.index(v)] = v }.freeze
      end

      # @param [Object] input
      # @return [Object]
      def call(input = Undefined)
        value =
          if input.equal?(Undefined)
            type.call
          elsif values.include?(input)
            input
          elsif mapping.key?(input)
            mapping[input]
          else
            input
          end

        type[value]
      end
      alias_method :[], :call

      def default(*)
        raise '.enum(*values).default(value) is not supported. Call '\
              '.default(value).enum(*values) instead'
      end

      # Check whether a value is in the enum
      # @param [Object] value
      # @return [Boolean]
      alias_method :include?, :valid?

      # @api public
      #
      # @see Definition#to_ast
      def to_ast(meta: true)
        [:enum, [type.to_ast(meta: meta),
                 values,
                 meta ? self.meta : EMPTY_HASH]]
      end
    end
  end
end
