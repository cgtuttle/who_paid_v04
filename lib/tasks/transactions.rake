namespace:transactions do

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