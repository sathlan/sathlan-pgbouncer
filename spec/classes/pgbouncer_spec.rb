require 'spec_helper'

describe 'pgbouncer' do
  let(:facts) do
    {
      :operatingsystem => 'Debian',
    }
  end

  describe 'when only required parameters are provided' do
    let(:params) do
      {}
    end
    it 'includes the class' do
      subject.should contain_class('pgbouncer')
    end
    it 'has the service' do
      subject.should contain_service('pgbouncer')
    end
    it 'has the package installed' do
      subject.should contain_package('pgbouncer')
    end
  end
end
