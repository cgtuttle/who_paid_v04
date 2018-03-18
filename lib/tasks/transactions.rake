namespace:transactions do

	# rake transactions:reprocess

	desc "Reprocess all payments"
	task reprocess: :environment do
		puts "Processing payments..."
		Payment.all.each do |payment|
			print "."
			PaymentProcess.new(payment).create
		end
		puts ""
		puts "Completed successfully."
	end

end