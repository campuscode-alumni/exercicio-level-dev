class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :pix_settings, dependent: :destroy
  has_many :credit_card_settings, dependent: :destroy
  has_many :boleto_settings, dependent: :destroy

  enum status: { incomplete: 0, pending: 10, accepted: 20, rejected: 30 }

  has_one :owner, -> { where owner: true },
          class_name: 'User', inverse_of: 'company', dependent: :destroy

  after_save :check_if_still_incomplete
  after_save :generate_token_if_accepted

  validates :cnpj, :legal_name, :billing_address, :billing_email,
            presence: true, on: :update
  validates :billing_email, private_email: true, on: :update
  validates :cnpj, cnpj: true, on: :update

  def payment_settings
    pix_settings + credit_card_settings + boleto_settings
  end

  def blank_all_info!
    self.cnpj = ''
    self.legal_name = ''
    self.billing_address = ''
    self.billing_email = ''
    self.status = :incomplete

    save(validate: false)
  end

  private

  def any_essential_info_blank?
    [cnpj, legal_name, billing_address, billing_email].all?(&:blank?)
  end

  def check_if_still_incomplete
    pending! if !any_essential_info_blank? && incomplete?
  end

  def accepted_but_no_token?
    token.blank? && accepted?
  end

  def generate_token_if_accepted
    return unless token.blank? && accepted?

    self.token = generate_token
    save!
  end
end
