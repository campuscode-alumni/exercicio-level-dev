class BoletoSetting < ApplicationRecord
  belongs_to :company
  belongs_to :payment_method, -> { where(type_of: :boleto) }, inverse_of: :boleto_settings

  enum status: { enabled: 5, disabled: 10 }

  validates :agency_number, :account_number, :bank_code, presence: true
  validates :bank_code, bank_code: true
  after_create :generate_token_attribute
end
