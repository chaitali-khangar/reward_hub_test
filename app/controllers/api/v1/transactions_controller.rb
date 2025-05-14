module Api
  module V1
    class TransactionsController < BaseController
      def index
        @transactions = @user.transactions.order(created_at: :desc)
        render :index, status: :ok
      end

      def create
        @transaction = @user.transactions.new(transaction_params)
        if @transaction.save
          render :show, status: :created
        else
          render json: { 'errors' => @transaction.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

        def transaction_params
          params.require(:transaction).permit(:amount, :country, :external_id, :transaction_date)
        end
    end
  end
end
