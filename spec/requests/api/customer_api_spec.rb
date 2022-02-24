require 'rails_helper'

describe 'Customer API' do
  context 'GET /api/v1/customer' do
    it 'should get all customers' do
      owner = create(:user, :complete_company_owner)
      owner.company.accepted!

      customer1 = create(:customer, company: owner.company)
      customer2 = create(:customer, company: owner.company)

      get '/api/v1/customer', headers: { companyToken: owner.company.token }

      expect(response).to have_http_status(200)
      expect(response.content_type).to include('application/json')
      expect(parsed_body.first[:customer][:name]).to eq(customer1.name)
      expect(parsed_body.first[:customer][:cpf]).to eq(customer1.cpf)
      expect(parsed_body.first[:customer][:token]).to eq(customer1.token)
      expect(parsed_body.first[:customer][:company][:legal_name]).to eq(owner.company.legal_name)
      expect(parsed_body.second[:customer][:name]).to eq(customer2.name)
      expect(parsed_body.second[:customer][:cpf]).to eq(customer2.cpf)
      expect(parsed_body.second[:customer][:token]).to eq(customer2.token)
      expect(parsed_body.second[:customer][:company][:legal_name]).to eq(owner.company.legal_name)
    end
  end

  context 'GET /api/v1/customer/:token' do
    it 'should get all customers' do
      owner = create(:user, :complete_company_owner)
      owner.company.accepted!

      customer1 = create(:customer, company: owner.company)
      customer2 = create(:customer, company: owner.company)

      get '/api/v1/customer', headers: { companyToken: owner.company.token }

      expect(response).to have_http_status(200)
      expect(response.content_type).to include('application/json')
      expect(parsed_body.first[:customer][:name]).to eq(customer1.name)
      expect(parsed_body.first[:customer][:cpf]).to eq(customer1.cpf)
      expect(parsed_body.first[:customer][:token]).to eq(customer1.token)
      expect(parsed_body.first[:customer][:company][:legal_name]).to eq(owner.company.legal_name)
      expect(parsed_body.second[:customer][:name]).to eq(customer2.name)
      expect(parsed_body.second[:customer][:cpf]).to eq(customer2.cpf)
      expect(parsed_body.second[:customer][:token]).to eq(customer2.token)
      expect(parsed_body.second[:customer][:company][:legal_name]).to eq(owner.company.legal_name)
    end
    it 'should return 500 if database is not available' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      create(:customer, company: company)

      allow(Customer).to receive(:all).and_raise(ActiveRecord::ActiveRecordError)

      get '/api/v1/customer', headers: { companyToken: company.token }

      expect(response).to have_http_status(500)
    end
  end

  context 'GET /api/v1/customer/:token' do
    it 'should get customer 1' do
      owner = create(:user, :complete_company_owner)
      owner.company.accepted!

      customer1 = create(:customer, company: owner.company)
      customer2 = create(:customer, company: owner.company)

      get "/api/v1/customer/#{customer1.token}", headers: { companyToken: owner.company.token }

      expect(response).to have_http_status(200)
      expect(response.content_type).to include('application/json')
      expect(parsed_body[:customer][:name]).to eq(customer1.name)
      expect(parsed_body[:customer][:cpf]).to eq(customer1.cpf)
      expect(parsed_body[:customer][:token]).to eq(customer1.token)
      expect(parsed_body[:customer][:company][:legal_name]).to eq(owner.company.legal_name)
      expect(parsed_body[:customer][:token]).to_not eq(customer2.token)
    end

    it 'should return 404 if setting does not exist' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      get '/api/v1/customer/999', headers: { companyToken: company.token }

      expect(response).to have_http_status(404)
    end

    it 'should return 401 if setting is from another company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      create(:customer, company: company)
      customer2 = create(:customer, company: other_company)

      get "/api/v1/customer/#{customer2.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(401)
    end

    it 'should return 500 if database is not available' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      customer1 = create(:customer, company: company)

      allow(Customer).to receive(:find_by).and_raise(ActiveRecord::ActiveRecordError)

      get "/api/v1/customer/#{customer1.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(500)
    end
  end

  context 'POST /api/v1/customer' do
    it 'should save a new customer' do
      owner = create(:user, :complete_company_owner)

      owner.company.accepted!
      customer_params = { customer: { name: 'Caio Silva',
                                      cpf: '41492765872' } }

      allow(SecureRandom).to receive(:alphanumeric).with(20).and_return('LI5YuUJrZuJSB6uPH2jm')

      post '/api/v1/customer', params: customer_params, headers: { companyToken: owner.company.token }

      expect(response).to have_http_status(201)
      expect(response.content_type).to include('application/json')
      expect(parsed_body[:customer][:name]).to eq('Caio Silva')
      expect(parsed_body[:customer][:cpf]).to eq('41492765872')
      expect(parsed_body[:customer][:token]).to eq('LI5YuUJrZuJSB6uPH2jm')
    end

    it 'should return error about name blank' do
      owner = create(:user, :complete_company_owner)

      owner.company.accepted!
      customer_params = { customer: { name: '',
                                      cpf: '41492765872' } }

      post '/api/v1/customer', params: customer_params, headers: { companyToken: owner.company.token }

      expect(response).to have_http_status(422)
      expect(response.content_type).to include('application/json')
      expect(parsed_body[:message]).to eq('Requisição inválida')
      expect(parsed_body[:errors][:name]).to include('não pode ficar em branco')
      expect(parsed_body[:request]).to eq(customer_params)
    end

    context 'POST /api/v1/customer' do
      it 'should save a new customer' do
        owner = create(:user, :complete_company_owner)

        owner.company.accepted!
        customer_params = { customer: { name: 'Caio Silva', 
                                        cpf: '41492765872'} }

        allow(SecureRandom).to receive(:alphanumeric).with(20).and_return('LI5YuUJrZuJSB6uPH2jm')

        post '/api/v1/customer', params: customer_params, headers: { companyToken: owner.company.token }

        expect(response).to have_http_status(201)
        expect(response.content_type).to include('application/json')
        expect(parsed_body[:customer][:name]).to eq('Caio Silva')
        expect(parsed_body[:customer][:cpf]).to eq('41492765872')
        expect(parsed_body[:customer][:token]).to eq('LI5YuUJrZuJSB6uPH2jm')
      end

      it 'should return error about name' do
        owner = create(:user, :complete_company_owner)

        owner.company.accepted!
        customer_params = { customer: { name: '', 
                                        cpf: '41492765872'} }
        post '/api/v1/customer', params: customer_params, headers: { companyToken: owner.company.token }

        expect(response).to have_http_status(422)
        expect(response.content_type).to include('application/json')
        expect(parsed_body[:message]).to eq('Requisição inválida')
        expect(parsed_body[:errors][:cpf]).to include('deve ser composto apenas por números')
        expect(parsed_body[:request]).to eq(customer_params)
      end

      it 'should return error about cpf format with "-" ' do
        owner = create(:user, :complete_company_owner)

        owner.company.accepted!
        customer_params = { customer: { name: 'Caio Silva',
                                        cpf: '411467289-56' } }

        post '/api/v1/customer', params: customer_params, headers: { companyToken: owner.company.token }

        expect(response).to have_http_status(422)
        expect(response.content_type).to include('application/json')
        expect(parsed_body[:message]).to eq('Requisição inválida')
        expect(parsed_body[:errors][:name]).to include('não pode ficar em branco')
        expect(parsed_body[:request]).to eq(customer_params)
      end

      it 'should return error about cpf' do
        owner = create(:user, :complete_company_owner)

        owner.company.accepted!
        customer_params = { customer: { name: 'Caio Silva', 
                                        cpf: ''} }

        post '/api/v1/customer', params: customer_params, headers: { companyToken: owner.company.token }

        expect(response).to have_http_status(422)
        expect(response.content_type).to include('application/json')
        expect(parsed_body[:message]).to eq('Requisição inválida')
        expect(parsed_body[:errors][:cpf]).to include('não pode ficar em branco')
        expect(parsed_body[:request]).to eq(customer_params)
      end

      it 'should return error about both' do
        owner = create(:user, :complete_company_owner)

        owner.company.accepted!
        customer_params = { customer: { name: '', 
                                        cpf: ''} }

        post '/api/v1/customer', params: customer_params, headers: { companyToken: owner.company.token }

        expect(response).to have_http_status(422)
        expect(response.content_type)   .to include('application/json')
        expect(parsed_body[:message]).to eq('Requisição inválida')
        expect(parsed_body[:errors][:name]).to include('não pode ficar em branco')
        expect(parsed_body[:errors][:cpf]).to include('não pode ficar em branco')
        expect(parsed_body[:request]).to eq(customer_params)
      end
    end
  end
