require 'spec_helper'

describe Puppet::Type.type(:elasticsearch_template) do

  let(:resource_name) { 'test_template' }

  describe 'when validating attributes' do
    [
      :host,
      :name,
      :password,
      :port,
      :protocol,
      :ssl_verify,
      :timeout,
      :username
    ].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:content, :ensure].each do |prop|
      it "should have a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end

    describe 'namevar validation' do
      it 'should have :name as its namevar' do
        expect(described_class.key_attributes).to eq([:name])
      end
    end
  end # of describe when validating attributes

  describe 'when validating values' do
    describe 'content' do
      it 'should reject non-hash values' do
        expect { described_class.new(
          :name => resource_name,
          :content => '{"foo":}'
        ) }.to raise_error(Puppet::Error, /hash expected/i)

        expect { described_class.new(
          :name => resource_name,
          :content => 0
        ) }.to raise_error(Puppet::Error, /hash expected/i)

        expect { described_class.new(
          :name => resource_name,
          :content => {}
        ) }.not_to raise_error
      end
    end

    describe 'ensure' do
      it 'should support present as a value for ensure' do
        expect { described_class.new(
          :name => resource_name,
          :ensure => :present
        ) }.to_not raise_error
      end

      it 'should support absent as a value for ensure' do
        expect { described_class.new(
          :name => resource_name,
          :ensure => :absent
        ) }.to_not raise_error
      end

      it 'should not support other values' do
        expect { described_class.new(
          :name => resource_name,
          :ensure => :foo
        ) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe 'host' do
      it 'should accept IP addresses' do
        expect { described_class.new(
          :name => resource_name,
          :host => '127.0.0.1'
        ) }.not_to raise_error
      end
    end

    describe 'port' do
      [-1, 0, 70000, 'foo'].each do |value|
        it "should reject invalid port value #{value}" do
          expect { described_class.new(
            :name => resource_name,
            :port => value
          ) }.to raise_error(Puppet::Error, /invalid port/i)
        end
      end
    end

    describe 'ssl_verify' do
      [-1, 0, {}, [], 'foo'].each do |value|
        it "should reject invalid ssl_verify value #{value}" do
          expect { described_class.new(
            :name => resource_name,
            :ssl_verify => value
          ) }.to raise_error(Puppet::Error, /invalid value/i)
        end
      end

      [true, false, 'true', 'false', 'yes', 'no'].each do |value|
        it "should accept ssl_verify value #{value}" do
          expect { described_class.new(
            :name => resource_name,
            :ssl_verify => value
          ) }.not_to raise_error
        end
      end
    end

    describe 'timeout' do
      it 'should reject string values' do
        expect { described_class.new(
          :name => resource_name,
          :timeout => 'foo'
        ) }.to raise_error(Puppet::Error, /must be a/)
      end

      it 'should reject negative integers' do
        expect { described_class.new(
          :name => resource_name,
          :timeout => -10
        ) }.to raise_error(Puppet::Error, /must be a/)
      end

      it 'should accept integers' do
        expect { described_class.new(
          :name => resource_name,
          :timeout => 10
        ) }.to_not raise_error
      end

      it 'should accept quoted integers' do
        expect { described_class.new(
          :name => resource_name,
          :timeout => '10'
        ) }.to_not raise_error
      end
    end
  end # of describing when validing values
end # of describe Puppet::Type
