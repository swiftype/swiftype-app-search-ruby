# Engines are the core concept representing indexes in App Search.
#
module SwiftypeAppSearch
  class Client
    module Engines
      def list_engines
        get("engines")
      end

      def get_engine(engine_name)
        get("engines/#{engine_name}")
      end

      def create_engine(engine_name)
        post("engines", :name => engine_name)
      end

      def destroy_engine(engine_name)
        delete("engines/#{engine_name}")
      end
    end
  end
end
