class Interlatch::InvalidationObserver < ActiveRecord::Observer
  def self.observed_classes
    ActiveRecord::Base.descendants
  end

  def after_save(model)
    (Rails.cache.fetch(Interlatch.dependency_key(model.class)) || []).each do |key|
      Rails.cache.delete(key)
    end
  end
end
