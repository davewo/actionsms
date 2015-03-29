require 'sms'

describe Sms::Message do
  it 'serializes with from' do
    h = {from: '123', to: '234', text: 'test'}
    msg = Sms::Message.new(h)
    expect(msg.serializable_hash).to eq(h)
  end

  it 'serializes without from' do
    h = {to: '234', text: 'test'}
    msg = Sms::Message.new(h)
    expect(msg.serializable_hash).to eq(h)
  end

  context 'Deliveries' do
    let(:message) { Sms::Message.new(from: '123', to: '234', text: 'test') }

    before do
      delivery = double('delivery')
      Sms.delivery_method = delivery
      expect(delivery).to receive(:deliver!).with(message)
    end

    it 'delivers' do
      message.deliver
    end

    it 'uses delivery handler' do
      handler = double('handler')
      message.delivery_handler = handler
      expect(handler).to receive(:deliver_sms).with(message).and_yield
      message.deliver
    end

    it 'notifies observers' do
      observer = double('observer')
      expect(observer).to receive(:delivered_sms).with(message)
      Sms.register_observer(observer)
      message.deliver
      Sms.unregister_observer(observer)
    end

  end
end
