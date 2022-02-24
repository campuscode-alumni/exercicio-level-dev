require 'rails_helper'

describe 'Owner creates credit card payment setting' do
  it 'successfully' do
    owner = create(:user, :complete_company_owner)
    company = owner.company
    company.accepted!

    credit_card_method, * = create_list(:payment_method, 3, :credit_card)

    login_as owner, scope: :user
    visit company_path owner.company
    click_on 'Meios de pagamento configurados'
    click_on 'Configurar novo cartão de crédito'

    fill_in 'Código do cartão', with: '2456785847953874'
    select credit_card_method.name, from: 'Meio de pagamento'
    click_on 'Criar Cartão de crédito'

    expect(current_path).to eq(company_payment_settings_path(owner.company))
    expect(page).to have_content('Pagamento configurado com sucesso')
    expect(page).to have_content('Código do cartão: 2456785847953874')
    expect(owner.company.payment_settings).to include(CreditCardSetting.first)
  end
end
