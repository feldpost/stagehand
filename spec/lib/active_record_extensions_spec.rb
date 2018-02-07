describe 'ActiveRecordExtensions' do
  class ConnectionTestMock < SourceRecord; end
  let(:source_record) { SourceRecord.create }

  describe '#synced?' do
    it 'returns false when there are unsynced changes' do
      expect(source_record.synced?).to be(false)
    end

    it 'returns true when there are no unsynced changes' do
      Stagehand::Staging::Synchronizer.sync_record(source_record)
      expect(source_record.synced?).to be(true)
    end
  end

  describe '::connection_specification_name=' do
    it 'set independent value for the same class per thread' do
      thread1_ready = false
      thread2_ready = false

      thread1 = Thread.new do
        ConnectionTestMock.connection_specification_name = 'thread_1_connection'
        thread1_ready = true
        sleep 0.1 until thread2_ready
        expect(ConnectionTestMock.connection_specification_name).to eq('thread_1_connection')
      end

      thread2 = Thread.new do
        sleep 0.1 until thread1_ready
        ConnectionTestMock.connection_specification_name = 'thread_2_connection'
        thread2_ready = true
        expect(ConnectionTestMock.connection_specification_name).to eq('thread_2_connection')
      end

      thread1.join
      thread2.join
    end

    it 'sets the connection specification name for the class in other threads that have not set it yet' do
      thread1_ready = false

      thread1 = Thread.new do
        ConnectionTestMock.connection_specification_name = 'thread_1_connection'
        thread1_ready = true
      end

      thread2 = Thread.new do
        sleep 0.1 until thread1_ready
        expect(ConnectionTestMock.connection_specification_name).to eq('thread_1_connection')
      end

      thread1.join
      thread2.join
    end
  end

  describe '#remove_connection' do
    it 'removes the connection for the current thread' do
      thread1_ready = false
      thread2_ready = false

      expect(ConnectionTestMock.connection_handler).to receive(:remove_connection).with('thread_1_connection')

      thread1 = Thread.new do
        ConnectionTestMock.connection_specification_name = 'thread_1_connection'
        thread1_ready = true
        sleep 0.1 until thread2_ready
        ConnectionTestMock.remove_connection
      end

      thread2 = Thread.new do
        sleep 0.1 until thread1_ready
        ConnectionTestMock.connection_specification_name = 'thread_2_connection'
        thread2_ready = true
      end

      thread1.join
      thread2.join
    end
  end
end
