module Rewards
  class BaseService
    private

      def success_response(message)
        { success: true, message: message }
      end

      def error_response(message)
        { success: false, message: message }
      end
  end
end
