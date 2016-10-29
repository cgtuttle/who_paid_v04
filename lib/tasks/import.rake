require 'csv'

namespace:import do
	counter = 0

	# rake import:users
	desc "Import users from /vendor/imports/users.csv"
	task users: :environment do
		filename = File.join Rails.root, "/vendor/imports/users.csv"
		CSV.foreach(filename, headers: true) do |row|
			id,email,first,last = row
			user = User.create(id: id, email: email, first_name: first, last_name: last, role: "guest")
			puts "#{email} - #{user.errors.full_messages.join(',')}" if user.errors.any?
			counter += 1 if user.persisted?
		end
		puts "Imported #{counter} users."
		reset_key_sequence("users")
	end

	desc "Import events from /vendor/imports/events.csv"
	task events: :environment do
		filename = File.join Rails.root, "/vendor/imports/events.csv"
		CSV.foreach(filename, headers: true) do |row|
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

	desc "Import accounts from /vendor/imports/accounts.csv"
	task accounts: :environment do
		filename = File.join Rails.root, "/vendor/imports/accounts.csv"
		CSV.foreach(filename, headers: true) do |row|
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

	desc "Import payments from /vendor/imports/payments.csv"
	task payments: :environment do
		filename = File.join Rails.root, "/vendor/imports/payments.csv"
		CSV.foreach(filename, headers: true) do |row|
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

	desc "Import allocations from /vendor/imports/allocations.csv"
	task allocations: :environment do
		filename = File.join Rails.root, "/vendor/imports/allocations.csv"
		CSV.foreach(filename, headers: true) do |row|
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

	desc "Import account_transactions from /vendor/imports/account_transactions.csv"
	task account_transactions: :environment do
		filename = File.join Rails.root, "/vendor/imports/account_transactions.csv"
		CSV.foreach(filename, headers: true) do |row|
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