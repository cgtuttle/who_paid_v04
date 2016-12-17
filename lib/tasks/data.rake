require 'csv'

namespace:data do	
	namespace:clear do

		# rake data:clear:all

		desc "Delete all data"
		task all: :environment do
			["data:clear:transactions", 
				"data:clear:payments", 
				"data:clear:accounts", 
				"data:clear:events", 
				"data:clear:users"
				].each do |t|
				Rake::Task[t].execute
			end
		end

		# rake data:clear transactions

		desc "Delete all transactions and allocations"
		task transactions: :environment do
			puts "Deleting Account Transactions..."
			AccountTransaction.delete_all
			puts "Deleting Allocations..."
			Allocation.delete_all
			puts "Completed successfully."
		end

		# rake data:clear payments

		desc "Delete all payments"
		task payments: :environment do
			puts "Deleting payments..."
			Payment.delete_all
			puts "Completed successfully."
		end

		# rake data:clear accounts

		desc "Delete all Accounts"
		task accounts: :environment do
			puts "Deleting accounts..."
			Account.delete_all
			puts "Completed successfully."
		end

		# rake data:clear events

		desc "Delete all events"
		task events: :environment do
			puts "Deleting events..."
			Event.delete_all
			puts "Completed successfully."
		end

		# rake data:clear users

		desc "Delete all users except admin"
		task users: :environment do
			puts "Deleting users..."
			User.where.not(email: "admin@whopaid.us" ).delete_all
			puts "Completed successfully."
		end
	end

	namespace:import do
		counter = 0

		# rake data:import:users

		desc "Import users from /vendor/imports/users.csv"
		task users: :environment do
			filename = File.join Rails.root, "/vendor/imports/users.csv"
			CSV.foreach(filename, headers: true) do |row|
				puts "importing #{row}"
				user = User.create(id: row["id"], 
					email: row["email"], 
					first_name: row["first"], 
					last_name: row["last"], 
					role: "guest")
				puts "#{email} - #{user.errors.full_messages.join(',')}" if user.errors.any?
				counter += 1 if user.persisted?
			end
			puts "Imported #{counter} users."
			reset_key_sequence("users")
		end

		# rake data:import:events

		desc "Import events from /vendor/imports/events.csv"
		task events: :environment do
			filename = File.join Rails.root, "/vendor/imports/events.csv"
			CSV.foreach(filename, headers: true) do |row|
				puts "importing #{row}"
				event = Event.create(id: row["id"], 
					name: row["name"], 
					created_at: row["created_at"], 
					updated_at: row["updated_at"], 
					owner_id: row["owner_id"])
				puts "#{row[:name]} - #{event.errors.full_messages.join(',')}" if event.errors.any?
				counter += 1 if event.persisted?
			end
			puts "Imported #{counter} events."
			reset_key_sequence("events")
		end

		# rake data:import:users

		desc "Import accounts from /vendor/imports/accounts.csv"
		task accounts: :environment do
			filename = File.join Rails.root, "/vendor/imports/accounts.csv"
			CSV.foreach(filename, headers: true) do |row|
				puts "importing #{row}"
				account = Account.create(id: row["id"], 
					source_id: row["source_id"], 
					source_type: row["source_type"], 
					account_name: row["account_name"], 
					event_id: row["event_id"],
					created_at: row["created_at"], 
					updated_at: row["updated_at"])
				puts "#{row[:id]} - #{account.errors.full_messages.join(',')}" if account.errors.any?
				counter += 1 if account.persisted?
			end
			puts "Imported #{counter} accounts."
			reset_key_sequence("accounts")
		end

		# rake data:import:payments

		desc "Import payments from /vendor/imports/payments.csv"
		task payments: :environment do
			filename = File.join Rails.root, "/vendor/imports/payments.csv"
			CSV.foreach(filename, headers: true) do |row|
				puts "importing #{row}"
				new_record = Payment.create(id: row["id"], 
					event_id: row["event_id"], 
					payment_date: row["payment_date"], 
					account_from: row["account_from"], 
					account_to: row["account_to"], 
					deleted: row["deleted"],
					amount: row["amount"],	
					for: row["for"],	
					created_at: row["created_at"], 
					updated_at: row["updated_at"])
				puts "#{row[:id]} - #{new_record.errors.full_messages.join(',')}" if new_record.errors.any?
				counter += 1 if new_record.persisted?
			end
			puts "Imported #{counter} new records."
			reset_key_sequence("payments")
		end

		# rake data:import:allocations

		desc "Import allocations from /vendor/imports/allocations.csv"
		task allocations: :environment do
			filename = File.join Rails.root, "/vendor/imports/allocations.csv"
			CSV.foreach(filename, headers: true) do |row|
				puts "importing #{row}"
				new_record = Allocation.create(id: row["id"], 
					journal_id: row["journal_id"],
					journal_type: row["journal_type"],
					account_id: row["account_id"],
					allocation_method: row["allocation_method"],
					allocation_entry: row["allocation_entry"],
					allocation_factor: row["allocation_factor"],
					created_at: row["created_at"], 
					updated_at: row["updated_at"])
				puts "#{row[:id]} - #{new_record.errors.full_messages.join(',')}" if new_record.errors.any?
				counter += 1 if new_record.persisted?
			end
			puts "Imported #{counter} new records."
			reset_key_sequence("allocations")
		end

		# rake data:import:account_transactions

		desc "Import account_transactions from /vendor/imports/account_transactions.csv"
		task account_transactions: :environment do
			filename = File.join Rails.root, "/vendor/imports/account_transactions.csv"
			CSV.foreach(filename, headers: true) do |row|
				puts "importing #{row}"
				if row["account_exists"]
					new_record = AccountTransaction.create(id: row["id"], 
						journal_id: row["journal_id"],
						journal_type: row["journal_type"],
						account_id: row["account_id"],
						debit: row["debit"],
						credit: row["credit"],
						entry_type: row["entry_type"],
						sub_journal_id: row["sub_journal_id"],
						sub_journal_type: row["sub_journal_type"],
						reversal_id: row["reversal_id"],
						occurred_on: row["occurred_on"],
						created_at: row["created_at"], 
						updated_at: row["updated_at"])
				end
				puts "#{row[:id]} - #{new_record.errors.full_messages.join(',')}" if new_record.errors.any?
				counter += 1 if new_record.persisted?
			end
			puts "Imported #{counter} new records."
			reset_key_sequence("account_transactions")
		end

		def reset_key_sequence(model)
			sql = "SELECT setval(pg_get_serial_sequence('#{model}', 'id'), coalesce(max(id),0) + 1, false) FROM #{model};"
			next_id = ActiveRecord::Base.connection.execute(sql)
			puts "Updated primary key sequence"
		end

	end

end