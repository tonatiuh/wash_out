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

  context 'when soap action inferred from request ' do
    before do
      mock_controller do
        soap_action 'rumba'

        def rumba
          render text: 'response-body'
        end
      end
    end

    context 'matches with a controller action' do
      let(:action) { 'rumba' }

      it 'executes matching action' do
        env = {
          'REQUEST_METHOD' => 'POST',
          'rack.input' => double('basic-rack-input', {:string => ''}),
          'wash_out.soap_action' => action,
          'wash_out.soap_data' => {:Envelope => {:Body => {action.to_sym => {}}}}
        }

        response = WashOut::Router.new('Api').call(env)[2]
        expect(response.body).to eq('response-body')
      end
    end

    context 'doesn\'t match any controller action' do
      describe 'interpretation of message tag as soap action' do
        context 'if message tag ends with Request suffix' do
          let(:action) { 'non-existent-action' }
          let(:message_tag) { 'rumbaRequest' }

          context 'ignoring Request suffix' do
            it 'attempts to link message tag with controller actions' do
              env = {
                'REQUEST_METHOD' => 'POST',
                'rack.input' => double('basic-rack-input', {:string => ''}),
                'wash_out.soap_action' => action,
                'wash_out.soap_data' => {:Envelope => {:Body => {message_tag.to_sym => {a: :b}}}}
              }

              response = WashOut::Router.new('Api').call(env)[2]
              expect(response.body).to eq('response-body')
            end
          end
        end
      end
    end
  end
end
