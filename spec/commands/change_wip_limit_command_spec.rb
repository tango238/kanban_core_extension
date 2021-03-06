require 'rails_helper'
require 'activity/phase_spec_builder'

describe ChangeWipLimitCommand do
  let(:project_id) { ProjectId('prj_789') }
  let(:service) { double(:wip_limit_service) }

  describe '#execute' do
    context 'no exceptions' do
      it do
        cmd = described_class.new(
          project_id_str: 'prj_789',
          phase_name: 'Dev',
          wip_limit_count: 3
        )
        expect(service)
          .to receive(:change)
          .with(project_id, Phase('Dev'), WipLimit(3))
        cmd.execute(service)
      end
    end

    context 'given phase_name = ""' do
      it do
        cmd = described_class.new(
          project_id_str: 'prj_789',
          phase_name: '',
          wip_limit_count: 3
        )
        expect(cmd.execute(service)).to be_falsey
      end
    end

    context 'given wip_limit_count = ""' do
      it do
        cmd = described_class.new(
          project_id_str: 'prj_789',
          phase_name: 'Dev',
          wip_limit_count: ''
        )
        expect(cmd.execute(service)).to be_falsey
      end
    end

    context 'given wip_limit_count = "0"' do
      it do
        cmd = described_class.new(
          project_id_str: 'prj_789',
          phase_name: 'Dev',
          wip_limit_count: 0
        )
        expect(cmd.execute(service)).to be_falsey
      end
    end

    context 'given wip_limit_count = "-1"' do
      it do
        cmd = described_class.new(
          project_id_str: 'prj_789',
          phase_name: 'Dev',
          wip_limit_count: -1
        )
        expect(cmd.execute(service)).to be_falsey
      end
    end

    context 'given wip_limit_count = "one"' do
      it do
        cmd = described_class.new(
          project_id_str: 'prj_789',
          phase_name: 'Dev',
          wip_limit_count: 'one'
        )
        expect(cmd.execute(service)).to be_falsey
      end
    end

    context 'service raises Activity::UnderCurrentWip' do
      it do
        cmd = described_class.new(
          project_id_str: 'prj_789',
          phase_name: 'Dev',
          wip_limit_count: 3
        )
        allow(service).to receive(:change).and_raise(Activity::UnderCurrentWip)
        expect(cmd.execute(service)).to be_falsey
      end
    end
  end
end
