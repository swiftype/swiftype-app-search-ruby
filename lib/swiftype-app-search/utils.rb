module SwiftypeAppSearch
  module Utils
    extend self

    def stringify_keys(hash)
      hash.each_with_object({}) do |(key, value), out|
        out[key.to_s] = value
      end
    end

    def symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), out|
        new_key = key.respond_to?(:to_sym) ? key.to_sym : key
        out[new_key] = value
      end
    end
  end
end
