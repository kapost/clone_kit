module CloneKit
  module Emitters
    class BaseActiveRecordEmitter
      def initialize(model_klass, query: :all)
        self.klass = model_klass
        self.query = query
      end

      def scope(*)
        klass.send(query)
      end

      def emit_all
        scope
      end

      private

      attr_accessor :klass, :query
    end
  end
end
