require 'spec_helper'
require 'wash_out/router'

describe WashOut::Router do
  context 'when no matching soap action' do
    before do
      mock_controller do
      end
    end

    it 'returns a 200 with empty soap action' do
      env = {}
      env['REQUEST_METHOD'] = 'GET'
      env['rack.input'] = double 'basic-rack-input', {:string => ''}
      result = WashOut::Router.new('Api').call env

      expect(result[0]).to eq(200)

      msg = result[2][0]
      expect(msg).to eq('OK')
    end
  end

  context 'when action name has "Request" suffix' do
    before do
      mock_controller do
        soap_action 'rumba'

        def rumba
          render text: 'foobar'
        end
      end
    end

    context 'if matching action exists' do
      let(:action) { 'rumba' }

      it 'executes matching action' do
        env = {
          'REQUEST_METHOD' => 'POST',
          'rack.input' => double('basic-rack-input', {:string => ''}),
          'wash_out.soap_action' => action,
          'wash_out.soap_data' => {:Envelope => {:Body => {action.to_sym => {}}}}
        }

        response = WashOut::Router.new('Api').call(env)[2]
        expect(response.body).to eq('foobar')
      end
    end

    context 'if no matching action exists' do
      context 'but matching action without "Request" suffix exists' do
        let(:action) { 'rumbaRequest' }

        it 'executes matching action without "Request" suffix' do
          env = {
            'REQUEST_METHOD' => 'POST',
            'rack.input' => double('basic-rack-input', {:string => ''}),
            'wash_out.soap_action' => action,
            'wash_out.soap_data' => {:Envelope => {:Body => {action.to_sym => {}}}}
          }

          response = WashOut::Router.new('Api').call(env)[2]
          expect(response.body).to eq('foobar')
        end
      end
    end
  end
end
