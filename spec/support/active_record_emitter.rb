# frozen_string_literal: true

class ActiveRecordEmitter
  def initialize(model_klass)
    self.klass = model_klass
  end

  def scope(*)
    klass.all
  end

  def emit_all
    scope
  end

  private

  attr_accessor :klass
end
