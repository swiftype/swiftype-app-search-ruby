# Search Settings is used to adjust weights and boosts
module SwiftypeAppSearch
  class Client
    module SearchSettings

      # Show all Weights and Boosts applied to the search fields of an Engine.
      #
      # @param [String] engine_name the unique Engine name
      #
      # @return [Hash] current Search Settings
      def show_settings(engine_name)
        get("engines/#{engine_name}/search_settings")
      end

      # Update Weights or Boosts for search fields of an Engine.
      #
      # @param [String] engine_name the unique Engine name
      # @param [Hash] settings new Search Settings Hash
      #
      # @return [Hash] new Search Settings
      def update_settings(engine_name, settings)
        put("engines/#{engine_name}/search_settings", settings)
      end

      # Reset Engine's Search Settings to default values.
      #
      # @param [String] engine_name the unique Engine name
      #
      # @return [Hash] default Search Settings
      def reset_settings(engine_name)
        post("engines/#{engine_name}/search_settings/reset")
      end
    end
  end
end
