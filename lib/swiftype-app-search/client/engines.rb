# Engines are the core concept representing indexes in App Search.
#
module SwiftypeAppSearch
  class Client
    module Engines
      def list_engines(current: 1, size: 20)
        get("engines", :page => { :current => current, :size => size })
      end

      def get_engine(engine_name)
        get("engines/#{engine_name}")
      end

      def create_engine(engine_name, language = nil)
        params = { :name => engine_name }
        params[:language] = language if language
        post("engines", params)
      end

      def destroy_engine(engine_name)
        delete("engines/#{engine_name}")
      end
    end
  end
end
