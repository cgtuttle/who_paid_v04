class Payment < ActiveRecord::Base
  belongs_to :event
  belongs_to :payer_account, class_name: "Account", foreign_key: :account_from
  belongs_to :payee_account, class_name: "Account", foreign_key: :account_to
  has_many :account_transactions, as: :journal

  attr_accessor :payee_name, :payer_name



end
