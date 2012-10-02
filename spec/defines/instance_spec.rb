require 'spec_helper'

describe 'pgbouncer::instance' do
  let(:pre_condition) do
      'class {"pgbouncer":}'
  end
  let(:facts) do
    {
      :operatingsystem => 'Debian',
      :concat_basedir  => '/var/lib/puppet' # required by concat
    }
  end
  let(:params) do
    {
      :index => 0,
    }
  end
  let(:title) { 'instance' }

  describe 'with only required parameters provided' do
    it { should contain_file('/etc/pgbouncer/instance.ini') }
    it { should contain_file('/etc/defaults/pgbouncer') }
  end
end
