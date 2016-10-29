namespace:transactions do
	namespace:clear do

		desc "Delete all transactions and allocations"
		task transactions: :environment do
			puts "Deleting Account Transactions..."
			AccountTransaction.delete_all
			puts "Deleting Allocations..."
			Allocation.delete_all
			puts "Completed successfully."
		end

		desc "Delete all payments"
		task payments: :environment do
			puts "Deleting payments..."
			Payment.delete_all
			puts "Completed successfully."
		end
	end

	desc "Reprocess all payments"
	task reprocess: :environment do
		puts "Processing payments..."
		Payment.all.each do |payment|
			print "."
			PaymentProcess.new(payment).execute
		end
		puts ""
		puts "Completed successfully."
	end

end