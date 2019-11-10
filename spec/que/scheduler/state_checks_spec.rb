require 'spec_helper'

RSpec.describe Que::Scheduler::StateChecks do
  describe '.check' do
    it 'detects when a migration has not been performed' do
      Que::Scheduler::Migrations.migrate!(version: 3)
      max = Que::Scheduler::Migrations::MAX_VERSION
      expect { described_class.check }.to raise_error(
        /The que-scheduler db migration state was found to be 3. It should be #{max}./
      )
    end

    it 'detects when multiple scheduler jobs are enqueued' do
      2.times { Que::Scheduler::SchedulerJob.enqueue }
      expect { described_class.check }.to raise_error(
        /Only one Que::Scheduler::SchedulerJob should be enqueued. 2 were found./
      )
    end
  end

  describe '.assert_db_migrated' do
    {
      true => :to,
      false => :not_to,
    }.each do |k, v|
      it "detects when running in synchronous mode #{k}" do
        expect(Que::Scheduler::Migrations).to receive(:db_version).and_return(0)
        expect(Que::Scheduler::VersionSupport).to receive(:running_synchronously?).and_return(k)
        expect { described_class.send(:assert_db_migrated) }.to raise_error do |err|
          expect(err.message).send(v, include('synchronous mode'))
        end
      end
    end
  end
end
