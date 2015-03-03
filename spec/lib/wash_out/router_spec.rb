require 'spec_helper'
require 'wash_out/router'

describe WashOut::Router do
  it 'returns a 200 with empty soap action' do

    mock_controller do
      # nothing
    end

    env = {}
    env['REQUEST_METHOD'] = 'GET'
    env['rack.input'] = double 'basic-rack-input', {:string => ''}
    result = WashOut::Router.new('Api').call env

    expect(result[0]).to eq(200)
    #expect(result[1]['Content-Type']).to eq('text/xml')

    msg = result[2][0]
    expect(msg).to eq('OK')
  end

  context 'when action name has "Request" suffix' do
    mock_controller do
      soap_action 'rumba'

      def rumba
        render text: 'foobar'
      end
    end

    context 'if matching action exists' do
      let(:action) { 'rumba' }

      it 'executes matching action' do
        env = {
          'REQUEST_METHOD' => 'POST',
          'rack.input' => double('basic-rack-input', {:string => ''}),
          'wash_out.soap_action' => action,
          'wash_out.soap_data' => {:Envelope => {:Body => {:rumba => {}}}}
        }

        response = WashOut::Router.new('Api').call(env)[2]
        expect(response.body).to eq('foobar')
      end
    end

    context 'if no matching action exists' do
      context 'but matching action without "Request" suffix exists' do
        it 'executes matching action without "Request" suffix' do
        end
      end
    end
  end
end
