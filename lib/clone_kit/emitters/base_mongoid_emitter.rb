module CloneKit
  module Emitters
    class BaseMongoidEmitter
      def initialize(model_klass, query: :all)
        self.klass = model_klass
        self.query = query
      end

      def scope(*)
        klass.send(query)
      end

      def emit_all
        scope.to_a
      end

      private

      attr_accessor :klass, :query
    end
  end
end
