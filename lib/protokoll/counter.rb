require 'active_record'

module Protokoll
  class Counter
    def self.compute_next(object, options)
      element = Models::CustomAutoIncrement.find_or_create_by(klass_name: options[:klass_name] || object.class.to_s.underscore)

      element.counter = options[:start] if outdated?(element, options) || element.counter == 0
      element.counter += 1

      element
    end

    def self.preview_next(object, options)
      element = compute_next(object, options)

      Formater.new.format(element.counter, options)
    end

    def self.next(object, options)
      element = compute_next(object, options)

      element.touch unless element.changed?
      element.save! if element.changed?

      Formater.new.format(element.counter, options)
    end

    private

    def self.outdated?(record, options)
      Time.now.strftime(update_event(options)).to_i > record.updated_at.strftime(update_event(options)).to_i
    end

    def self.update_event(options)
      pattern = options[:pattern]
      event = String.new

      event += "%Y" if pattern.include? "%y" or pattern.include? "%Y"
      event += "%m" if pattern.include? "%m"
      event += "%H" if pattern.include? "%H"
      event += "%M" if pattern.include? "%M"
      event += "%d" if pattern.include? "%d"
      event
    end
  end
end
